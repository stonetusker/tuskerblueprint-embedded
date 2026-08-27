SUMMARY = "Sensornode release metadata"
DESCRIPTION = "Provides release and version metadata for the Sensornode OS image."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

INHIBIT_DEFAULT_DEPS = "1"

do_compile[noexec] = "1"

do_install() {
    install -d ${D}${sysconfdir}
    echo "IMAGE_VERSION=\"${SENSORNODE_IMAGE_VERSION}\"" > ${D}${sysconfdir}/sensornode-release
    echo "GIT_COMMIT=\"${SENSORNODE_GIT_COMMIT}\"" >> ${D}${sysconfdir}/sensornode-release
    echo "BUILD_NUMBER=\"${SENSORNODE_BUILD_NUMBER}\"" >> ${D}${sysconfdir}/sensornode-release
    chmod 0644 ${D}${sysconfdir}/sensornode-release
}

FILES:${PN} += "${sysconfdir}/sensornode-release"
