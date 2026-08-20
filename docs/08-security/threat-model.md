---
id: SEC-ARCH-001
title: Threat Model
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

# Threat Model

## Policy

Assets include source, build inputs, caches, runners, credentials, signing keys, artifacts, device identities, Jenkins data, MCP tools, and approval records. Threats include supply-chain compromise, cache poisoning, runner persistence, secret leakage, malicious logs, prompt injection, unsafe AI commands, and unauthorized deployment.

## Required Controls

- Least privilege
- Authentication and authorization
- Audit logging
- Secret redaction
- Fail-closed behavior for release controls
- Documented recovery and revocation

## Verification

Controls are verified by the security test plan and reviewed before each public release.
