require sensornode-image.inc
SUMMARY = "Hardened SensorNode release image"

IMAGE_FEATURES:remove = "debug-tweaks ssh-server-openssh"
inherit extrausers
EXTRA_USERS_PARAMS = "usermod -L root;"

# Read-only-rootfs can be enabled after Mender and application state paths are verified.
# IMAGE_FEATURES:append = " read-only-rootfs"
