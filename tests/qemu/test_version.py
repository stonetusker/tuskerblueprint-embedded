import pytest

pytestmark = pytest.mark.integration

import os
from conftest import get_json


def test_version(device_url):
    status, body = get_json(f"{device_url}/version")
    assert status == 200
    expected = os.getenv("EXPECTED_IMAGE_VERSION")
    if expected:
        assert body["image_version"] == expected
    assert body["image_version"] != "unknown"
    expected_device = os.getenv("EXPECTED_DEVICE_ID")
    if expected_device:
        assert body["device_id"] == expected_device
