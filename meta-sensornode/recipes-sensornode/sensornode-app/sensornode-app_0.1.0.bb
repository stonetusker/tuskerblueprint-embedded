SUMMARY = "Sensornode Edge Application"
DESCRIPTION = "Telemetry and monitoring daemon for Sensornode"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

DEPENDS += "go-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/../../../app/sensornode:"

SRC_URI = " \
    file://cmd \
    file://go.mod \
    file://sensornode.service \
    file://sensornode-healthcheck.sh \
    file://sensornode.env \
"

S = "${WORKDIR}"
B = "${WORKDIR}"

# Inhibit standard GNU strip and debug split since Go handles its own symbols
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

do_compile() {
    export CGO_ENABLED=0
    export GOOS=linux
    export GOARCH=arm64
    export GO111MODULE=on
    export GOPROXY=off

    ${STAGING_BINDIR_NATIVE}/go build \
        -trimpath \
        -ldflags="-s -w" \
        -o ${B}/sensornode \
        ${S}/cmd/sensornode/main.go
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/sensornode ${D}${bindir}/sensornode
    install -m 0755 ${WORKDIR}/sensornode-healthcheck.sh ${D}${bindir}/sensornode-healthcheck.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/sensornode.service ${D}${systemd_system_unitdir}/sensornode.service

    install -d ${D}${sysconfdir}/default
    install -m 0644 ${WORKDIR}/sensornode.env ${D}${sysconfdir}/default/sensornode
}

SYSTEMD_SERVICE:${PN} = "sensornode.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

FILES:${PN} += " \
    ${bindir}/sensornode \
    ${bindir}/sensornode-healthcheck.sh \
    ${systemd_system_unitdir}/sensornode.service \
    ${sysconfdir}/default/sensornode \
"
