---
id: PRD-005
title: Release Strategy
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---

# Release Strategy

A release progresses through Built, Tested, Candidate, Approved, Canary, Verified, Fleet Rollout, and Completed.

The artifact tested in QEMU is promoted without rebuilding. Promotion checks signature, checksum, SBOM, test evidence, approval, and target compatibility.

Public repository releases use signed Git tags and include Markdown release notes linking requirements, ADRs, tests, and evidence.
