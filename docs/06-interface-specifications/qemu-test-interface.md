---
id: INT-003
title: QEMU Test Interface
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

# QEMU Test Interface

The harness accepts image path, kernel path when required, device name, timeout, network mode, evidence directory, and expected version.

It emits JUnit XML, serial log, test summary, QEMU command record, and a process exit status.
