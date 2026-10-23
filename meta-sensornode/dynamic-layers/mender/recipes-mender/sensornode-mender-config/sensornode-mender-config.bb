SUMMARY = "SensorNode Mender state scripts"
DESCRIPTION = "Artifact state scripts that gate the Mender commit on SensorNode health. \
Server URL, polling and the server certificate are set through meta-mender variables in kas/mender.yml."
LICENSE = "CLOSED"

SRC_URI = " \
    file://ArtifactCommit_Enter_50_sensornode-health \
    file://sensornode-require-data-partition.conf \
    file://sensornode-require-data-mount.conf \
"

S = "${WORKDIR}"

inherit mender-state-scripts

# Artifact* scripts are embedded in the .mender file, not installed in the rootfs.
do_compile() {
    install -m 0755 ${WORKDIR}/ArtifactCommit_Enter_50_sensornode-health ${MENDER_STATE_SCRIPTS_DIR}/
}

do_install:append() {
    install -d ${D}${systemd_system_unitdir}/mender-grow-data.service.d
    sed -e 's|@MENDER_DATA_PART@|${MENDER_DATA_PART}|' ${WORKDIR}/sensornode-require-data-partition.conf \
        > ${D}${systemd_system_unitdir}/mender-grow-data.service.d/sensornode-require-data-partition.conf
    install -d ${D}${systemd_system_unitdir}/mender-configure-apply-device-config.service.d
    install -m 0644 ${WORKDIR}/sensornode-require-data-mount.conf \
        ${D}${systemd_system_unitdir}/mender-configure-apply-device-config.service.d/
}

FILES:${PN} += " \
    ${systemd_system_unitdir}/mender-grow-data.service.d \
    ${systemd_system_unitdir}/mender-configure-apply-device-config.service.d \
"
