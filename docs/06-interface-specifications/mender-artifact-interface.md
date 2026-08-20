---
id: INT-006
title: Mender Artifact Interface
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---

# Mender Artifact Interface

Artifact names follow:

`sensornode-<version>-<short-sha>-<build-number>.mender`

The artifact declares compatible device type, release identity, checksum, and signature. The artifact is created from the exact QEMU-tested image.
