SUMMARY = "SensorNode Mender client configuration and health scripts"
LICENSE = "CLOSED"

SRC_URI = " \
    file://mender.conf.in \
    file://server.crt \
    file://ArtifactCommit_Enter_50_sensornode-health \
    file://mender-device-identity \
"

S = "${WORKDIR}"

MENDER_SERVER_URL ?= "https://docker.mender.io"
MENDER_SERVER_HOST_IP ?= "10.0.2.2"

do_install() {
    install -d ${D}${sysconfdir}/mender/scripts ${D}${datadir}/mender/identity
    
    # Configuration and server certificate
    install -m 0644 ${WORKDIR}/mender.conf.in ${D}${sysconfdir}/mender/mender.conf
    sed -i 's|@MENDER_SERVER_URL@|${MENDER_SERVER_URL}|g' ${D}${sysconfdir}/mender/mender.conf
    install -m 0644 ${WORKDIR}/server.crt ${D}${sysconfdir}/mender/server.crt

    # State scripts and identity
    install -m 0755 ${WORKDIR}/ArtifactCommit_Enter_50_sensornode-health ${D}${sysconfdir}/mender/scripts/
    install -m 0755 ${WORKDIR}/mender-device-identity ${D}${datadir}/mender/identity/mender-device-identity
}

# Safely append the hostname mapping without causing a packaging collision with base-files
pkg_postinst:${PN}() {
    if [ -n "${MENDER_SERVER_HOST_IP}" ] && [ -f "$D${sysconfdir}/hosts" ]; then
        if ! grep -q "docker.mender.io" "$D${sysconfdir}/hosts"; then
            echo "${MENDER_SERVER_HOST_IP} docker.mender.io" >> "$D${sysconfdir}/hosts"
        fi
    fi
}

FILES:${PN} += " \
    ${sysconfdir}/mender \
    ${datadir}/mender \
"

CONFFILES:${PN} += " \
    ${sysconfdir}/mender/mender.conf \
    ${sysconfdir}/mender/server.crt \
"
