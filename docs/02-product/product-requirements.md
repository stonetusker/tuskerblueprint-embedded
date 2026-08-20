---
id: PRD-003
title: Product Requirements
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - BUS-001
verified_by:
  - TEST-BUILD-001
  - TEST-QEMU-003
  - TEST-CACHE-001
  - TEST-QEMU-001
  - TEST-OTA-001
  - TEST-ROLLBACK-001
  - TEST-ROLLBACK-002
  - TEST-AI-001
  - TEST-AI-002
  - TEST-DOC-001
---

# Product Requirements

| ID | Requirement | Priority | Verification |
|---|---|---|---|
| PRD-REQ-001 | Build a minimal ARM64 SensorNode image with Yocto. | Must | TEST-BUILD-001 |
| PRD-REQ-002 | Run the SensorNode application as a managed systemd service. | Must | TEST-QEMU-003 |
| PRD-REQ-003 | Measure clean and shared-cache build performance under equivalent conditions. | Must | TEST-CACHE-001 |
| PRD-REQ-004 | Validate every release candidate in headless QEMU before promotion. | Must | TEST-QEMU-001 |
| PRD-REQ-005 | Deliver a validated image to a QEMU device through Mender OTA. | Must | TEST-OTA-001 |
| PRD-REQ-006 | Prevent a failed build or smoke test from creating an OTA deployment. | Must | TEST-ROLLBACK-001 |
| PRD-REQ-007 | Roll back an installed but unhealthy update to the last known good version. | Must | TEST-ROLLBACK-002 |
| PRD-REQ-008 | Allow Claude to inspect Jenkins evidence and propose remediation through a constrained MCP integration. | Must | TEST-AI-001 |
| PRD-REQ-009 | Require explicit human approval before an AI-proposed rebuild is executed. | Must | TEST-AI-002 |
| PRD-REQ-010 | Maintain requirements, architecture, tests, decisions, runbooks, and evidence summaries as Markdown in Git. | Must | TEST-DOC-001 |

## Acceptance Rule

A public release cannot be declared complete while any Must requirement remains unverified.
