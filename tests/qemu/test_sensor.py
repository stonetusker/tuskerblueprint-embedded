import pytest

pytestmark = pytest.mark.integration

from conftest import get_json


def test_sensor_sequence(device_url):
    _, first = get_json(f"{device_url}/sensor")
    _, second = get_json(f"{device_url}/sensor")
    assert second["sequence"] == first["sequence"] + 1
    assert second["unit"] == "celsius"
