---
id: INT-007
title: Device Identity Interface
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

# Device Identity Interface

Each QEMU device has a stable unique identifier, device type, fleet cohort, and current artifact name.

Identity data must not expose infrastructure secrets. Device names use `sensornode-qemu-NN`.
