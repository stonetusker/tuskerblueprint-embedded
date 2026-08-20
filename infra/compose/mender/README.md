---
id: IMPL-MENDER-SERVER-001
title: Mender Server Deployment Scaffold
status: In Review
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ADR-008
verified_by:
  []
---


# Mender Server Deployment Scaffold

The self-hosted Mender server topology is version-specific and must not be recreated from memory. During Phase 0, select an upstream-supported deployment bundle, record its immutable source and checksum, and vendor or retrieve it through the Ansible `mender` role.

The role must fail unless all of these are supplied:

- Validated Mender bundle version
- Immutable archive URL
- SHA-256 checksum
- Domain and TLS configuration
- Database and object-storage credentials
- Backup and restore procedure

This directory intentionally avoids an invented compose stack that could misrepresent current Mender architecture.
