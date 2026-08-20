---
id: IMPL-YOCTO-001
title: Yocto Build Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - SYS-REQ-001
  - BLD-REQ-001
verified_by:
  []
---

# Yocto Build Step by Step

## Files involved

- `kas/base.yml`: Poky and OpenEmbedded sources, `qemuarm64`, common build settings
- `kas/ci.yml`: CI image and release identity
- `kas/release.yml`: release image and SPDX generation
- `kas/mender.yml`: Mender layer and `mender-full`
- `meta-sensornode/conf/layer.conf`: custom layer registration
- `meta-sensornode/conf/distro/sensornode.conf`: SensorNode distro
- `meta-sensornode/recipes-core/images/`: image variants
- `meta-sensornode/recipes-sensornode/sensornode-app/`: Go service recipe
- `meta-sensornode/lib/oeqa/runtime/cases/sensornode.py`: runtime test

## Build the container

```bash
make builder-image
```

## Build development image

```bash
KAS_FILE=kas/development.yml IMAGE=sensornode-image-dev scripts/build-image.sh
```

## Build CI image

```bash
KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci scripts/build-image.sh
```

## Run runtime tests

```bash
KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci scripts/run-qemu-tests.sh
```

The test verifies SSH reachability, systemd service state, `/health`, release identity, and failed systemd units.

## Build release image

```bash
SENSORNODE_VERSION=1.0.0 \
KAS_FILE=kas/release.yml \
IMAGE=sensornode-image-release \
scripts/build-image.sh
```

The release image removes debug tweaks and SSH, locks root, generates SPDX, and writes immutable identity to `/etc/sensornode/`.

## Failure-demo image

```bash
KAS_FILE=kas/broken-demo.yml IMAGE=sensornode-image-broken scripts/build-image.sh
KAS_FILE=kas/broken-demo.yml IMAGE=sensornode-image-broken scripts/run-qemu-tests.sh
```

The QEMU gate is expected to fail because the application health endpoint intentionally returns 503.
