from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.case import OERuntimeTestCase


class SensorNodeRuntimeTest(OERuntimeTestCase):
    @OETestDepends(["ssh.SSHTest.test_ssh"])
    def test_01_service_active(self):
        status, output = self.target.run("systemctl is-active sensornode.service")
        self.assertEqual(status, 0, msg=output)
        self.assertEqual(output.strip(), "active")

    @OETestDepends(["sensornode.SensorNodeRuntimeTest.test_01_service_active"])
    def test_02_health_endpoint(self):
        command = "curl --fail --silent http://127.0.0.1:8080/health | jq -e '.status == \"healthy\"'"
        status, output = self.target.run(command)
        self.assertEqual(status, 0, msg=output)

    @OETestDepends(["sensornode.SensorNodeRuntimeTest.test_02_health_endpoint"])
    def test_03_version_identity(self):
        command = "test \"$(curl --fail --silent http://127.0.0.1:8080/version | jq -r .image_version)\" = \"$(cat /etc/sensornode/image-version)\""
        status, output = self.target.run(command)
        self.assertEqual(status, 0, msg=output)

    @OETestDepends(["sensornode.SensorNodeRuntimeTest.test_01_service_active"])
    def test_04_no_failed_mandatory_units(self):
        command = "systemctl --failed --no-legend --plain | grep -Ev '(^$|systemd-networkd-wait-online)'"
        status, output = self.target.run(command)
        self.assertNotEqual(status, 0, msg="failed units detected: %s" % output)
