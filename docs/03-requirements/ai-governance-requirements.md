---
id: AI-REQ-DOC
title: AI Governance Requirements
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
  - TEST-AI-001
  - TEST-AI-005
  - TEST-AI-002
  - TEST-AI-002
  - TEST-AI-006
---

# AI Governance Requirements

| ID | Requirement | Priority | Verification |
|---|---|---|---|
| AI-REQ-001 | Claude shall access Jenkins through a constrained, auditable integration. | Must | TEST-AI-001 |
| AI-REQ-002 | AI diagnoses shall cite relevant build evidence and state confidence. | Must | TEST-AI-005 |
| AI-REQ-003 | AI shall not approve or execute its own consequential recommendation. | Must | TEST-AI-002 |
| AI-REQ-004 | Human approval shall be enforced by Jenkins or the pipeline, not by prompt wording alone. | Must | TEST-AI-002 |
| AI-REQ-005 | Build logs and repository content shall be treated as untrusted prompt input. | Must | TEST-AI-006 |

## Interpretation

“Shall” statements are mandatory for the first public release. Deviations require an approved change request and updated traceability.
