SUMMARY = "SensorNode runtime package group"
DESCRIPTION = "Runtime packages required by the Stonetusker SensorNode reference image"
LICENSE = "MIT"
PR = "r1"

inherit packagegroup

RDEPENDS:${PN} = " \
    sensornode-app \
    sensornode-release \
    ca-certificates \
    curl \
    iproute2 \
    iputils-ping \
    jq \
    systemd-analyze \
"
