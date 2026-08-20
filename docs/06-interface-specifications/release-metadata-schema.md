---
id: INT-005
title: Release Metadata Schema
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---

# Release Metadata Schema

Required fields:

- product
- semantic version
- Git commit
- layer revisions
- machine
- distro
- image target
- builder image digest
- build number
- build timestamp
- image checksum
- SBOM checksum
- test evidence URI
- signature identity
- approval identifier

The canonical machine-readable file may be JSON; this Markdown document controls the schema.
