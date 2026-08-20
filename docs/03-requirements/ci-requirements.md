---
id: CI-REQ-DOC
title: CI Requirements
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
  - TEST-CI-001
  - TEST-CI-002
  - TEST-CI-003
  - TEST-SEC-003
  - TEST-CI-004
---

# CI Requirements

| ID | Requirement | Priority | Verification |
|---|---|---|---|
| CI-REQ-001 | GitHub Actions shall be the authoritative continuous-build orchestrator. | Must | TEST-CI-001 |
| CI-REQ-002 | GitHub Actions and Jenkins shall invoke common repository scripts. | Must | TEST-CI-002 |
| CI-REQ-003 | Full Yocto build concurrency shall be limited until resource evidence supports expansion. | Must | TEST-CI-003 |
| CI-REQ-004 | Untrusted pull requests shall not receive unrestricted cache-write or deployment credentials. | Must | TEST-SEC-003 |
| CI-REQ-005 | A main-branch failure shall retain actionable logs and test reports. | Must | TEST-CI-004 |

## Interpretation

“Shall” statements are mandatory for the first public release. Deviations require an approved change request and updated traceability.
