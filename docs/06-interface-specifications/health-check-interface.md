---
id: INT-008
title: Health Check Interface
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

# Health Check Interface

Health succeeds only when the SensorNode service is active, the application endpoint responds, the expected version is running, mandatory systemd units are healthy, and required storage is writable.

The same logical criteria are used by CI and post-OTA validation.
