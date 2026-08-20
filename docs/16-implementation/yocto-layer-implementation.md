---
id: IMPL-002
title: Yocto Layer Implementation
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---


# Yocto Layer Implementation

## Layer

`meta-sensornode` is a real Yocto layer with:

- `conf/layer.conf`
- `conf/distro/sensornode.conf`
- Common and variant image recipes
- SensorNode Go application recipe
- systemd unit and hardening
- Immutable release identity package
- OEQA runtime tests executed by `testimage`
- Compatibility-controlled Mender client configuration

## Build

```bash
docker build -t stonetusker/yocto-builder:0.2.0 containers/yocto-builder
KAS_FILE=kas/development.yml IMAGE=sensornode-image-dev scripts/build-image.sh
```

## CI Runtime Test

```bash
KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci scripts/run-qemu-tests.sh
```

The custom OEQA case verifies service state, `/health`, image identity, and failed systemd units from inside the QEMU guest.

## Release Pinning

The reference branch is Scarthgap. Phase 0 must replace moving branch references with verified immutable commits and record them in ADR-001 before release.
