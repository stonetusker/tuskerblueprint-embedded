require sensornode-image.inc
SUMMARY = "SensorNode CI image with runtime test support"
IMAGE_FEATURES:append = " debug-tweaks ssh-server-openssh"

IMAGE_CLASSES += "testimage"
TEST_SUITES = "ping ssh systemd sensornode"
TESTIMAGE_AUTO:qemuall = "0"
