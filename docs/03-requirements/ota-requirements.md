---
id: OTA-REQ-DOC
title: OTA Requirements
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
  - TEST-OTA-001
  - TEST-SEC-004
  - TEST-OTA-002
  - TEST-OTA-003
  - TEST-ROLLBACK-002
---

# OTA Requirements

| ID | Requirement | Priority | Verification |
|---|---|---|---|
| OTA-REQ-001 | Only an immutable tested candidate shall be packaged or promoted for OTA. | Must | TEST-OTA-001 |
| OTA-REQ-002 | Mender artifacts shall be signed and checksummed. | Must | TEST-SEC-004 |
| OTA-REQ-003 | Deployment shall begin with a canary device. | Must | TEST-OTA-002 |
| OTA-REQ-004 | Post-boot health shall control update commit. | Must | TEST-OTA-003 |
| OTA-REQ-005 | A failed canary shall stop wider rollout. | Must | TEST-ROLLBACK-002 |

## Interpretation

“Shall” statements are mandatory for the first public release. Deviations require an approved change request and updated traceability.
