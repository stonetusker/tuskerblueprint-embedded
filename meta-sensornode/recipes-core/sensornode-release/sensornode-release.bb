SUMMARY = "SensorNode immutable release identity"
LICENSE = "CLOSED"

SENSORNODE_IMAGE_VERSION ?= "development"
SENSORNODE_GIT_COMMIT ?= "unknown"
SENSORNODE_BUILD_NUMBER ?= "local"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/sensornode
    printf '%s\n' '${SENSORNODE_IMAGE_VERSION}' > ${D}${sysconfdir}/sensornode/image-version
    cat > ${D}${sysconfdir}/sensornode/release.json <<EOF
{
  "product": "SensorNode",
  "image_version": "${SENSORNODE_IMAGE_VERSION}",
  "git_commit": "${SENSORNODE_GIT_COMMIT}",
  "build_number": "${SENSORNODE_BUILD_NUMBER}",
  "machine": "${MACHINE}",
  "distro": "${DISTRO}"
}
EOF
}

FILES:${PN} = "${sysconfdir}/sensornode"
