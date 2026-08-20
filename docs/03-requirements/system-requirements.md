---
id: SYS-REQ-DOC
title: System Requirements
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - PRD-003
verified_by:
  - TEST-BUILD-001
  - TEST-REL-001
  - TEST-QEMU-001
  - TEST-QEMU-004
  - TEST-OTA-001
  - TEST-ROLLBACK-001
  - TEST-ROLLBACK-002
---

# System Requirements

| ID | Requirement | Priority | Verification |
|---|---|---|---|
| SYS-REQ-001 | The system shall build `sensornode-image` for `qemuarm64` from pinned layer revisions. | Must | TEST-BUILD-001 |
| SYS-REQ-002 | The system shall produce release metadata that identifies commit, layers, machine, image, builder, and checksums. | Must | TEST-REL-001 |
| SYS-REQ-003 | The system shall boot the generated image in headless QEMU. | Must | TEST-QEMU-001 |
| SYS-REQ-004 | The system shall prevent promotion when mandatory QEMU validation fails. | Must | TEST-QEMU-004 |
| SYS-REQ-005 | The system shall update a registered QEMU device through Mender. | Must | TEST-OTA-001 |
| SYS-REQ-006 | The system shall retain the last known good version when a candidate fails before deployment. | Must | TEST-ROLLBACK-001 |
| SYS-REQ-007 | The system shall roll back after post-boot health failure. | Must | TEST-ROLLBACK-002 |

## Interpretation

“Shall” statements are mandatory for the first public release. Deviations require an approved change request and updated traceability.
