SUMMARY = "Common SensorNode embedded Linux image"
LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL:append = " packagegroup-sensornode"
IMAGE_LINGUAS = ""
NO_RECOMMENDATIONS ?= "1"

# Generate ext4 and QEMU-friendly outputs. Mender configuration adds its required image type.
IMAGE_FSTYPES:append = " ext4 tar.bz2"
IMAGE_ROOTFS_EXTRA_SPACE = "131072"

# Controlled failure modes are an image property so a broken candidate can be
# built from the same packages as the healthy one (see mender/demo-scenarios/).
SENSORNODE_FAILURE_MODE ?= "none"
ROOTFS_POSTPROCESS_COMMAND += "sensornode_set_failure_mode"
sensornode_set_failure_mode() {
    sed -i -e 's/^SENSORNODE_FAILURE_MODE=.*/SENSORNODE_FAILURE_MODE=${SENSORNODE_FAILURE_MODE}/' \
        ${IMAGE_ROOTFS}${sysconfdir}/default/sensornode
}
