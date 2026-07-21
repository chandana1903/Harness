"""Unit tests for Flask app"""

import pytest
from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_home(client):
    response = client.get("/")
    data = response.get_json()
    assert response.status_code == 200
    assert data["message"] == "Hello from Harness CI/CD Course!"
    assert data["episode"] == 2


def test_health(client):
    response = client.get("/health")
    data = response.get_json()
    assert response.status_code == 200
    assert data["status"] == "healthy"


def test_info(client):
    response = client.get("/info")
    data = response.get_json()
    assert response.status_code == 200
    assert data["app"] == "Harness Course Python App"
    assert data["language"] == "Python"
