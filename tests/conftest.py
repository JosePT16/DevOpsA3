import pytest

from app import create_app


@pytest.fixture()
def client(tmp_path, monkeypatch):
    """
    Creates a Flask test client with an isolated SQLite DB file.
    """
    test_db = tmp_path / "test.db"
    monkeypatch.setenv("SQLITE_DB_PATH", str(test_db))

    app = create_app(testing=True)
    with app.test_client() as client:
        yield client
