# Compatibility-controlled Mender configuration.
# The exact variables/classes are validated against the selected meta-mender revision in Phase 0.
MENDER_ARTIFACT_NAME ?= "${SENSORNODE_IMAGE_VERSION}"
MENDER_DEVICE_TYPE ?= "qemuarm64-sensornode"
MENDER_SERVER_URL ?= "https://mender.example.invalid"
MENDER_TENANT_TOKEN ?= ""

# Conservative reference sizes for QEMU. Validate against the generated image and selected integration.
MENDER_STORAGE_TOTAL_SIZE_MB ?= "2048"
MENDER_BOOT_PART_SIZE_MB ?= "64"
MENDER_DATA_PART_SIZE_MB ?= "256"
