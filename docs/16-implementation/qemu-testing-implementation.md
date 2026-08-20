---
id: IMPL-005
title: QEMU Testing Implementation
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


# QEMU Testing Implementation

The primary CI gate is Yocto `testimage`, which gives the test code the target abstraction, SSH access, logs, timeout handling, and QEMU lifecycle management.

A separate direct QEMU launcher is included for demonstrations and a small fleet. It boots the ARM64 kernel with `-cpu cortex-a53`, a virtio root filesystem, serial logging, and forwarded SSH/application ports.

The direct launcher validates software behavior; Mender A/B boot behavior requires the compatibility-approved disk and boot integration.
