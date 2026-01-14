from contextlib import contextmanager

@contextmanager
def db_cursor():
    raise RuntimeError("DB credentials are configured on PythonAnywhere only.")
    yield