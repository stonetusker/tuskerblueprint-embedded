require sensornode-image.inc
SUMMARY = "SensorNode developer image"
IMAGE_FEATURES:append = " debug-tweaks tools-debug tools-profile ssh-server-openssh"
IMAGE_INSTALL:append = " bash strace tcpdump vim"
