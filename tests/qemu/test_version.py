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
