from flask import Flask, render_template, request, redirect, url_for, session, flash
from utils import db_cursor
import mysql.connector
from datetime import datetime, date, timedelta, time
from urllib.parse import urlparse, urljoin
import re
import os
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

app = Flask(__name__)
app.secret_key = 'the_winning_triplet'

app.permanent_session_lifetime = timedelta(minutes=60)
@app.before_request
def refresh_session():
    if session.get("user_email") or session.get("admin_employee_id"):
        session.permanent = True
        session.modified = True

def normalize_time(t):
    if isinstance(t, timedelta):
        secs = int(t.total_seconds())
        h = secs // 3600
        m = (secs % 3600) // 60
        s = secs % 60
        return time(h % 24, m, s)
    return t

PHONE_RE = re.compile(r"^[0-9-]+$")

#remove spaces, keep digits + dashes only
def normalize_phone(p: str) -> str:
    return (p or "").strip().replace(" ", "")

def is_valid_phone(p: str) -> bool:
    p = normalize_phone(p)
    return bool(p) and PHONE_RE.fullmatch(p) is not None

# Get current user details using the session email
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

# Update flight status to 'completed' after takeoff time
def refresh_flight_statuses():
    with db_cursor() as cur:
        cur.execute("""
            UPDATE Flight
            SET flight_status = 'Completed'
            WHERE flight_status IN ('Scheduled', 'Full')
              AND TIMESTAMP(takeoff_date, takeoff_time) < NOW()
        """)

# Show a welcome message after login
@app.route("/")
def home():
    user = current_user()

    just_name = session.pop("just_logged_in_name", None)
    if just_name:
        flash(f"Welcome back, {just_name}!", "success")

    return render_template("index.html", user=user)

@app.route("/login", methods=["GET", "POST"])
def login():
    # Get the page to redirect to after login (if the user was sent here from another route)
    next_url = request.args.get("next") or request.form.get("next")

    # If the user is already logged in, redirect them immediately
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

        # Save the user's login session and keep it active for a limited time
        session.permanent = True

        session["user_email"] = user["customer_email"]
        session["just_logged_in_name"] = user["customer_first_name"]

        # Redirect to the original page safely, otherwise go to the homepage
        if next_url and is_safe_url(next_url):
            return redirect(next_url)
        return redirect(url_for("home"))

    return render_template("login.html", next=next_url)

@app.route("/register", methods=["GET", "POST"])
def register():
    # next can arrive via querystring (GET) or hidden input (POST)
    next_url = request.args.get("next") or request.form.get("next")

    if session.get("user_email"):
        return redirect(next_url if is_safe_url(next_url) else url_for("home"))

    today = date.today().isoformat()

    if request.method == "POST":
        first_name = request.form.get("first_name", "").strip()
        last_name = request.form.get("last_name", "").strip()
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "").strip()
        passport_id = request.form.get("passport_id", "").strip()
        birth_date = request.form.get("birth_date", "").strip()
        phones = [normalize_phone(p) for p in request.form.getlist("phone")]
        phones = [p for p in phones if p]  # keep non-empty

        form = {
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "passport_id": passport_id,
            "birth_date": birth_date,
            "phones": phones
        }

        if not all([first_name, last_name, email, password, passport_id, birth_date]):
            flash("Please fill in all fields.", "error")
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

        if any(not is_valid_phone(p) for p in phones):
            flash("Phone numbers can contain only digits and '-'.", "error")
            return render_template("register.html", today=today, next=next_url, form=form)

        try:
            with db_cursor() as cur:
                cur.execute("""
                    SELECT 1
                    FROM Registered_customer
                    WHERE customer_email = %s
                """, (email,))
                if cur.fetchone():
                    flash("That email is already registered", "error")
                    return render_template("register.html", today=today, next=next_url, form=form)

                cur.execute("""
                    SELECT 1
                    FROM Registered_customer
                    WHERE passport_id = %s
                """, (passport_id,))
                if cur.fetchone():
                    flash("That passport ID is already in use.", "error")
                    return render_template("register.html", today=today, next=next_url, form=form)

                cur.execute("""
                    INSERT INTO Registered_customer
                    (customer_email, customer_first_name, customer_last_name, customer_password, passport_id, birth_date, sign_up_date)
                    VALUES (%s, %s, %s, %s, %s, %s, CURDATE())
                """, (email, first_name, last_name, password, passport_id, birth_date))

                # Replace phones (delete then insert)
                cur.execute("DELETE FROM Registered_customer_phone WHERE customer_email = %s", (email,))
                for ph in phones:
                    cur.execute("""
                        INSERT INTO Registered_customer_phone (customer_email, customer_phone)
                        VALUES (%s, %s)
                    """, (email, ph))

            flash("Registration successful! Please log in.", "success")

            # ✅ send them to login, and preserve next for after login
            if next_url and is_safe_url(next_url):
                return redirect(url_for("login", next=next_url))
            return redirect(url_for("login"))

        except Exception:
            flash("Registration failed. Please try again.", "error")
            return render_template("register.html", today=today, next=next_url, form=form)

    # GET
    return render_template("register.html", today=today, next=next_url, form=None)

@app.route("/book", methods=["GET"])
def book():
    refresh_flight_statuses()

    origin = request.args.get("origin", "").strip()
    destination = request.args.get("destination", "").strip()
    date = request.args.get("date", "").strip()

    with db_cursor() as cur:
        # dropdown list
        cur.execute("""
            SELECT DISTINCT origin_airport AS airport FROM Flight_route
            UNION
            SELECT DISTINCT destination_airport AS airport FROM Flight_route
            ORDER BY airport
        """)
        airports = [r["airport"] for r in cur.fetchall()]

        # base query: show ALL scheduled flights
        sql = """
            SELECT
              f.flight_id,
              f.takeoff_date,
              f.takeoff_time,
              r.origin_airport,
              r.destination_airport,
              DATE(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_date,
              TIME(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_time,
              MIN(p.price) AS from_price
            FROM Flight f
            JOIN Flight_route r ON r.route_id = f.route_id
            LEFT JOIN Flight_Class_Pricing p
              ON p.flight_id = f.flight_id
             AND p.plane_id = f.plane_id
             AND p.class_type = 'Economy'
            WHERE f.flight_status = 'Scheduled'
        """

        params = []

        # apply filters only if user chose them
        if date:
            sql += " AND f.takeoff_date = %s"
            params.append(date)
        if origin:
            sql += " AND r.origin_airport = %s"
            params.append(origin)
        if destination:
            sql += " AND r.destination_airport = %s"
            params.append(destination)

        sql += """
            GROUP BY f.flight_id, f.takeoff_date, f.takeoff_time, r.origin_airport, r.destination_airport
            ORDER BY f.takeoff_date, f.takeoff_time
        """

        cur.execute(sql, params)
        flights = cur.fetchall()

    return render_template(
        "book.html",
        origin=origin,
        destination=destination,
        date=date,
        flights=flights,
        airports=airports
    )

@app.route("/booking-log/<flight_id>", methods=["GET"])
def booking_log(flight_id):
    with db_cursor() as cur:
        cur.execute("SELECT 1 FROM Flight WHERE flight_id = %s", (flight_id,))
        if not cur.fetchone():
            flash("Flight not found.", "error")
            return redirect(url_for("book"))

    return render_template("booking_log.html", flight_id=flight_id)

@app.route("/booking/<flight_id>/guest", methods=["GET", "POST"])
def guest_details(flight_id):
    flight_id = flight_id.strip().upper()

    # after guest details, continue to the flight page (then seats)
    next_url = request.args.get("next") or request.form.get("next") or url_for("flight_details", flight_id=flight_id)

    # used to re-fill the form if there is an error
    form = {"email": "", "full_name": "", "passport_id": "", "phones": []}

    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        full_name = request.form.get("full_name", "").strip()
        passport_id = request.form.get("passport_id", "").strip()  # collected but NOT saved
        phones = [normalize_phone(p) for p in request.form.getlist("phone")]
        phones = [p for p in phones if p]

        form = {"email": email, "full_name": full_name, "passport_id": passport_id, "phones": phones}

        # validation
        if not email or not full_name or not passport_id or len(phones) == 0:
            flash("Please fill in all fields (including at least one phone).", "error")
            return render_template(
                "guest_details.html",
                flight_id=flight_id,
                next_url=next_url,
                form=form,
                registered_customer=False
            )

        if any(not is_valid_phone(p) for p in phones):
            flash("Phone numbers can contain only digits and '-'.", "error")
            return render_template(
                "guest_details.html",
                flight_id=flight_id,
                next_url=next_url,
                form=form,
                registered_customer=False
            )

        # If email belongs to registered customer -> show message then redirect to login
        with db_cursor() as cur:
            cur.execute("SELECT 1 FROM Registered_customer WHERE customer_email = %s", (email,))
            exists = cur.fetchone() is not None

        if exists:
            flash("This email belongs to a registered customer.\n Please log in.", "error")
            return redirect(url_for("login", next=url_for("flight_details", flight_id=flight_id)))

        # split full name to first/last for Guest table
        parts = full_name.split()
        first_name = parts[0]
        last_name = " ".join(parts[1:]) if len(parts) > 1 else ""

        # keep guest info in session so seats() can use it
        session["guest"] = {
            "email": email,
            "first_name": first_name,
            "last_name": last_name,
            "phones": phones
        }

        return redirect(next_url)

    # GET
    return render_template(
        "guest_details.html",
        flight_id=flight_id,
        next_url=next_url,
        form=form,
        registered_customer=False
    )

@app.route("/booking/<flight_id>/customer-details", methods=["GET", "POST"])
def customer_details(flight_id):
    # must be logged in
    if not session.get("user_email"):
        # if not logged in, send them to guest flow or login
        return redirect(url_for("guest_details", flight_id=flight_id, next=url_for("flight_details", flight_id=flight_id)))

    flight_id = flight_id.strip().upper()

    # after details, continue to flight details
    next_url = request.args.get("next") or request.form.get("next") or url_for("flight_details", flight_id=flight_id)

    email = session.get("user_email")

    # GET: prefill form from DB
    with db_cursor() as cur:
        cur.execute("""
            SELECT customer_email, customer_first_name, customer_last_name, passport_id, birth_date
            FROM Registered_customer
            WHERE customer_email = %s
        """, (email,))
        user = cur.fetchone()

        cur.execute("""
            SELECT customer_phone
            FROM Registered_customer_phone
            WHERE customer_email = %s
            ORDER BY customer_phone
        """, (email,))
        phones = [r["customer_phone"] for r in cur.fetchall()]

    if not user:
        flash("User not found. Please log in again.", "error")
        return redirect(url_for("logout"))

    form = {
        "email": user["customer_email"],
        "first_name": user["customer_first_name"],
        "last_name": user["customer_last_name"],
        "passport_id": user["passport_id"],
        "birth_date": str(user["birth_date"]),
        "phones": phones
    }

    if request.method == "POST":
        first_name = request.form.get("first_name", "").strip()
        last_name = request.form.get("last_name", "").strip()
        passport_id = request.form.get("passport_id", "").strip()
        birth_date = request.form.get("birth_date", "").strip()
        phones_new = [normalize_phone(p) for p in request.form.getlist("phone")]
        phones_new = [p for p in phones_new if p]

        # re-fill if error
        form.update({
            "first_name": first_name,
            "last_name": last_name,
            "passport_id": passport_id,
            "birth_date": birth_date,
            "phones": phones_new
        })

        # basic validation
        if not all([first_name, last_name, passport_id, birth_date]) or len(phones_new) == 0:
            flash("Please fill in all fields (including at least one phone).", "error")
            return render_template("customer_details.html", flight_id=flight_id, next_url=next_url, form=form)

        if any(not is_valid_phone(p) for p in phones_new):
            flash("Phone numbers can contain only digits and '-'.", "error")
            return render_template("customer_details.html", flight_id=flight_id, next_url=next_url, form=form)

        try:
            bd = datetime.strptime(birth_date, "%Y-%m-%d").date()
            if bd < date(1900, 1, 1) or bd > date.today():
                raise ValueError()
        except ValueError:
            flash("Birth date must be valid (YYYY-MM-DD) and between 1900 and today.", "error")
            return render_template("customer_details.html", flight_id=flight_id, next_url=next_url, form=form)

        session["booking_customer"] = {
            "email": email,
            "first_name": first_name,
            "last_name": last_name,
            "passport_id": passport_id,
            "birth_date": birth_date,
            "phones": phones_new
        }

        return redirect(next_url)

    return render_template("customer_details.html", flight_id=flight_id, next_url=next_url, form=form)

def create_seats_for_flight(cur, flight_id: str, plane_id: str):
    # get both cabin layouts
    cur.execute("""
        SELECT class_type, rows_num, columns_num
        FROM Cabin_class
        WHERE plane_id = %s
    """, (plane_id,))
    cabins = cur.fetchall()

    layout = {c["class_type"]: (int(c["rows_num"]), int(c["columns_num"])) for c in cabins}

    if "Economy" not in layout:
        raise ValueError("Missing Economy layout for this plane")

    has_business = "Business" in layout

    econ_rows, econ_cols = layout["Economy"]
    bus_rows, bus_cols = (0, 0)
    if has_business:
        bus_rows, bus_cols = layout["Business"]

    # make sure no leftovers (important if you retry same flight_id)
    cur.execute("DELETE FROM Seat WHERE flight_id = %s", (flight_id,))

    # Business seats: rows 1..bus_rows
    if has_business:
        for r in range(1, bus_rows + 1):
            for c in range(1, bus_cols + 1):
                cur.execute("""
                    INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
                    VALUES (%s, %s, %s, %s, 'Business', NULL)
                """, (flight_id, r, c, plane_id))

    # Economy seats: start AFTER Business rows
    econ_row_start = bus_rows + 1 if has_business else 1
    for r in range(econ_row_start, econ_row_start + econ_rows):
        for c in range(1, econ_cols + 1):
            cur.execute("""
                INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
                VALUES (%s, %s, %s, %s, 'Economy', NULL)
            """, (flight_id, r, c, plane_id))

@app.route("/flight/<flight_id>")
def flight_details(flight_id):
    with db_cursor() as cur:
        # flight + route info
        cur.execute("""
            SELECT f.flight_id, f.takeoff_date, f.takeoff_time,
                   r.origin_airport, r.destination_airport, f.plane_id
            FROM Flight f
            JOIN Flight_route r ON r.route_id = f.route_id
            WHERE f.flight_id = %s
        """, (flight_id,))
        flight = cur.fetchone()
        if not flight:
            flash("Flight not found.", "error")
            return redirect(url_for("book"))

        # cabin classes (price + dimensions)
        cur.execute("""
            SELECT
              cc.class_type,
              cc.rows_num,
              cc.columns_num,
              p.price
            FROM Cabin_class cc
            LEFT JOIN Flight_Class_Pricing p
              ON p.flight_id = %s
             AND p.plane_id  = cc.plane_id
             AND p.class_type = cc.class_type
            WHERE cc.plane_id = %s
            ORDER BY cc.class_type
        """, (flight_id, flight["plane_id"]))
        cabins = cur.fetchall()

        # availability per class (count seats where order_id is NULL)
        cur.execute("""
            SELECT class_type, COUNT(*) AS available
            FROM Seat
            WHERE flight_id = %s AND order_id IS NULL
            GROUP BY class_type
        """, (flight_id,))
        avail_map = {row["class_type"]: row["available"] for row in cur.fetchall()}

    # attach availability into cabins
    for c in cabins:
        c["available"] = avail_map.get(c["class_type"], 0)

    return render_template("flight_details.html", flight=flight, cabins=cabins)

@app.route("/seats/<flight_id>", methods=["GET", "POST"])
def seats(flight_id):
    class_type = request.args.get("class_type") or request.form.get("class_type")

    cleanup_expired_pending_orders()

    if class_type not in ("Economy", "Business"):
        flash("Invalid class type.", "error")
        return redirect(url_for("flight_details", flight_id=flight_id))

    with db_cursor() as cur:
        cur.execute("""
            SELECT cc.rows_num, cc.columns_num, p.price, f.plane_id
            FROM Flight f
            JOIN Cabin_class cc
              ON cc.plane_id = f.plane_id
             AND cc.class_type = %s
            JOIN Flight_Class_Pricing p
              ON p.flight_id = f.flight_id
             AND p.plane_id  = f.plane_id
             AND p.class_type = cc.class_type
            WHERE f.flight_id = %s
        """, (class_type, flight_id))
        cabin = cur.fetchone()
        if not cabin:
            flash("Cabin not found for this flight.", "error")
            return redirect(url_for("flight_details", flight_id=flight_id))

        if request.method == "POST":
            selected = request.form.getlist("seat")  # values like "3-2"
            if not selected:
                flash("Please select at least one seat.", "error")
            else:
                # create order
                oid = generate_order_id(cur)
                user_email = session.get("user_email")

                if user_email:
                    # Registered user order
                    cur.execute("""
                        INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
                        VALUES (%s, %s, %s, %s, NOW(), 'Pending')
                    """, (oid, flight_id, None, user_email))
                else:
                    guest_email = (session.get("guest", {}).get("email") or "").strip().lower()

                    if not guest_email:
                        flash("Guest details are missing. Please continue as guest again.", "error")
                        return redirect(url_for("guest_details", flight_id=flight_id,
                                                next=url_for("seats", flight_id=flight_id, class_type=class_type)))

                    cur.execute("""
                        INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
                        VALUES (%s, %s, %s, %s, NOW(), 'Pending')
                    """, (oid, flight_id, guest_email, None))

                # try to reserve seats (only if still free)
                ok = True
                for s in selected:
                    r_str, c_str = s.split("-")
                    r = int(r_str)
                    c = int(c_str)
                    cur.execute("""
                        UPDATE Seat
                        SET order_id = %s
                        WHERE flight_id = %s AND class_type = %s
                          AND s_row = %s AND s_column = %s
                          AND order_id IS NULL
                    """, (oid, flight_id, class_type, r, c))
                    if cur.rowcount != 1:
                        ok = False
                        break

                if not ok:
                    # rollback logic is limited with autocommit=True; simplest: cancel the order + release any reserved seats
                    cur.execute("UPDATE Seat SET order_id = NULL WHERE order_id = %s", (oid,))
                    cur.execute("UPDATE Orders SET order_status = 'Cancelled by system' WHERE order_id = %s", (oid,))
                    flash("One of the seats was just taken. Please try again.", "error")
                else:
                    return redirect(url_for("checkout", order_id=oid))

        # Build seat map for GET (and for re-render after POST errors)
        cur.execute("""
            SELECT s_row, s_column, order_id
            FROM Seat
            WHERE flight_id = %s AND class_type = %s
        """, (flight_id, class_type))
        seats_rows = cur.fetchall()

    # Create a fast lookup: (row,col) -> is_taken
    taken = {(s["s_row"], s["s_column"]): (s["order_id"] is not None) for s in seats_rows}

    return render_template(
        "seats.html",
        flight_id=flight_id,
        class_type=class_type,
        cabin=cabin,
        taken=taken
    )

@app.route("/checkout/<order_id>", methods=["GET", "POST"])
def checkout(order_id):
    if request.method == "POST":
        cleanup_expired_pending_orders()

        with db_cursor() as cur:
            cur.execute("""
                UPDATE Orders
                SET order_status = 'Active',
                    date_of_purchase = NOW()
                WHERE order_id = %s AND order_status = 'Pending'
            """, (order_id,))

            if cur.rowcount != 1:
                flash("This reservation expired or was already confirmed. Please book again.", "error")
                return redirect(url_for("book"))

            # ✅ If this order is for a guest, save guest details NOW (after payment)
            cur.execute("SELECT flight_id, guest_email FROM Orders WHERE order_id = %s", (order_id,))
            row = cur.fetchone()
            guest_email = (row or {}).get("guest_email")

            if guest_email:
                guest = session.get("guest")

                # If session is missing guest info, you can decide what to do:
                # either block the purchase, or save only guest_email.
                if not guest or guest.get("email") != guest_email:
                    flash("Guest details missing. Please continue as guest again.", "error")
                    return redirect(url_for("booking_log", flight_id=row.get("flight_id")))

                first_name = guest.get("first_name", "")
                last_name = guest.get("last_name", "")
                phones = guest.get("phones", [])

                # IMPORTANT: change table/column names to match your DB schema
                cur.execute("""
                    INSERT INTO Guest (customer_email, customer_first_name, customer_last_name)
                    VALUES (%s, %s, %s)
                    ON DUPLICATE KEY UPDATE
                      customer_first_name = VALUES(customer_first_name),
                      customer_last_name  = VALUES(customer_last_name)
                """, (guest_email, first_name, last_name))

                cur.execute("DELETE FROM Guest_phone WHERE customer_email = %s", (guest_email,))
                for ph in phones:
                    cur.execute("""
                        INSERT INTO Guest_phone (customer_email, customer_phone)
                        VALUES (%s, %s)
                    """, (guest_email, ph))

                # optional: cleanup so it won't leak to next order
                session.pop("guest", None)

        flash("Payment confirmed. Order is now active!", "success")
        return redirect(url_for("checkout", order_id=order_id))

    with db_cursor() as cur:
        cur.execute("""
            SELECT o.order_id, o.flight_id, o.date_of_purchase, o.order_status,
                   f.takeoff_date, f.takeoff_time,
                   r.origin_airport, r.destination_airport,
                   DATE(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_date,
                   TIME(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_time
            FROM Orders o
            JOIN Flight f ON f.flight_id = o.flight_id
            JOIN Flight_route r ON r.route_id = f.route_id
            WHERE o.order_id = %s
        """, (order_id,))
        order = cur.fetchone()

        if not order:
            flash("Order not found.", "error")
            return redirect(url_for("home"))

        cur.execute("""
            SELECT class_type, s_row, s_column
            FROM Seat
            WHERE order_id = %s
            ORDER BY class_type, s_row, s_column
        """, (order_id,))
        seats = cur.fetchall()

        cur.execute("""
            SELECT COALESCE(SUM(fcp.price), 0) AS total
            FROM Seat s
            JOIN Flight_Class_Pricing fcp
              ON fcp.flight_id  = s.flight_id
             AND fcp.plane_id   = s.plane_id
             AND fcp.class_type = s.class_type
            WHERE s.order_id = %s
        """, (order_id,))
        total = cur.fetchone()["total"]

    return render_template("checkout.html", order=order, seats=seats, total=total)

@app.route("/tickets", methods=["GET", "POST"])
def tickets():
    cleanup_expired_pending_orders()

    refresh_flight_statuses()

    order = None
    seats = []
    total = 0
    can_cancel = False

    if request.method == "POST":
        order_id = request.form.get("order_id", "").strip()
        email = request.form.get("email", "").strip().lower()

        with db_cursor() as cur:
            cur.execute("""
                SELECT
                    o.order_id, o.flight_id, o.order_status,
                    f.takeoff_date, f.takeoff_time,
                    DATE(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_date,
                    TIME(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_time,
                    r.origin_airport, r.destination_airport,
                    o.guest_email, o.reg_customer_email
                FROM Orders o
                JOIN Flight f ON f.flight_id = o.flight_id
                JOIN Flight_route r ON r.route_id = f.route_id
                WHERE o.order_id = %s
                  AND (o.guest_email = %s OR o.reg_customer_email = %s)
            """, (order_id, email, email))
            order = cur.fetchone()

            if not order:
                flash("No matching order found for that code + email.", "error")
                return render_template("tickets.html")

            cur.execute("""
                SELECT class_type, s_row, s_column
                FROM Seat
                WHERE order_id = %s
                ORDER BY class_type, s_row, s_column
            """, (order_id,))
            seats = cur.fetchall()

            cur.execute("""
                SELECT COALESCE(SUM(fcp.price), 0) AS total
                FROM Seat s
                JOIN Flight_Class_Pricing fcp
                  ON fcp.flight_id  = s.flight_id
                 AND fcp.plane_id   = s.plane_id
                 AND fcp.class_type = s.class_type
                WHERE s.order_id = %s;
            """, (order_id,))
            total = (cur.fetchone() or {}).get("total") or 0

        # cancel eligibility: > 36 hours before takeoff and status Active
        takeoff_t = normalize_time(order["takeoff_time"])
        takeoff_dt = datetime.combine(order["takeoff_date"], takeoff_t)
        can_cancel = (order["order_status"] == "Active") and (takeoff_dt - datetime.now() > timedelta(hours=36))

    return render_template("tickets.html", order=order, seats=seats, total=total, can_cancel=can_cancel)

@app.route("/cancel/<order_id>", methods=["POST"])
def cancel_order(order_id):
    refresh_flight_statuses()
    with db_cursor() as cur:
        # fetch order + flight time
        cur.execute("""
            SELECT o.order_id, o.flight_id, o.order_status,
                   f.takeoff_date, f.takeoff_time
            FROM Orders o
            JOIN Flight f ON f.flight_id = o.flight_id
            WHERE o.order_id = %s
        """, (order_id,))
        order = cur.fetchone()

        if not order:
            flash("Order not found.", "error")
            return redirect(url_for("home"))

        if order["order_status"] != "Active":
            flash("Only active orders can be cancelled.", "error")
            return redirect(url_for("tickets"))

        # ✅ 36h rule
        takeoff_t = normalize_time(order["takeoff_time"])
        takeoff_dt = datetime.combine(order["takeoff_date"], takeoff_t)
        if takeoff_dt - datetime.now() <= timedelta(hours=36):
            flash("Too late to cancel (must be more than 36 hours before takeoff).", "error")
            return redirect(url_for("tickets"))

        # ✅ STEP 1: calculate total BEFORE releasing seats
        cur.execute("""
            SELECT COALESCE(SUM(fcp.price), 0) AS total
            FROM Seat s
            JOIN Flight_Class_Pricing fcp
              ON fcp.flight_id  = s.flight_id
             AND fcp.plane_id   = s.plane_id
             AND fcp.class_type = s.class_type
            WHERE s.order_id = %s
        """, (order_id,))
        total = (cur.fetchone() or {}).get("total") or 0

        fee = round(float(total) * 0.05, 2)
        refund = round(float(total) * 0.95, 2)

        # ✅ STEP 2: apply cancellation (update status + release seats)
        cur.execute(
            "UPDATE Orders SET order_status = 'Cancelled by customer' WHERE order_id = %s",
            (order_id,)
        )
        cur.execute(
            "UPDATE Seat SET order_id = NULL WHERE order_id = %s",
            (order_id,)
        )

        # ✅ STEP 3: show refund message
        flash(f"Order cancelled. Fee ₪{fee:.2f}. Refund ₪{refund:.2f}.", "success")

    return redirect(url_for("tickets"))

@app.route("/purchase-history", methods=["GET"])
def purchase_history():
    # Only for logged-in users
    if not session.get("user_email"):
        flash("Please log in to view your purchase history.", "error")
        return redirect(url_for("login", next=url_for("purchase_history")))

    refresh_flight_statuses()

    email = session["user_email"]

    # Filter status from querystring: ?status=Active / Completed / Cancelled by customer / Cancelled by system
    status = request.args.get("status", "").strip()

    allowed_statuses = {
        "Active",
        "Completed",
        "Cancelled by customer",
        "Cancelled by system",
    }

    where = ["o.reg_customer_email = %s", "o.order_status IN ('Active','Completed','Cancelled by customer')"]

    params = [email]

    if status:
        if status not in allowed_statuses:
            flash("Invalid status filter.", "error")
            return redirect(url_for("purchase_history"))
        where.append("o.order_status = %s")
        params.append(status)

    where_sql = "WHERE " + " AND ".join(where)

    with db_cursor() as cur:
        # One query: orders + seats_count + total price (from Flight_Class_Pricing)
        cur.execute(f"""
            SELECT
              o.order_id,
              o.flight_id,
              o.date_of_purchase,
              o.order_status,
              f.takeoff_date,
              f.takeoff_time,
              r.origin_airport,
              r.destination_airport,
              COUNT(s.order_id) AS seats_count,
              COALESCE(SUM(fcp.price), 0) AS total
            FROM Orders o
            JOIN Flight f ON f.flight_id = o.flight_id
            JOIN Flight_route r ON r.route_id = f.route_id
            LEFT JOIN Seat s ON s.order_id = o.order_id
            LEFT JOIN Flight_Class_Pricing fcp
              ON fcp.flight_id  = o.flight_id
             AND fcp.plane_id   = s.plane_id
             AND fcp.class_type = s.class_type
            {where_sql}
            GROUP BY
              o.order_id, o.flight_id, o.date_of_purchase, o.order_status,
              f.takeoff_date, f.takeoff_time, r.origin_airport, r.destination_airport
            ORDER BY o.date_of_purchase DESC
            LIMIT 500
        """, tuple(params))

        orders = cur.fetchall()

    return render_template(
        "purchase_history.html",
        orders=orders,
        selected_status=status
    )

@app.route("/logout")
def logout():
    session.pop("user_email", None)
    session.pop("just_logged_in_name", None)

    # ✅ if the user clicked "Admin" and we forced logout first
    next_url = session.pop("next_after_logout", None)
    if next_url:
        return redirect(next_url)

    flash("You were logged out", "success")
    return redirect(url_for("home"))

def is_safe_url(target: str) -> bool:
    """Prevent open-redirects (only allow redirects inside your site)."""
    if not target:
        return False
    ref_url = urlparse(request.host_url)
    test_url = urlparse(urljoin(request.host_url, target))
    return (test_url.scheme, test_url.netloc) == (ref_url.scheme, ref_url.netloc)

def generate_order_id(cur, max_tries=20):
    for _ in range(max_tries):
        cur.execute("SELECT LPAD(FLOOR(RAND()*99999), 5, '0') AS oid")
        oid = cur.fetchone()["oid"]
        cur.execute("SELECT 1 FROM Orders WHERE order_id = %s", (oid,))
        if not cur.fetchone():
            return oid
    raise RuntimeError("Could not generate unique order id")

def cleanup_expired_pending_orders():
    with db_cursor() as cur:
        # 1) find orders that should be removed (never paid)
        cur.execute("""
            SELECT order_id
            FROM Orders
            WHERE
              (order_status = 'Pending' AND date_of_purchase < (NOW() - INTERVAL 15 MINUTE))
              OR
              (order_status = 'Cancelled by customer' AND date_of_purchase < (NOW() - INTERVAL 15 MINUTE))
        """)
        old_orders = [r["order_id"] for r in cur.fetchall()]

        # 2) release seats + delete the orders
        for oid in old_orders:
            cur.execute("UPDATE Seat SET order_id = NULL WHERE order_id = %s", (oid,))
            cur.execute("DELETE FROM Orders WHERE order_id = %s", (oid,))

@app.route("/admin/login", methods=["GET", "POST"])
def admin_login():
    if request.method == "POST":
        employee_id = request.form.get("employee_id", "").strip()
        password = request.form.get("password", "").strip()

        with db_cursor() as cur:
            cur.execute("""
                SELECT employee_id, employee_first_name, manager_password 
                FROM Manager
                WHERE employee_id = %s
            """, (employee_id,))
            manager = cur.fetchone()

        if not manager or manager["manager_password"] != password:
            flash("Invalid employee ID or password", "error")
            return render_template("admin_login.html")

        session.permanent = True

        session["admin_employee_id"] = manager["employee_id"]
        session['admin_name'] = manager["employee_first_name"]

        flash(f"Welcome back, admin {manager['employee_first_name']}!", "success")
        return redirect(url_for("admin_flights"))

    return render_template("admin_login.html")

@app.route("/go-admin")
def go_admin():
    # Customer logged in -> block and remember where to go after logout
    if session.get("user_email"):
        session["next_after_logout"] = url_for("admin_login")
        flash("Please logout of the customer account", "error")
        return redirect(request.referrer or url_for("home"))

    # Not logged in as customer -> allow admin login
    return redirect(url_for("admin_login"))

@app.route("/admin/flights", methods=["GET"])
def admin_flights():
    if not session.get("admin_employee_id"):
        return redirect(url_for("admin_login"))

    refresh_flight_statuses()

    flight_id = request.args.get("flight_id", "").strip().upper()
    status = request.args.get("status", "").strip()
    takeoff_date = request.args.get("takeoff_date", "").strip()

    where = []
    params = []

    if flight_id:
        where.append("f.flight_id = %s")
        params.append(flight_id)
    if status:
        where.append("f.flight_status = %s")
        params.append(status)
    if takeoff_date:
        where.append("f.takeoff_date = %s")
        params.append(takeoff_date)

    where_sql = ("WHERE " + " AND ".join(where)) if where else ""

    with db_cursor() as cur:
        cur.execute("""
            SELECT
              f.flight_id, f.takeoff_date, f.takeoff_time, f.flight_status,
              r.origin_airport, r.destination_airport,
              DATE(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_date,
              TIME(DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)) AS landing_time,
              f.plane_id, f.manager_id
            FROM Flight f
            JOIN Flight_route r ON r.route_id = f.route_id
            {where_sql}
            ORDER BY f.takeoff_date DESC, f.takeoff_time DESC
            LIMIT 200
        """.format(where_sql=where_sql), tuple(params))

        flights = cur.fetchall()

    now = datetime.now()
    for f in flights:
        # takeoff_time from MySQL might be a timedelta or time; normalize_time handles it in your project
        takeoff_t = normalize_time(f["takeoff_time"])
        takeoff_dt = datetime.combine(f["takeoff_date"], takeoff_t)

        f["can_cancel_72h"] = (takeoff_dt - now) >= timedelta(hours=72)

    return render_template(
        "admin_flights.html",
        flights=flights,
        filters={"flight_id": flight_id, "status": status, "takeoff_date": takeoff_date},
    )

@app.route("/admin/add/plane", methods=["GET", "POST"])
def admin_add_plane():
    if not session.get("admin_employee_id"):
        return redirect(url_for("admin_login"))

    if request.method == "POST":
        plane_id = request.form.get("plane_id", "").strip().upper()
        plane_size = request.form.get("plane_size", "").strip()
        plane_manufacturer = request.form.get("plane_manufacturer", "").strip()
        purchase_date = request.form.get("purchase_date", "").strip()

        econ_rows = request.form.get("econ_rows", "").strip()
        econ_cols = request.form.get("econ_cols", "").strip()

        bus_rows = request.form.get("bus_rows", "").strip()
        bus_cols = request.form.get("bus_cols", "").strip()

        if not all([plane_id, plane_size, plane_manufacturer, purchase_date, econ_rows, econ_cols]):
            flash("Please fill in all required fields.", "error")
            return render_template("admin_add_plane.html")

        # ✅ Business required ONLY if Large
        if plane_size == "Large" and (not bus_rows or not bus_cols):
            flash("Large planes must include Business rows and columns.", "error")
            return render_template("admin_add_plane.html")

        try:
            econ_rows = int(econ_rows)
            econ_cols = int(econ_cols)

            if econ_rows <= 0 or econ_cols <= 0:
                raise ValueError()

            if plane_size == "Large":
                bus_rows = int(bus_rows)
                bus_cols = int(bus_cols)
                if bus_rows <= 0 or bus_cols <= 0:
                    raise ValueError()

        except ValueError:
            flash("Rows/Columns must be positive numbers.", "error")
            return render_template("admin_add_plane.html")

        try:
            with db_cursor() as cur:
                # 1) Insert Plane
                cur.execute("""
                    INSERT INTO Plane (plane_id, plane_size, plane_manufacturer, purchase_date)
                    VALUES (%s, %s, %s, %s)
                """, (plane_id, plane_size, plane_manufacturer, purchase_date))

                # 2) Insert Economy cabin layout
                cur.execute("""
                    INSERT INTO Cabin_class (plane_id, class_type, rows_num, columns_num)
                    VALUES (%s, 'Economy', %s, %s)
                """, (plane_id, econ_rows, econ_cols))

                # 3) Insert Business cabin layout ONLY for Large
                if plane_size == "Large":
                    cur.execute("""
                        INSERT INTO Cabin_class (plane_id, class_type, rows_num, columns_num)
                        VALUES (%s, 'Business', %s, %s)
                    """, (plane_id, bus_rows, bus_cols))

            flash("Plane + cabin layout added successfully.", "success")
            return redirect(url_for("admin_flights"))

        except mysql.connector.Error as e:
            flash(f"Database error: {e.msg}", "error")
            return render_template("admin_add_plane.html")

    return render_template("admin_add_plane.html")

@app.route("/admin/add/route", methods=["GET", "POST"])
def admin_add_route():
    if not session.get("admin_employee_id"):
        return redirect(url_for("admin_login"))

    if request.method == "POST":
        route_id = request.form.get("route_id", "").strip()
        origin = request.form.get("origin_airport", "").strip().upper()
        dest = request.form.get("destination_airport", "").strip().upper()
        duration = request.form.get("flight_duration", "").strip()

        if not all([route_id, origin, dest, duration]):
            flash("Please fill in all fields.", "error")
            return render_template("admin_add_route.html")

        with db_cursor() as cur:
            cur.execute("""
                INSERT INTO Flight_route (route_id, origin_airport, destination_airport, flight_duration)
                VALUES (%s, %s, %s, %s)
            """, (route_id, origin, dest, duration))

        flash("Route added successfully.", "success")
        return redirect(url_for("admin_flights"))

    return render_template("admin_add_route.html")

def has_plane_conflict(cur, plane_id, new_start_dt, new_end_dt):
    """
    Returns a dict with the conflicting flight (flight_id + window) if conflict exists,
    otherwise returns None.
    Only considers Scheduled/Full flights.
    """
    plane_id = (plane_id or "").strip().upper()

    cur.execute("""
        SELECT
          f.flight_id,
          f.flight_status,
          TIMESTAMP(f.takeoff_date, f.takeoff_time) AS start_dt,
          DATE_ADD(
            TIMESTAMP(f.takeoff_date, f.takeoff_time),
            INTERVAL r.flight_duration MINUTE
          ) AS end_dt
        FROM Flight f
        JOIN Flight_route r ON r.route_id = f.route_id
        WHERE f.plane_id = %s
          AND f.flight_status IN ('Scheduled', 'Full')
          AND %s < DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)
          AND %s > TIMESTAMP(f.takeoff_date, f.takeoff_time)
        ORDER BY start_dt
        LIMIT 1
    """, (plane_id, new_start_dt, new_end_dt))

    return cur.fetchone()  # None if no conflict


def has_employee_conflict(cur, link_table, employee_id, new_start_dt, new_end_dt):
    """
    link_table: 'Pilots_in_flights' or 'Flight_attendants_in_flights'
    Returns True if employee has an overlapping flight window.
    """
    cur.execute(f"""
        SELECT 1
        FROM {link_table} lf
        JOIN Flight f ON f.flight_id = lf.flight_id
        JOIN Flight_route r ON r.route_id = f.route_id
        WHERE lf.employee_id = %s
          AND f.flight_status IN ('Scheduled', 'Full')
          AND (
            %s < DATE_ADD(TIMESTAMP(f.takeoff_date, f.takeoff_time), INTERVAL r.flight_duration MINUTE)
            AND
            %s > TIMESTAMP(f.takeoff_date, f.takeoff_time)
          )
        LIMIT 1
    """, (employee_id, new_start_dt, new_end_dt))
    return cur.fetchone() is not None

@app.route("/admin/add/flights", methods=["GET", "POST"])
def admin_add_flight():
    if not session.get("admin_employee_id"):
        return redirect(url_for("admin_login"))

    # -------------------------
    # GET dropdown data + maps
    # -------------------------
    with db_cursor() as cur:
        # Planes dropdown
        cur.execute("SELECT plane_id FROM Plane ORDER BY plane_id")
        planes = [r["plane_id"] for r in cur.fetchall()]

        # Routes dropdown (+ durations)
        cur.execute("""
            SELECT route_id, origin_airport, destination_airport, flight_duration
            FROM Flight_route
            ORDER BY route_id
        """)
        routes = cur.fetchall()

        # Logged-in admin details
        admin_id = session.get("admin_employee_id")
        cur.execute("""
            SELECT employee_id, employee_first_name, employee_last_name
            FROM Manager
            WHERE employee_id = %s
        """, (admin_id,))
        logged_admin = cur.fetchone()

        if not logged_admin:
            flash("Admin user not found. Please login again.", "error")
            session.pop("admin_employee_id", None)
            return redirect(url_for("admin_login"))

        # Cabin layouts for layout_map
        cur.execute("""
            SELECT plane_id, class_type, rows_num, columns_num
            FROM Cabin_class
        """)
        cc = cur.fetchall()

        # ALL crew
        cur.execute("""
            SELECT employee_id, employee_first_name, employee_last_name, long_flight_training
            FROM Pilot
            ORDER BY employee_first_name, employee_last_name
        """)
        all_pilots = cur.fetchall()

        cur.execute("""
            SELECT employee_id, employee_first_name, employee_last_name, long_flight_training
            FROM Flight_attendant
            ORDER BY employee_first_name, employee_last_name
        """)
        all_attendants = cur.fetchall()

    # Build layout_map: {plane_id: {class_type: {rows, cols}}}
    layout_map = {}
    for x in cc:
        pid = x["plane_id"]
        layout_map.setdefault(pid, {})
        layout_map[pid][x["class_type"]] = {
            "rows": int(x["rows_num"]),
            "cols": int(x["columns_num"])
        }

    # Build route_map: {route_id(str): duration(int minutes)}
    route_map = {str(r["route_id"]): int(r["flight_duration"]) for r in routes}

    # -------------------------
    # Helper: filter crew by long-flight rule
    # -------------------------
    def filter_crew_for_route(route_id_str: str):
        minutes = int(route_map.get(str(route_id_str), 0) or 0)
        is_long = minutes >= 360  # ✅ 6 hours or more

        if is_long:
            pilots_filtered = [p for p in all_pilots if int(p["long_flight_training"]) == 1]
            attendants_filtered = [a for a in all_attendants if int(a["long_flight_training"]) == 1]
        else:
            pilots_filtered = all_pilots
            attendants_filtered = all_attendants

        return pilots_filtered, attendants_filtered, is_long, minutes

    # -------------------------
    # GET: decide selected route & filter lists shown
    # -------------------------
    if routes:
        selected_route_id = request.args.get("route_id") or str(routes[0]["route_id"])
    else:
        selected_route_id = request.args.get("route_id") or ""

    pilots, attendants, is_long_flight, duration_minutes = filter_crew_for_route(selected_route_id)

    # -------------------------
    # POST: create flight
    # -------------------------
    if request.method == "POST":
        flight_id = request.form.get("flight_id", "").strip().upper()
        route_id = request.form.get("route_id", "").strip()          # confirm it's string
        plane_id = request.form.get("plane_id", "").strip().upper()
        manager_id = session.get("admin_employee_id")
        takeoff_date = request.form.get("takeoff_date", "").strip()
        takeoff_time = request.form.get("takeoff_time", "").strip()

        econ_price = request.form.get("econ_price", "").strip()
        bus_price  = request.form.get("bus_price", "").strip()

        # ✅ checkbox lists (NO CTRL needed)
        pilot_ids = request.form.getlist("pilot_ids")
        attendant_ids = request.form.getlist("attendant_ids")

        # Re-filter based on the route chosen in POST
        pilots, attendants, is_long_flight, duration_minutes = filter_crew_for_route(route_id)
        selected_route_id = str(route_id)

        def render_with_error(msg):
            flash(msg, "error")
            return render_template(
                "admin_add_flight.html",
                planes=planes,
                routes=routes,
                layout_map=layout_map,
                route_map=route_map,
                logged_admin=logged_admin,
                pilots=pilots,
                attendants=attendants,
                selected_route_id=selected_route_id,
                is_long_flight=is_long_flight
            )

        # Basic validation
        if not all([flight_id, route_id, plane_id, manager_id, takeoff_date, takeoff_time]):
            return render_with_error("Please fill in the required flight fields.")

        try:
            with db_cursor() as cur:
                # 0) Make sure flight_id does not already exist
                cur.execute("SELECT 1 FROM Flight WHERE flight_id = %s LIMIT 1", (flight_id,))
                if cur.fetchone():
                    return render_with_error(
                        f"Flight ID '{flight_id}' already exists. Please choose a different ID."
                    )

                # 0.5) Compute new flight window
                new_start_dt = datetime.strptime(f"{takeoff_date} {takeoff_time}", "%Y-%m-%d %H:%M")
                new_end_dt = new_start_dt + timedelta(minutes=int(duration_minutes))

                # (optional debug) confirm db
                cur.execute("SELECT DATABASE() AS db")
                print("DB in use:", (cur.fetchone() or {}).get("db"))

                # 1) Prevent plane overlap
                conflict = has_plane_conflict(cur, plane_id, new_start_dt, new_end_dt)
                if conflict:
                    return render_with_error(
                        f"Plane {plane_id} overlaps with flight {conflict['flight_id']} "
                        f"({conflict['start_dt']} → {conflict['end_dt']}, status={conflict['flight_status']})."
                    )

                # 2) Prevent crew overlap
                for pid in pilot_ids:
                    if has_employee_conflict(cur, "Pilots_in_flights", pid, new_start_dt, new_end_dt):
                        return render_with_error(f"Pilot {pid} already has an overlapping flight.")

                for aid in attendant_ids:
                    if has_employee_conflict(cur, "Flight_attendants_in_flights", aid, new_start_dt, new_end_dt):
                        return render_with_error(f"Flight attendant {aid} already has an overlapping flight.")

                # 3) Cabin layout (Economy required, Business optional)
                cur.execute("""
                    SELECT class_type, rows_num, columns_num
                    FROM Cabin_class
                    WHERE plane_id = %s
                """, (plane_id,))
                cabins = cur.fetchall()

                layout = {x["class_type"]: (int(x["rows_num"]), int(x["columns_num"])) for x in cabins}

                if "Economy" not in layout:
                    return render_with_error("This plane is missing Economy layout in Cabin_class.")

                has_business = "Business" in layout

                econ_rows, econ_cols = layout["Economy"]
                bus_rows = bus_cols = 0
                if has_business:
                    bus_rows, bus_cols = layout["Business"]

                # 4) Prices validation (Economy required, Business only if exists)
                if not econ_price:
                    return render_with_error("Please enter Economy price.")
                if has_business and not bus_price:
                    return render_with_error("Please enter Business price.")

                # 5) Insert Flight
                cur.execute("""
                    INSERT INTO Flight
                      (flight_id, route_id, plane_id, manager_id, takeoff_date, takeoff_time, flight_status)
                    VALUES (%s, %s, %s, %s, %s, %s, 'Scheduled')
                """, (flight_id, route_id, plane_id, manager_id, takeoff_date, takeoff_time))

                create_seats_for_flight(cur, flight_id, plane_id)

                # 6) Insert pricing
                cur.execute("""
                    INSERT INTO Flight_Class_Pricing (flight_id, plane_id, class_type, price)
                    VALUES (%s, %s, 'Economy', %s)
                """, (flight_id, plane_id, float(econ_price)))

                if has_business:
                    cur.execute("""
                        INSERT INTO Flight_Class_Pricing (flight_id, plane_id, class_type, price)
                        VALUES (%s, %s, 'Business', %s)
                    """, (flight_id, plane_id, float(bus_price)))

                # 8) Crew links (replace existing if retry)
                cur.execute("DELETE FROM Pilots_in_flights WHERE flight_id = %s", (flight_id,))
                cur.execute("DELETE FROM Flight_attendants_in_flights WHERE flight_id = %s", (flight_id,))

                for pid in pilot_ids:
                    cur.execute("""
                        INSERT INTO Pilots_in_flights (flight_id, employee_id)
                        VALUES (%s, %s)
                    """, (flight_id, pid))

                for aid in attendant_ids:
                    cur.execute("""
                        INSERT INTO Flight_attendants_in_flights (flight_id, employee_id)
                        VALUES (%s, %s)
                    """, (flight_id, aid))

            # ✅ ONLY if everything succeeded
            flash("Flight created successfully.", "success")
            return redirect(url_for("admin_flights"))

        except mysql.connector.Error as e:
            # Cleanup partial inserts (important with autocommit)
            try:
                with db_cursor() as cur2:
                    cur2.execute("DELETE FROM Seat WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Pilots_in_flights WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Flight_attendants_in_flights WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Flight_Class_Pricing WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Flight WHERE flight_id = %s", (flight_id,))
            except Exception:
                pass

            return render_with_error(f"Database error: {e.msg}")

        except Exception:
            # Catch-all
            try:
                with db_cursor() as cur2:
                    cur2.execute("DELETE FROM Seat WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Pilots_in_flights WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Flight_attendants_in_flights WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Flight_Class_Pricing WHERE flight_id = %s", (flight_id,))
                    cur2.execute("DELETE FROM Flight WHERE flight_id = %s", (flight_id,))
            except Exception:
                pass

            return render_with_error("Something went wrong while creating the flight.")

    # -------------------------
    # GET: render page
    # -------------------------
    return render_template(
        "admin_add_flight.html",
        planes=planes,
        routes=routes,
        layout_map=layout_map,
        route_map=route_map,
        logged_admin=logged_admin,
        pilots=pilots,
        attendants=attendants,
        selected_route_id=selected_route_id,
        is_long_flight=is_long_flight
    )

@app.route("/admin/flights/cancel/<flight_id>", methods=["POST"])
def admin_cancel_flight(flight_id):
    if not session.get("admin_employee_id"):
        return redirect(url_for("admin_login"))

    refresh_flight_statuses()

    flight_id = flight_id.strip().upper()
    admin_id = session.get("admin_employee_id")

    with db_cursor() as cur:
        # 1) Fetch flight details
        cur.execute("""
            SELECT flight_status, takeoff_date, takeoff_time, manager_id
            FROM Flight
            WHERE flight_id = %s
        """, (flight_id,))
        flight = cur.fetchone()

        if not flight:
            flash("Flight not found.", "error")
            return redirect(url_for("admin_flights"))

        # Only the assigned manager can cancel
        if str(flight["manager_id"]) != str(admin_id):
            flash("You can cancel only flights assigned to you.", "error")
            return redirect(url_for("admin_flights"))

        if flight["flight_status"] not in ("Scheduled", "Full"):
            flash("Only Scheduled/Full flights can be cancelled.", "error")
            return redirect(url_for("admin_flights"))

        # 2) 72h rule
        takeoff_t = normalize_time(flight["takeoff_time"])
        takeoff_dt = datetime.combine(flight["takeoff_date"], takeoff_t)
        if takeoff_dt - datetime.now() < timedelta(hours=72):
            flash("Too late to cancel: you can cancel only 72+ hours before takeoff.", "error")
            return redirect(url_for("admin_flights"))

        # 3) Mark flight cancelled
        cur.execute("""
            UPDATE Flight
            SET flight_status = 'Cancelled'
            WHERE flight_id = %s
        """, (flight_id,))

        # 4) Refund ALL paid orders (Active) in one shot
        # Compute totals per order_id from Seat + Flight_Class_Pricing
        cur.execute("""
            SELECT
              o.order_id,
              COALESCE(SUM(fcp.price), 0) AS total
            FROM Orders o
            LEFT JOIN Seat s
              ON s.order_id = o.order_id
            LEFT JOIN Flight_Class_Pricing fcp
              ON fcp.flight_id  = s.flight_id
             AND fcp.plane_id   = s.plane_id
             AND fcp.class_type = s.class_type
            WHERE o.flight_id = %s
              AND o.order_status = 'Active'
            GROUP BY o.order_id
        """, (flight_id,))
        paid_orders = cur.fetchall()  # list of {order_id, total}

        refunded_orders_count = len(paid_orders)
        total_refunded = sum(float(r["total"] or 0) for r in paid_orders)

        # Cancel paid orders
        cur.execute("""
            UPDATE Orders
            SET order_status = 'Cancelled by system'
            WHERE flight_id = %s
              AND order_status = 'Active'
        """, (flight_id,))

        # 5) Cancel pending reservations too (no "refund", but release seats)
        cur.execute("""
            UPDATE Orders
            SET order_status = 'Cancelled by system'
            WHERE flight_id = %s
              AND order_status = 'Pending'
        """, (flight_id,))

        # 6) Release seats for ANY order on this flight (paid/pending/whatever)
        # This prevents "stuck" seats.
        cur.execute("""
            UPDATE Seat s
            JOIN Orders o ON o.order_id = s.order_id
            SET s.order_id = NULL
            WHERE o.flight_id = %s
        """, (flight_id,))

        flash(
            f"Flight {flight_id} cancelled. "
            f"Refunded {refunded_orders_count} paid order(s), total ₪{total_refunded:.2f}.",
            "success"
        )

    return redirect(url_for("admin_flights"))

@app.route("/admin/dashboard")
def admin_dashboard():
    if not session.get("admin_employee_id"):
        return redirect(url_for("admin_login"))

    refresh_flight_statuses()

    with db_cursor() as cur:
        cur.execute("SELECT COUNT(*) AS n FROM Plane")
        planes_count = cur.fetchone()["n"]

        cur.execute("SELECT COUNT(*) AS n FROM Flight_route")
        routes_count = cur.fetchone()["n"]

        cur.execute("SELECT COUNT(*) AS n FROM Flight")
        flights_count = cur.fetchone()["n"]

        # --- cancellation rate per month (from your Query 4) ---
        cur.execute("""
            SELECT
              DATE_FORMAT(date_of_purchase, '%Y-%m') AS purchase_month,
              ROUND(
                100 * SUM(order_status = 'Cancelled by customer') / NULLIF(COUNT(*), 0),
                2
              ) AS customer_cancellation_rate
            FROM Orders
            GROUP BY purchase_month
            ORDER BY purchase_month;
        """)
        rows = cur.fetchall()

        # --- employee hours (Query 3) ---
        cur.execute("""
            WITH employee_flights AS (
              SELECT
                p.employee_id,
                fr.flight_duration
              FROM Pilot p
              LEFT JOIN Pilots_in_flights pf
                ON pf.employee_id = p.employee_id
              LEFT JOIN Flight f
                ON f.flight_id = pf.flight_id
               AND f.flight_status = 'Completed'
              LEFT JOIN Flight_route fr
                ON fr.route_id = f.route_id

              UNION ALL

              SELECT
                fa.employee_id,
                fr.flight_duration
              FROM Flight_attendant fa
              LEFT JOIN Flight_attendants_in_flights faf
                ON faf.employee_id = fa.employee_id
              LEFT JOIN Flight f
                ON f.flight_id = faf.flight_id
               AND f.flight_status = 'Completed'
              LEFT JOIN Flight_route fr
                ON fr.route_id = f.route_id
            )
            SELECT
              employee_id,
              ROUND(SUM(CASE WHEN flight_duration > 360 THEN flight_duration ELSE 0 END) / 60, 2) AS long_flight_hours,
              ROUND(SUM(CASE WHEN flight_duration <= 360 THEN flight_duration ELSE 0 END) / 60, 2) AS short_flight_hours
            FROM employee_flights
            GROUP BY employee_id
            ORDER BY employee_id;
        """)
        emp_rows = cur.fetchall()

        # --- flights by takeoff hour ---
        cur.execute("""
            SELECT
              HOUR(f.takeoff_time) AS takeoff_hour,
              COUNT(*) AS flights_count
            FROM Flight f
            WHERE
              TIMESTAMP(f.takeoff_date, f.takeoff_time) < NOW()
              AND f.flight_status IN ('Completed','Full')
            GROUP BY HOUR(f.takeoff_time)
            ORDER BY takeoff_hour;
        """)
        hour_rows = cur.fetchall()

        # --- flights completed per month ---
        cur.execute("""
            SELECT
              DATE_FORMAT(f.takeoff_date, '%Y-%m') AS month,
              COUNT(*) AS flights_completed
            FROM Flight f
            WHERE f.flight_status = 'Completed'
            GROUP BY month
            ORDER BY month;
        """)
        completed_rows = cur.fetchall()

        # --- top 5 routes by completed flights ---
        cur.execute("""
            SELECT
              CONCAT(fr.origin_airport, ' → ', fr.destination_airport) AS route,
              COUNT(*) AS flights_completed
            FROM Flight f
            JOIN Flight_route fr
              ON fr.route_id = f.route_id
            WHERE f.flight_status = 'Completed'
            GROUP BY route
            ORDER BY flights_completed DESC
            LIMIT 5;
        """)
        top5_rows = cur.fetchall()

    months = [r["purchase_month"] for r in rows]
    rates = [float(r["customer_cancellation_rate"] or 0) for r in rows]

    # save plot into static/
    static_dir = os.path.join(app.root_path, "static")
    os.makedirs(static_dir, exist_ok=True)
    plot_path = os.path.join(static_dir, "cancellation_rate_by_month.png")

    plt.figure(figsize=(8, 5))
    plt.plot(months, rates, marker="o")
    plt.title("Customer Cancellation Rate by Month")
    plt.xlabel("Purchase Month")
    plt.ylabel("Cancellation Rate (%)")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(plot_path, dpi=200, bbox_inches="tight")
    plt.close()

    df = pd.DataFrame(emp_rows)

    # If there are employees with no completed flights, the query can return NULLs -> make them 0
    df["long_flight_hours"] = df["long_flight_hours"].fillna(0).astype(float)
    df["short_flight_hours"] = df["short_flight_hours"].fillna(0).astype(float)

    df["total_hours"] = df["long_flight_hours"] + df["short_flight_hours"]
    df_plot = df.sort_values("total_hours", ascending=True)

    plt.figure(figsize=(10, max(3, 0.35 * len(df_plot))))

    plt.barh(
        df_plot["employee_id"].astype(str),
        df_plot["short_flight_hours"],
        label="Short flight hours"
    )

    plt.barh(
        df_plot["employee_id"].astype(str),
        df_plot["long_flight_hours"],
        left=df_plot["short_flight_hours"],
        label="Long flight hours"
    )

    plt.title("Flight Hours per Employee")
    plt.xlabel("Hours")
    plt.ylabel("Employee ID")
    plt.legend()
    plt.tight_layout()

    emp_plot_filename = f"employee_hours_{int(datetime.now().timestamp())}.png"
    emp_plot_path = os.path.join(static_dir, emp_plot_filename)

    plt.savefig(emp_plot_path, dpi=200, bbox_inches="tight")
    plt.close()

    df_hour = pd.DataFrame(hour_rows)

    # make sure types + order are correct (prevents the "categorical units" warning too)
    df_hour["takeoff_hour"] = df_hour["takeoff_hour"].astype(int)
    df_hour["flights_count"] = df_hour["flights_count"].astype(int)
    df_hour = df_hour.sort_values("takeoff_hour")

    plt.figure(figsize=(10, 5))

    # BAR chart (like your 2nd picture)
    plt.bar(df_hour["takeoff_hour"], df_hour["flights_count"], width=0.6)

    plt.title("Number of Flights by Takeoff Hour")
    plt.xlabel("Takeoff Hour")
    plt.ylabel("Number of Flights")
    plt.xticks(df_hour["takeoff_hour"])  # show only hours that exist (like screenshot)

    plt.tight_layout()

    hour_plot_filename = f"flights_by_takeoff_hour_{int(datetime.now().timestamp())}.png"
    hour_plot_path = os.path.join(static_dir, hour_plot_filename)

    plt.savefig(hour_plot_path, dpi=200, bbox_inches="tight")
    plt.close()

    df_completed = pd.DataFrame(completed_rows)

    df_completed["flights_completed"] = df_completed["flights_completed"].astype(int)

    # make sure sorted
    df_completed = df_completed.sort_values("month")

    plt.figure(figsize=(10, 5))
    plt.bar(
        df_completed["month"],
        df_completed["flights_completed"],
        width=0.5
    )

    plt.title("Flights Completed per Month")
    plt.xlabel("Month")
    plt.ylabel("Number of Flights Completed")
    plt.xticks(df_completed["month"], rotation=45)
    plt.tight_layout()

    completed_plot_filename = f"flights_completed_per_month_{int(datetime.now().timestamp())}.png"
    completed_plot_path = os.path.join(static_dir, completed_plot_filename)

    plt.savefig(completed_plot_path, dpi=200, bbox_inches="tight")
    plt.close()

    df_top5 = pd.DataFrame(top5_rows)

    df_top5["flights_completed"] = df_top5["flights_completed"].astype(int)

    # nicer: sort ascending so the biggest is on top
    df_top5 = df_top5.sort_values("flights_completed", ascending=True)

    plt.figure(figsize=(10, 4))
    plt.barh(
        df_top5["route"],
        df_top5["flights_completed"],
        height=0.5
    )

    plt.title("Top 5 Routes by Completed Flights")
    plt.xlabel("Number of Completed Flights")
    plt.ylabel("Route")

    ax = plt.gca()
    ax.xaxis.set_major_locator(ticker.MaxNLocator(integer=True))

    plt.tight_layout()

    top5_plot_filename = f"top5_routes_completed_{int(datetime.now().timestamp())}.png"
    top5_plot_path = os.path.join(static_dir, top5_plot_filename)

    plt.savefig(top5_plot_path, dpi=200, bbox_inches="tight")
    plt.close()

    return render_template(
        "admin_dashboard.html",
        planes_count=planes_count,
        routes_count=routes_count,
        flights_count=flights_count,
        cancel_plot="cancellation_rate_by_month.png",
        employee_hours_plot = emp_plot_filename,
        flights_by_hour_plot=hour_plot_filename,
        flights_completed_plot=completed_plot_filename,
        top5_routes_plot=top5_plot_filename
    )

@app.route("/admin/add/employees", methods=["GET", "POST"])
def admin_add_employee():
    if not session.get("admin_employee_id"):
        return redirect(url_for("admin_login"))

    form = {
        "employee_id": "",
        "first_name": "",
        "last_name": "",
        "phone": "",
        "city": "",
        "street": "",
        "street_num": "",
        "employment_date": "",
        "job_title": "Pilot",
        "long_flight_training": False,
    }

    if request.method == "POST":
        employee_id = request.form.get("employee_id", "").strip()
        first_name = request.form.get("first_name", "").strip()
        last_name = request.form.get("last_name", "").strip()
        phone = normalize_phone(request.form.get("phone", ""))
        city = request.form.get("city", "").strip()
        street = request.form.get("street", "").strip()
        street_num_raw = request.form.get("street_num", "").strip()
        employment_date_raw = request.form.get("employment_date", "").strip()
        job_title = request.form.get("job_title", "").strip()

        # ✅ Checkbox: if checked it exists, if not checked it's missing
        long_flight_training = 1 if request.form.get("long_flight_training") else 0

        form.update({
            "employee_id": employee_id,
            "first_name": first_name,
            "last_name": last_name,
            "phone": phone,
            "city": city,
            "street": street,
            "street_num": street_num_raw,
            "employment_date": employment_date_raw,
            "job_title": job_title,
            "long_flight_training": (long_flight_training == 1),
        })

        if not all([employee_id, first_name, last_name, phone, city, street, street_num_raw, employment_date_raw, job_title]):
            flash("Please fill in all fields.", "error")
            return render_template("admin_add_employee.html", form=form)

        if job_title not in ("Pilot", "Flight_attendant"):
            flash("Please choose a valid job title.", "error")
            return render_template("admin_add_employee.html", form=form)

        if len(employee_id) != 9 or not employee_id.isdigit():
            flash("Employee ID must be exactly 9 digits.", "error")
            return render_template("admin_add_employee.html", form=form)

        if not is_valid_phone(phone):
            flash("Phone number can contain only digits and '-'.", "error")
            return render_template("admin_add_employee.html", form=form)

        try:
            street_num = int(street_num_raw)
            if street_num <= 0:
                raise ValueError()
        except ValueError:
            flash("Street number must be a positive integer.", "error")
            return render_template("admin_add_employee.html", form=form)

        try:
            emp_date = datetime.strptime(employment_date_raw, "%Y-%m-%d").date()
        except ValueError:
            flash("Employment date must be a valid date (YYYY-MM-DD).", "error")
            return render_template("admin_add_employee.html", form=form)

        if emp_date < date(1900, 1, 1) or emp_date > date.today():
            flash("Employment date must be between 1900-01-01 and today.", "error")
            return render_template("admin_add_employee.html", form=form)

        try:
            with db_cursor() as cur:
                # prevent duplicates in all employee tables
                cur.execute("SELECT 1 FROM Manager WHERE employee_id = %s", (employee_id,))
                if cur.fetchone():
                    flash("That employee ID already exists (Manager).", "error")
                    return render_template("admin_add_employee.html", form=form)

                cur.execute("SELECT 1 FROM Pilot WHERE employee_id = %s", (employee_id,))
                if cur.fetchone():
                    flash("That employee ID already exists (Pilot).", "error")
                    return render_template("admin_add_employee.html", form=form)

                cur.execute("SELECT 1 FROM Flight_attendant WHERE employee_id = %s", (employee_id,))
                if cur.fetchone():
                    flash("That employee ID already exists (Flight Attendant).", "error")
                    return render_template("admin_add_employee.html", form=form)

                if job_title == "Pilot":
                    cur.execute("""
                        INSERT INTO Pilot
                          (employee_id, employee_first_name, employee_last_name,
                           employee_phone, employee_city, employee_street, employee_street_num,
                           employment_date, long_flight_training)
                        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
                    """, (
                        employee_id, first_name, last_name,
                        phone, city, street, street_num,
                        emp_date, long_flight_training
                    ))
                else:
                    cur.execute("""
                        INSERT INTO Flight_attendant
                          (employee_id, employee_first_name, employee_last_name,
                           employee_phone, employee_city, employee_street, employee_street_num,
                           employment_date, long_flight_training)
                        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
                    """, (
                        employee_id, first_name, last_name,
                        phone, city, street, street_num,
                        emp_date, long_flight_training
                    ))

            flash(f"Employee added successfully ({job_title.replace('_', ' ')}).", "success")
            return redirect(url_for("admin_dashboard"))

        except Exception:
            flash("Failed to add employee. Please try again.", "error")
            return render_template("admin_add_employee.html", form=form)

    return render_template("admin_add_employee.html", form=form)


@app.route("/admin/logout", methods=["POST"])
def admin_logout():
    session.pop("admin_employee_id", None)
    session.pop("admin_name", None)
    flash("You were logged out", "success")
    return redirect(url_for("home"))

@app.route("/ping")
def ping():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}

if __name__ == "__main__":
    app.run(debug=True)