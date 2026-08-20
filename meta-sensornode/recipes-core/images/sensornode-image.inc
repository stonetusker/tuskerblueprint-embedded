SUMMARY = "Common SensorNode embedded Linux image"
LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL:append = " packagegroup-sensornode"
IMAGE_LINGUAS = ""
NO_RECOMMENDATIONS ?= "1"

# Generate ext4 and QEMU-friendly outputs. Mender configuration adds its required image type.
IMAGE_FSTYPES:append = " ext4 tar.bz2"
IMAGE_ROOTFS_EXTRA_SPACE = "131072"

