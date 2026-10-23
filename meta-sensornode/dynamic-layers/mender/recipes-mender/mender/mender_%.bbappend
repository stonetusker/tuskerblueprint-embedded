FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://mender-device-identity"

# Replace the upstream MAC-only identity with the SensorNode device identity.
do_install:append() {
    install -m 0755 ${WORKDIR}/mender-device-identity ${D}${datadir}/mender/identity/mender-device-identity
}
