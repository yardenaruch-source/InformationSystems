import mysql.connector
from contextlib import contextmanager

@contextmanager
def db_cursor():
    connection = mysql.connector.connect(
        host="yardenaruch.mysql.pythonanywhere-services.com",
        user="yardenaruch",
        password="ily3hap3",
        database="yardenaruch$FLYTAUdb",
        autocommit=True
    )
    try:
        cursor = connection.cursor(dictionary=True)
        yield cursor
    finally:
        cursor.close()
        connection.close()