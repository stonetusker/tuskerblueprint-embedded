---
id: DIR-QEMU-FLEET-README-MD
title: Qemu-Fleet Documentation
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

# Qemu-Fleet

The virtual fleet follows COMP-011, the QEMU fleet runbook, and rollback tests.

## Baseline Mode

`launch/qemu-device.sh` directly boots the Yocto `Image` kernel and ext4 root filesystem with a Cortex-A53 CPU model. This validates the application and operating system.

## Mender Mode

A/B OTA requires the validated meta-mender disk layout and boot integration. The compatibility spike will add a dedicated Mender fleet launcher after `TEST-SPIKE-003` proves install, reboot, commit, and rollback.
