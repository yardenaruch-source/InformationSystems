from flask import Flask, render_template, request, redirect, url_for, session, flash
from utils import db_cursor
from datetime import datetime, date

app = Flask(__name__)
app.secret_key = 'the_winning_triplet'

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
    return render_template("index.html", user=user)

@app.route("/login", methods=["GET", "POST"])
def login():
    if session.get("user_email"):
        return redirect(url_for("home"))

    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "").strip()

        if not email or not password:
            flash("Please fill in email and password.", "error")
            return render_template("login.html")

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
            return render_template("login.html")

        session["user_email"] = user["customer_email"]
        flash(f"Welcome back, {user['customer_first_name']}!", "success")
        return redirect(url_for("home"))

    return render_template("login.html")


@app.route("/logout")
def logout():
    session.pop("user_email", None)
    flash("You were logged out.", "success")
    return redirect(url_for("home"))

@app.route("/register", methods=["GET", "POST"])
def register():
    if session.get("user_email"):
        return redirect(url_for("home"))

    today = date.today().isoformat()

    if request.method == "POST":
        first_name = request.form.get("first_name", "").strip()
        last_name = request.form.get("last_name", "").strip()
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "").strip()
        passport_id = request.form.get("passport_id", "").strip()
        birth_date = request.form.get("birth_date", "").strip()

        if not all([first_name, last_name, email, password, passport_id, birth_date]):
            flash("Please fill in all fields.", "error")
            return render_template("register.html", today=today)

        if len(password) > 8:
            flash("Password must be at most 8 characters.", "error")
            return render_template("register.html", today=today)

        try:
            bd = datetime.strptime(birth_date, "%Y-%m-%d").date()
        except ValueError:
            flash("Invalid birth date.", "error")
            return render_template("register.html", today=today)

        if bd < date(1900, 1, 1) or bd > date.today():
            flash("Birth date must be between 1900-01-01 and today.", "error")
            return render_template("register.html", today=today)

        try:
            with db_cursor() as cur:
                cur.execute(
                    """
                    SELECT 1
                    FROM Registered_customer
                    WHERE customer_email = %s
                    """,
                    (email,),
                )
                if cur.fetchone():
                    flash("That email is already registered.", "error")
                    return render_template("register.html", today=today)

                cur.execute(
                    """
                    SELECT 1
                    FROM Registered_customer
                    WHERE passport_id = %s
                    """,
                    (passport_id,),
                )
                if cur.fetchone():
                    flash("That passport ID is already in use.", "error")
                    return render_template("register.html", today=today)

                cur.execute(
                    """
                    INSERT INTO Registered_customer
                    (customer_email, customer_first_name, customer_last_name, customer_password, passport_id, birth_date, sign_up_date)
                    VALUES (%s, %s, %s, %s, %s, %s, CURDATE())
                    """,
                    (email, first_name, last_name, password, passport_id, birth_date),
                )

            flash("Registration successful! Please log in.", "success")
            return redirect(url_for("login"))

        except Exception as e:
            # Don’t expose sensitive DB details in production; for now it helps debugging
            flash(f"Registration failed: {e}", "error")  #change to: Regiistration faild. Please try again.
            return render_template("register.html", today=today)

    return render_template("register.html", today=today)

@app.route("/book", methods=["GET"])
def book():
    origin = request.args.get("origin", "").strip().upper()
    destination = request.args.get("destination", "").strip().upper()
    date = request.args.get("date", "").strip()

    flights = []
    if origin and destination and date:
        with db_cursor() as cur:
            cur.execute("""
                SELECT
                  f.flight_id,
                  f.takeoff_date,
                  f.takeoff_time,
                  r.origin_airport,
                  r.destination_airport,
                  MIN(cc.price) AS from_price
                FROM Flight f
                JOIN Flight_Route r ON r.route_id = f.route_id
                JOIN Cabin_Class cc ON cc.flight_id = f.flight_id
                WHERE f.flight_status = 'Scheduled'
                  AND f.takeoff_date = %s
                  AND r.origin_airport = %s
                  AND r.destination_airport = %s
                GROUP BY f.flight_id, f.takeoff_date, f.takeoff_time, r.origin_airport, r.destination_airport
                ORDER BY f.takeoff_time
            """, (date, origin, destination))
            flights = cur.fetchall()

    return render_template(
        "book.html",
        origin=origin,
        destination=destination,
        date=date,
        flights=flights
    )

@app.route("/flight/<flight_id>")
def flight_details(flight_id):
    with db_cursor() as cur:
        cur.execute("""
            SELECT f.flight_id, f.takeoff_date, f.takeoff_time,
                   r.origin_airport, r.destination_airport
            FROM Flight f
            JOIN Flight_route r ON r.route_id = f.route_id
            WHERE f.flight_id = %s
        """, (flight_id,))
        flight = cur.fetchone()

    if not flight:
        flash("Flight not found.", "error")
        return redirect(url_for("book"))

    return render_template("flight_details.html", flight=flight)

@app.route("/ping")
def ping():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}

if __name__ == "__main__":
    app.run(debug=True)

