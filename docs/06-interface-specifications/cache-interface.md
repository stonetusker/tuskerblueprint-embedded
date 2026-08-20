---
id: INT-004
title: Cache Interface
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

# Cache Interface

The build consumes configurable `DL_DIR`, `SSTATE_DIR`, and mirror endpoints. Pull-request identities are read-only where practical. Trusted main and nightly jobs may write.

Cache availability failure must be visible; release identity must never depend on mutable cache object names.
