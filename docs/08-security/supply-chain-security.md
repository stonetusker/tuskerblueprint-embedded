---
id: SEC-ARCH-002
title: Supply-Chain Security
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

# Supply-Chain Security

## Policy

Pin source revisions and builder digests, verify checksums, scan dependencies, generate SBOMs, sign release artifacts, separate cache from releases, protect branches, and retain provenance.

## Required Controls

- Least privilege
- Authentication and authorization
- Audit logging
- Secret redaction
- Fail-closed behavior for release controls
- Documented recovery and revocation

## Verification

Controls are verified by the security test plan and reviewed before each public release.
