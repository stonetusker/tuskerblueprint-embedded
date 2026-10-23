SUMMARY = "SensorNode wired network configuration"
DESCRIPTION = "systemd-networkd DHCP configuration for the SensorNode Ethernet uplink"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://80-sensornode-wired.network"

S = "${WORKDIR}"

inherit allarch

do_install() {
    install -d ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/80-sensornode-wired.network ${D}${systemd_unitdir}/network/
}

FILES:${PN} = "${systemd_unitdir}/network/80-sensornode-wired.network"
RDEPENDS:${PN} = "systemd"
