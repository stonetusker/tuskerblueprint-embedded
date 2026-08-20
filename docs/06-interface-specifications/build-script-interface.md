---
id: INT-002
title: Build Script Interface
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

# Build Script Interface

`build-image.sh` accepts environment, machine, target, workspace, downloads path, sstate path, and output directory.

It returns zero only when BitBake completes and required outputs exist. It writes a stable metadata file and never embeds CI-provider-specific behavior.

GitHub Actions and Jenkins must invoke this same interface.
