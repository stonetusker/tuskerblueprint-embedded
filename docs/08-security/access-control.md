---
id: SEC-ARCH-006
title: Access Control
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - SEC-REQ-DOC
verified_by:
  []
---

# Access Control

## Policy

Roles separate development, review, release approval, administration, and AI diagnostics. No identity combines AI recommendation and approval authority.

## Required Controls

- Least privilege
- Authentication and authorization
- Audit logging
- Secret redaction
- Fail-closed behavior for release controls
- Documented recovery and revocation

## Verification

Controls are verified by the security test plan and reviewed before each public release.
