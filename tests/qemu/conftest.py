import json
import os
import time
import urllib.error
import urllib.request

import pytest


@pytest.fixture(scope="session")
def device_url():
    return os.getenv("SENSORNODE_URL", "http://127.0.0.1:8081").rstrip("/")


def get_json(url: str, timeout: float = 5.0):
    with urllib.request.urlopen(url, timeout=timeout) as response:
        return response.status, json.load(response)


@pytest.fixture(scope="session", autouse=True)
def wait_for_device(device_url):
    deadline = time.monotonic() + int(os.getenv("SENSORNODE_READY_TIMEOUT", "180"))
    while time.monotonic() < deadline:
        try:
            status, body = get_json(f"{device_url}/health", 2.0)
            if status == 200 and body.get("status") == "healthy":
                return
        except (OSError, urllib.error.URLError, json.JSONDecodeError):
            pass
        time.sleep(2)
    pytest.fail(f"SensorNode did not become healthy: {device_url}")
