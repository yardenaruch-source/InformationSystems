import mysql.connector
from contextlib import contextmanager

@contextmanager
def db_cursor():
    connection = mysql.connector.connect(
        host="yardenaruch.mysql.pythonanywhere-services.com",
        user="yardenaruch",
        password="ily3hap3",
        database="yardenaruch$FLYTAUdb",
        autocommit=False,   # ✅ IMPORTANT: allow rollback
    )

    cursor = connection.cursor(dictionary=True)
    try:
        yield cursor
        connection.commit()     # ✅ commit only if no exception happened
    except Exception:
        connection.rollback()   # ✅ undo partial inserts if something failed
        raise                   # ✅ re-raise so your route can show the error
    finally:
        cursor.close()
        connection.close()
