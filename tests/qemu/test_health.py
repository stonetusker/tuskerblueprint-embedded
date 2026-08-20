import pytest

pytestmark = pytest.mark.integration

from conftest import get_json


def test_health(device_url):
    status, body = get_json(f"{device_url}/health")
    assert status == 200
    assert body["status"] == "healthy"
    assert body["application_version"]
    assert body["image_version"]
    assert body["device_id"]
