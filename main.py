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
    # Where to go after login (e.g. /seats/LY482?class_type=Economy)
    next_url = request.args.get("next") or request.form.get("next")

    # If already logged in, go to next (if provided) or home
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
        flash(f"Welcome back, {user['customer_first_name']}!", "success")

        # Redirect to the page they originally wanted
        return redirect(next_url or url_for("home"))

    # GET request: show login page (also pass next so template can include it)
    return render_template("login.html", next=next_url)

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

@app.route("/booking/<flight_id>/guest", methods=["GET", "POST"])
def guest_details(flight_id):
    flight_id = flight_id.strip().upper()

    # after guest details, continue to the flight page (then seats)
    next_url = request.args.get("next") or url_for("flight_details", flight_id=flight_id)

    # used to re-fill the form if there is an error
    form = {"email": "", "full_name": "", "passport_id": "", "phones": []}

    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        full_name = request.form.get("full_name", "").strip()
        passport_id = request.form.get("passport_id", "").strip()  # collected but NOT saved
        phones = [p.strip() for p in request.form.getlist("phone") if p.strip()]

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

        # If email belongs to registered customer -> show message then redirect to login
        with db_cursor() as cur:
            cur.execute("SELECT 1 FROM Registered_customer WHERE customer_email = %s", (email,))
            exists = cur.fetchone() is not None

        if exists:
            login_redirect_url = url_for("login", next=next_url)
            return render_template(
                "guest_details.html",
                flight_id=flight_id,
                next_url=next_url,
                form=form,
                registered_customer=True,
                login_redirect_url=login_redirect_url
            )

        # split full name to first/last for Guest table
        parts = full_name.split()
        first_name = parts[0]
        last_name = " ".join(parts[1:]) if len(parts) > 1 else ""

        # Save ONLY: email + first_name + last_name + phones (NOT passport)
        with db_cursor() as cur:
            # IMPORTANT: replace column names to match your table if different
            # This assumes: Guest(guest_email PK, guest_first_name, guest_last_name)
            cur.execute("""
                INSERT INTO Guest (guest_email, guest_first_name, guest_last_name)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE
                  guest_first_name = VALUES(guest_first_name),
                  guest_last_name  = VALUES(guest_last_name)
            """, (email, first_name, last_name))

            # replace phones for that guest
            # This assumes: Guest_phone(guest_email, guest_phone)
            cur.execute("DELETE FROM Guest_phone WHERE guest_email = %s", (email,))
            for ph in phones:
                cur.execute("""
                    INSERT INTO Guest_phone (guest_email, guest_phone)
                    VALUES (%s, %s)
                """, (email, ph))

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

@app.route("/cancel/<order_id>", methods=["POST"])
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

@app.route("/admin", methods=["GET"])
def admin():
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
        cur.execute("SELECT COUNT(*) AS n FROM Plane")
        planes_count = cur.fetchone()["n"]

        cur.execute("SELECT COUNT(*) AS n FROM Flight_route")
        routes_count = cur.fetchone()["n"]

        cur.execute("SELECT COUNT(*) AS n FROM Flight")
        flights_count = cur.fetchone()["n"]

        cur.execute("""
            SELECT
              f.flight_id, f.takeoff_date, f.takeoff_time, f.flight_status,
              r.origin_airport, r.destination_airport,
              f.plane_id, f.manager_id
            FROM Flight f
            JOIN Flight_route r ON r.route_id = f.route_id
            {where_sql}
            ORDER BY f.takeoff_date DESC, f.takeoff_time DESC
            LIMIT 200
        """.format(where_sql=where_sql), tuple(params))
        flights = cur.fetchall()

    return render_template(
        "admin.html",
        flights=flights,
        planes_count=planes_count,
        routes_count=routes_count,
        flights_count=flights_count,
        filters={"flight_id": flight_id, "status": status, "takeoff_date": takeoff_date},
    )


@app.route("/admin/add/plane", methods=["GET", "POST"])
def admin_add_plane():
    if request.method == "POST":
        plane_id = request.form.get("plane_id", "").strip().upper()
        plane_size = request.form.get("plane_size", "").strip()
        plane_manufacturer = request.form.get("plane_manufacturer", "").strip()
        purchase_date = request.form.get("purchase_date", "").strip()

        if not all([plane_id, plane_size, plane_manufacturer, purchase_date]):
            flash("Please fill in all fields.", "error")
            return render_template("admin_plane_new.html")

        with db_cursor() as cur:
            cur.execute("""
                INSERT INTO Plane (plane_id, plane_size, plane_manufacturer, purchase_date)
                VALUES (%s, %s, %s, %s)
            """, (plane_id, plane_size, plane_manufacturer, purchase_date))

        flash("Plane added successfully.", "success")
        return redirect(url_for("admin"))

    return render_template("admin_plane_new.html")


@app.route("/admin/add/route", methods=["GET", "POST"])
def admin_add_route():
    if request.method == "POST":
        route_id = request.form.get("route_id", "").strip()
        origin = request.form.get("origin_airport", "").strip().upper()
        dest = request.form.get("destination_airport", "").strip().upper()
        duration = request.form.get("flight_duration", "").strip()

        if not all([route_id, origin, dest, duration]):
            flash("Please fill in all fields.", "error")
            return render_template("admin_route_new.html")

        with db_cursor() as cur:
            cur.execute("""
                INSERT INTO Flight_route (route_id, origin_airport, destination_airport, flight_duration)
                VALUES (%s, %s, %s, %s)
            """, (route_id, origin, dest, duration))

        flash("Route added successfully.", "success")
        return redirect(url_for("admin"))

    return render_template("admin_route_new.html")


@app.route("/admin/add/flights", methods=["GET", "POST"])
def admin_add_flight():
    # GET: show dropdowns for planes/routes/managers
    with db_cursor() as cur:
        cur.execute("SELECT plane_id FROM Plane ORDER BY plane_id")
        planes = [r["plane_id"] for r in cur.fetchall()]

        cur.execute("""
            SELECT route_id, origin_airport, destination_airport
            FROM Flight_route
            ORDER BY route_id
        """)
        routes = cur.fetchall()

        cur.execute("""
            SELECT employee_id, employee_first_name, employee_last_name
            FROM Manager
            ORDER BY employee_id
        """)
        managers = cur.fetchall()

    if request.method == "POST":
        flight_id = request.form.get("flight_id", "").strip().upper()
        route_id = request.form.get("route_id", "").strip()
        plane_id = request.form.get("plane_id", "").strip().upper()
        manager_id = request.form.get("manager_id", "").strip()
        takeoff_date = request.form.get("takeoff_date", "").strip()
        takeoff_time = request.form.get("takeoff_time", "").strip()

        # optional: auto-create cabin & seats
        econ_price = request.form.get("econ_price", "").strip()
        bus_price = request.form.get("bus_price", "").strip()
        econ_rows = request.form.get("econ_rows", "").strip()
        econ_cols = request.form.get("econ_cols", "").strip()
        bus_rows = request.form.get("bus_rows", "").strip()
        bus_cols = request.form.get("bus_cols", "").strip()

        if not all([flight_id, route_id, plane_id, manager_id, takeoff_date, takeoff_time]):
            flash("Please fill in the required flight fields.", "error")
            return render_template("admin_flight_new.html", planes=planes, routes=routes, managers=managers)

        with db_cursor() as cur:
            cur.execute("""
                INSERT INTO Flight (flight_id, route_id, plane_id, manager_id, takeoff_date, takeoff_time, flight_status)
                VALUES (%s, %s, %s, %s, %s, %s, 'Scheduled')
            """, (flight_id, route_id, plane_id, manager_id, takeoff_date, takeoff_time))

            # If cabin fields provided, try to create cabin classes + seats
            auto_ok = all([econ_price, bus_price, econ_rows, econ_cols, bus_rows, bus_cols])
            if auto_ok:
                # NOTE: This assumes your Cabin_class is per-flight (recommended).
                # If your DB is still (plane_id, class_type) PK, this will need adjustment.
                cur.execute("""
                    INSERT INTO Cabin_class (flight_id, class_type, plane_id, columns_num, rows_num, price)
                    VALUES (%s, 'Economy', %s, %s, %s, %s)
                """, (flight_id, plane_id, int(econ_cols), int(econ_rows), float(econ_price)))

                cur.execute("""
                    INSERT INTO Cabin_class (flight_id, class_type, plane_id, columns_num, rows_num, price)
                    VALUES (%s, 'Business', %s, %s, %s, %s)
                """, (flight_id, plane_id, int(bus_cols), int(bus_rows), float(bus_price)))

                # Seats: Economy
                for r in range(1, int(econ_rows) + 1):
                    for c in range(1, int(econ_cols) + 1):
                        cur.execute("""
                            INSERT INTO Seat (flight_id, class_type, s_row, s_column, order_id)
                            VALUES (%s, 'Economy', %s, %s, NULL)
                        """, (flight_id, r, c))

                # Seats: Business
                for r in range(1, int(bus_rows) + 1):
                    for c in range(1, int(bus_cols) + 1):
                        cur.execute("""
                            INSERT INTO Seat (flight_id, class_type, s_row, s_column, order_id)
                            VALUES (%s, 'Business', %s, %s, NULL)
                        """, (flight_id, r, c))

        flash("Flight created successfully.", "success")
        return redirect(url_for("admin"))

    return render_template("admin_flight_new.html", planes=planes, routes=routes, managers=managers)


@app.route("/admin/flights/cancel/<flight_id>", methods=["POST"])
def admin_cancel_flight(flight_id):
    flight_id = flight_id.strip().upper()
    with db_cursor() as cur:
        cur.execute("""
            UPDATE Flight
            SET flight_status = 'Cancelled'
            WHERE flight_id = %s
        """, (flight_id,))
        if cur.rowcount != 1:
            flash("Flight not found.", "error")
        else:
            flash("Flight cancelled.", "success")
    return redirect(url_for("admin"))

@app.route("/ping")
def ping():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}

if __name__ == "__main__":
    app.run(debug=True)

