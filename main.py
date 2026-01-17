from flask import Flask, render_template, request, redirect, url_for, session, flash
from utils import db_cursor
from datetime import datetime, date, timedelta

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
                JOIN Flight_route r ON r.route_id = f.route_id
                JOIN Cabin_class cc ON cc.flight_id = f.flight_id
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
            SELECT class_type, price, rows_num, columns_num
            FROM Cabin_class
            WHERE flight_id = %s
            ORDER BY class_type
        """, (flight_id,))
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
        cur.execute("""
            SELECT order_id
            FROM Orders
            WHERE order_status = 'Pending'
              AND date_of_purchase < (NOW() - INTERVAL 15 MINUTE)
        """)
        old_orders = [r["order_id"] for r in cur.fetchall()]

        for oid in old_orders:
            cur.execute("UPDATE Seat SET order_id = NULL WHERE order_id = %s", (oid,))
            cur.execute("""
                UPDATE Orders
                SET order_status = 'Cancelled by system'
                WHERE order_id = %s
            """, (oid,))

@app.route("/seats/<flight_id>", methods=["GET", "POST"])
def seats(flight_id):
    class_type = request.args.get("class_type") or request.form.get("class_type")

    cleanup_expired_pending_orders()

    if class_type not in ("Economy", "Business"):
        flash("Invalid class type.", "error")
        return redirect(url_for("flight_details", flight_id=flight_id))

    with db_cursor() as cur:
        # get cabin dimensions + price
        cur.execute("""
            SELECT rows_num, columns_num, price
            FROM Cabin_class
            WHERE flight_id = %s AND class_type = %s
        """, (flight_id, class_type))
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
                    # Guest order (must store guest_email)
                    guest_email = request.form.get("guest_email", "").strip().lower()
                    if not guest_email:
                        flash("Guest email is required.", "error")
                        # Stop here so we don't reserve seats without an order
                        return redirect(url_for("seats", flight_id=flight_id, class_type=class_type))

                    cur.execute("""
                        INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
                        VALUES (%s, %s, %s, %s, NOW(), 'Pending')
                    """, (oid, flight_id, guest_email, None))

                # try to reserve seats (only if still free)
                ok = True
                for s in selected:
                    r, c = s.split("-")
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
    cleanup_expired_pending_orders()

    if request.method == "POST":
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

        flash("Payment confirmed. Order is now active!", "success")
        return redirect(url_for("checkout", order_id=order_id))

    with db_cursor() as cur:
        cur.execute("""
            SELECT o.order_id, o.flight_id, o.date_of_purchase, o.order_status,
                   f.takeoff_date, f.takeoff_time, r.origin_airport, r.destination_airport
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
            SELECT SUM(cc.price) AS total
            FROM Seat s
            JOIN Cabin_class cc
              ON cc.flight_id = s.flight_id AND cc.class_type = s.class_type
            WHERE s.order_id = %s
        """, (order_id,))
        total = (cur.fetchone() or {}).get("total") or 0

    return render_template("checkout.html", order=order, seats=seats, total=total)

@app.route("/tickets", methods=["GET", "POST"])
def tickets():
    cleanup_expired_pending_orders()

    order = None
    seats = []
    total = 0
    can_cancel = False

    if request.method == "POST":
        order_id = request.form.get("order_id", "").strip()
        email = request.form.get("email", "").strip().lower()

        with db_cursor() as cur:
            cur.execute("""
                SELECT o.order_id, o.flight_id, o.order_status,
                       f.takeoff_date, f.takeoff_time,
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
                SELECT SUM(cc.price) AS total
                FROM Seat s
                JOIN Cabin_class cc
                  ON cc.flight_id = s.flight_id AND cc.class_type = s.class_type
                WHERE s.order_id = %s
            """, (order_id,))
            total = (cur.fetchone() or {}).get("total") or 0

        # cancel eligibility: > 36 hours before takeoff and status Active
        try:
            takeoff_dt = datetime.combine(order["takeoff_date"], order["takeoff_time"])
            can_cancel = (order["order_status"] == "Active") and (takeoff_dt - datetime.now() > timedelta(hours=36))
        except Exception:
            can_cancel = False

    return render_template("tickets.html", order=order, seats=seats, total=total, can_cancel=can_cancel)

@app.route("/cancel/<order_id>")
def cancel_order(order_id):
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

        takeoff_dt = datetime.combine(order["takeoff_date"], order["takeoff_time"])
        if takeoff_dt - datetime.now() <= timedelta(hours=36):
            flash("Too late to cancel (must be more than 36 hours before takeoff).", "error")
            return redirect(url_for("tickets"))

        # apply cancellation: update status + release seats
        cur.execute("UPDATE Orders SET order_status = 'Cancelled by customer' WHERE order_id = %s", (order_id,))
        cur.execute("UPDATE Seat SET order_id = NULL WHERE order_id = %s", (order_id,))

        flash("Order cancelled. A 5% cancellation fee applies.", "success")

    return redirect(url_for("tickets"))

@app.route("/ping")
def ping():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}

if __name__ == "__main__":
    app.run(debug=True)

