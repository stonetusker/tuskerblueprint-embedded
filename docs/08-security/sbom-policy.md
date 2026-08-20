---
id: SEC-ARCH-005
title: SBOM Policy
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

# SBOM Policy

## Policy

Every release candidate includes an SPDX-compatible SBOM generated from the Yocto build. The SBOM is checksummed, retained, and linked in release metadata.

## Required Controls

- Least privilege
- Authentication and authorization
- Audit logging
- Secret redaction
- Fail-closed behavior for release controls
- Documented recovery and revocation

## Verification

Controls are verified by the security test plan and reviewed before each public release.
