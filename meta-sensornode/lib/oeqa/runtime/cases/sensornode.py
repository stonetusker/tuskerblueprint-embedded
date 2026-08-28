import time
from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends

class SensorNodeRuntimeTest(OERuntimeTestCase):

    def test_01_service_active(self):
        max_retries = 10
        status = -1
        output = ""
        for _ in range(max_retries):
            status, output = self.target.run("systemctl is-active sensornode")
            if status == 0 and output.strip() == "active":
                break
            time.sleep(1)
        self.assertEqual(status, 0, msg=f"Service status: {output}")

    @OETestDepends(['sensornode.SensorNodeRuntimeTest.test_01_service_active'])
    def test_02_health_endpoint(self):
        status, output = self.target.run("curl -sf http://127.0.0.1:8080/health || /usr/bin/sensornode-healthcheck.sh")
        self.assertEqual(status, 0, msg=output)

    @OETestDepends(['sensornode.SensorNodeRuntimeTest.test_02_health_endpoint'])
    def test_03_version_identity(self):
        status, output = self.target.run("test -f /etc/sensornode-release")
        self.assertEqual(status, 0, msg=output)

    @OETestDepends(['sensornode.SensorNodeRuntimeTest.test_01_service_active'])
    def test_04_no_failed_mandatory_units(self):
        status, output = self.target.run("systemctl --failed --no-legend --plain")
        self.assertNotIn("sensornode.service", output, msg="sensornode.service is in failed state")
