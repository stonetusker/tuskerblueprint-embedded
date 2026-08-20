---
id: DIR-META-SENSORNODE-README-MD
title: Meta-Sensornode Documentation
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---

# Meta-Sensornode

The custom Yocto layer will follow COMP-004 and the approved Yocto ADRs.

## Layer Contents

- `conf/distro/sensornode.conf`: distribution policy
- `recipes-core/images/`: development, CI, release, and failure images
- `recipes-core/sensornode-release/`: immutable image identity
- `recipes-sensornode/sensornode-app/`: Go application and systemd packaging
- `lib/oeqa/runtime/cases/sensornode.py`: custom QEMU runtime tests
- `recipes-mender/`: compatibility-controlled Mender client configuration

## Release Limitation

`LAYERSERIES_COMPAT` and Mender metadata target the reference Scarthgap baseline. Exact commits and Mender variables must be validated and locked during Phase 0 before a release claim is made.
