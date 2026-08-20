SUMMARY = "Stonetusker SensorNode reference application"
DESCRIPTION = "Small HTTP service used to validate embedded build, boot, OTA, and rollback workflows"
HOMEPAGE = "https://stonetusker.com"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/../../../app/sensornode:"

SRC_URI = " \
    file://go.mod \
    file://cmd \
    file://sensornode.service \
    file://sensornode-healthcheck.sh \
    file://sensornode.env \
"

S = "${WORKDIR}"
B = "${WORKDIR}/build"

inherit go-mod systemd useradd

GO_IMPORT = "stonetusker.com/tuskerblueprint/sensornode"

SENSORNODE_APP_VERSION ?= "${PV}"
SENSORNODE_GIT_COMMIT ?= "unknown"
SENSORNODE_BUILD_TIME ?= "not-recorded"
SENSORNODE_DEFAULT_FAILURE_MODE ?= "none"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "--system --user-group --home /var/lib/sensornode --shell /sbin/nologin sensornode"

SYSTEMD_SERVICE:${PN} = "sensornode.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_compile() {
    install -d ${B}
    cd ${S}
    ${GO} build ${GOBUILDFLAGS} -trimpath \
        -ldflags "-s -w -X main.version=${SENSORNODE_APP_VERSION} -X main.gitCommit=${SENSORNODE_GIT_COMMIT} -X main.buildTime=${SENSORNODE_BUILD_TIME}" \
        -o ${B}/sensornode ./cmd/sensornode
}

do_install() {
    install -d ${D}${bindir} ${D}${systemd_system_unitdir} ${D}${sysconfdir}/sensornode ${D}${libexecdir}/sensornode
    install -m 0755 ${B}/sensornode ${D}${bindir}/sensornode
    install -m 0644 ${WORKDIR}/sensornode.service ${D}${systemd_system_unitdir}/sensornode.service
    install -m 0755 ${WORKDIR}/sensornode-healthcheck.sh ${D}${libexecdir}/sensornode/healthcheck
    install -m 0644 ${WORKDIR}/sensornode.env ${D}${sysconfdir}/sensornode/sensornode.env
    sed -i 's|@FAILURE_MODE@|${SENSORNODE_DEFAULT_FAILURE_MODE}|g' ${D}${sysconfdir}/sensornode/sensornode.env
}

FILES:${PN} += "${systemd_system_unitdir}/sensornode.service ${libexecdir}/sensornode ${sysconfdir}/sensornode"
CONFFILES:${PN} += "${sysconfdir}/sensornode/sensornode.env"
