---
id: DEMO-OTA-001
title: Pipeline Prevention Scenario
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - PRD-REQ-006
verified_by:
  []
---


# Pipeline Prevention Scenario

1. Build `kas/broken-demo.yml`.
2. Boot through Yocto `testimage`.
3. Confirm `/health` returns 503.
4. Confirm the QEMU job fails.
5. Confirm artifact packaging and Mender promotion jobs do not execute.
6. Confirm all fleet devices retain the prior version.
