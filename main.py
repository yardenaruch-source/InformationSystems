from flask import Flask, render_template, request, redirect, url_for, session, flash
from utils import db_cursor
from datetime import datetime, date, timedelta
from urllib.parse import urlparse, urljoin

app = Flask(__name__)
app.secret_key = 'the_winning_triplet'


def is_safe_url(target: str) -> bool:
    """Prevent open-redirects (only allow redirects inside your site)."""
    if not target:
        return False
    ref_url = urlparse(request.host_url)
    test_url = urlparse(urljoin(request.host_url, target))
    return (test_url.scheme, test_url.netloc) == (ref_url.scheme, ref_url.netloc)


def current_user():
    email = session.get("user_email")
    if not email:
        return None

    with db_cursor() as cur:
        cur.execute(
            """
            SELECT customer_email, customer_first_name, customer_last_name, passport_id, birth_date, sign_up_date
            FROM Registered_customer
            WHERE customer_email = %s
            """,
            (email,),
        )
        return cur.fetchone()


@app.route("/")
def home():
    user = current_user()

    just_name = session.pop("just_logged_in_name", None)
    if just_name:
        flash(f"Welcome back, {just_name}!", "success")

    return render_template("index.html", user=user)


@app.route("/login", methods=["GET", "POST"])
def login():
    next_url = request.args.get("next") or request.form.get("next")

    if session.get("user_email"):
        return redirect(next_url or url_for("home"))

    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "").strip()

        if not email or not password:
            flash("Please fill in email and password.", "error")
            return render_template("login.html", next=next_url)

        with db_cursor() as cur:
            cur.execute(
                """
                SELECT customer_email, customer_first_name, customer_last_name
                FROM Registered_customer
                WHERE customer_email = %s AND customer_password = %s
                """,
                (email, password),
            )
            user = cur.fetchone()

        if not user:
            flash("Invalid email or password.", "error")
            return render_template("login.html", next=next_url)

        session["user_email"] = user["customer_email"]
        session["just_logged_in_name"] = user["customer_first_name"]

        if next_url and is_safe_url(next_url):
            return redirect(next_url)
        return redirect(url_for("home"))

    return render_template("login.html", next=next_url)


@app.route("/logout")
def logout():
    session.pop("user_email", None)
    session.pop("just_logged_in_name", None)
    session.pop("guest", None)  # optional, but helps avoid weird leftovers
    flash("You were logged out", "success")
    return redirect(url_for("home"))


@app.route("/register", methods=["GET", "POST"])
def register():
    next_url = request.args.get("next") or request.form.get("next")
    if session.get("user_email"):
        return redirect(next_url if is_safe_url(next_url) else url_for("home"))

    today = date.today().isoformat()

    # IMPORTANT: always define form for GET too (prevents template crash)
    form = {
        "first_name": "",
        "last_name": "",
        "email": "",
        "passport_id": "",
        "birth_date": "",
        "phones": [""],  # default: one empty phone input
    }

    if request.method == "POST":
        first_name = request.form.get("first_name", "").strip()
        last_name = request.form.get("last_name", "").strip()
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "").strip()
        passport_id = request.form.get("passport_id", "").strip()
        birth_date = request.form.get("birth_date", "").strip()

        # collect multiple phones
        phones = [p.strip() for p in request.form.getlist("phone") if p.strip()]

        # refill form for re-render
        form = {
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "passport_id": passport_id,
            "birth_date": birth_date,
            "phones": phones or [""],
        }

        # validation
        if not all([first_name, last_name, email, password, passport_id, birth_date]) or len(phones) == 0:
            flash("Please fill in all fields (including at least one phone).", "error")
            return render_template("register.html", today=today, next=next_url, form=form)

        if len(password) > 8:
            flash("Password must be at most 8 characters.", "error")
            return render_template("register.html", today=today, next=next_url, form=form)

        try:
            bd = datetime.strptime(birth_date, "%Y-%m-%d").date()
        except ValueError:
            flash("Invalid birth date.", "error")
            return render_template("register.html", today=today, next=next_url, form=form)

        if bd < date(1900, 1, 1) or bd > date.today():
            flash("Birth date must be between 1900-01-01 and today.", "error")
            return render_template("register.html", today=today, next=next_url, form=form)

        # DB insert
        try:
            with db_cursor() as cur:
                # existing email?
                cur.execute("SELECT 1 FROM Registered_customer WHERE customer_email = %s", (email,))
                if cur.fetchone():
                    flash("That email is already registered.", "error")
                    return render_template("register.html", today=today, next=next_url, form=form)

                # existing passport?
                cur.execute("SELECT 1 FROM Registered_customer WHERE passport_id = %s", (passport_id,))
                if cur.fetchone():
                    flash("That passport ID is already in use.", "error")
                    return render_template("register.html", today=today, next=next_url, form=form)

                # insert customer
                cur.execute(
                    """
                    INSERT INTO Registered_customer
                    (customer_email, customer_first_name, customer_last_name, customer_password, passport_id, birth_date, sign_up_date)
                    VALUES (%s, %s, %s, %s, %s, %s, CURDATE())
                    """,
                    (email, first_name, last_name, password, passport_id, birth_date),
                )

                # insert phones (table should exist!)
                # Expected table: Registered_customer_phone(customer_email, customer_phone)
                for ph in phones:
                    cur.execute(
                        """
                        INSERT INTO Registered_customer_phone (customer_email, customer_phone)
                        VALUES (%s, %s)
                        """,
                        (email, ph),
                    )

            flash("Registration successful! Please log in.", "success")

            if next_url and is_safe_url(next_url):
                return redirect(url_for("login", next=next_url))
            return redirect(url_for("login"))

        except Exception:
            # If you want to see the real reason, check PythonAnywhere error log.
            flash("Registration failed. Please try again.", "error")
            return render_template("register.html", today=today, next=next_url, form=form)

    # GET
    return render_template("register.html", today=today, next=next_url, form=form)


# ----- the rest of your routes stay the same -----
# book, guest_details, flight_details, seats, checkout, tickets, admin, etc.
# (keep them as you have them)


@app.route("/ping")
def ping():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}


if __name__ == "__main__":
    app.run(debug=True)
