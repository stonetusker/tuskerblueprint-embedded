SUMMARY = "SensorNode Mender client configuration and health scripts"
LICENSE = "CLOSED"

SRC_URI = " \
    file://mender.conf.in \
    file://ArtifactCommit_Enter_50_sensornode-health \
    file://mender-device-identity \
"

S = "${WORKDIR}"
MENDER_SERVER_URL ?= "https://mender.example.invalid"

do_install() {
    install -d ${D}${sysconfdir}/mender/scripts ${D}${datadir}/mender/identity
    install -m 0644 ${WORKDIR}/mender.conf.in ${D}${sysconfdir}/mender/mender.conf
    sed -i 's|@MENDER_SERVER_URL@|${MENDER_SERVER_URL}|g' ${D}${sysconfdir}/mender/mender.conf
    install -m 0755 ${WORKDIR}/ArtifactCommit_Enter_50_sensornode-health ${D}${sysconfdir}/mender/scripts/
    install -m 0755 ${WORKDIR}/mender-device-identity ${D}${datadir}/mender/identity/mender-device-identity
}

FILES:${PN} += "${sysconfdir}/mender"
CONFFILES:${PN} += "${sysconfdir}/mender/mender.conf"
