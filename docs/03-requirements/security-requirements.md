---
id: SEC-REQ-DOC
title: Security Requirements
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
  - TEST-SEC-005
  - TEST-SEC-006
  - TEST-SEC-002
  - TEST-AI-003
  - TEST-AI-004
  - TEST-SEC-007
---

# Security Requirements

| ID | Requirement | Priority | Verification |
|---|---|---|---|
| SEC-REQ-001 | No production secret shall be stored in Git. | Must | TEST-SEC-005 |
| SEC-REQ-002 | Service identities shall use least privilege. | Must | TEST-SEC-006 |
| SEC-REQ-003 | Release candidates shall include SBOM, checksum, and signature. | Must | TEST-SEC-002 |
| SEC-REQ-004 | AI access shall exclude administrator, shell, credential, and deployment authority. | Must | TEST-AI-003 |
| SEC-REQ-005 | Build logs shall be redacted before AI access. | Must | TEST-AI-004 |
| SEC-REQ-006 | Main branch and release promotion shall require protected review controls. | Must | TEST-SEC-007 |

## Interpretation

“Shall” statements are mandatory for the first public release. Deviations require an approved change request and updated traceability.
