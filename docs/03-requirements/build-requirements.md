---
id: BLD-REQ-DOC
title: Build Requirements
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
  - TEST-BUILD-002
  - TEST-BUILD-003
  - TEST-CACHE-001
  - TEST-SEC-001
  - TEST-SEC-002
---

# Build Requirements

| ID | Requirement | Priority | Verification |
|---|---|---|---|
| BLD-REQ-001 | The build shall run as an unprivileged user in a pinned builder environment. | Must | TEST-BUILD-002 |
| BLD-REQ-002 | The build shall support clean, cached, CI, release, and broken-demo configurations. | Must | TEST-BUILD-003 |
| BLD-REQ-003 | The downloads and sstate locations shall be externally configurable. | Must | TEST-CACHE-001 |
| BLD-REQ-004 | The build shall fail on unpinned or checksum-invalid source inputs. | Must | TEST-SEC-001 |
| BLD-REQ-005 | The build shall emit an SPDX-compatible SBOM for release candidates. | Must | TEST-SEC-002 |

## Interpretation

“Shall” statements are mandatory for the first public release. Deviations require an approved change request and updated traceability.
