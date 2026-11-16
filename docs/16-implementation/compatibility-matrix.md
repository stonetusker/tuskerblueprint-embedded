---
id: IMPL-013
title: Compatibility Matrix
status: Draft
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-11-16
traces_to:
  - ADR-001
  - ADR-008
  - ADR-009
verified_by:
  []
---


# Compatibility Matrix

| Area | Candidate Baseline | Evidence Required | Final Status |
|---|---|---|---|
| Yocto/Poky | Scarthgap branch | Clean build and OEQA pass | Unverified |
| meta-openembedded | Matching Scarthgap branch | Recipe parse and image build | Unverified |
| meta-mender | Matching validated branch/commit | A/B install, commit, rollback | Unverified |
| Builder host | Ubuntu 24.04 container on Linux | Full build and QEMU access | Unverified |
| Jenkins agents | Pinned Java runtime and agent.jar from the controller | Main CI build pass | Unverified |
| Jenkins | Pinned LTS image | Diagnostic pipeline pass | Unverified |
| Jenkins MCP | Selected plugin or adapter | Allowlist, audit, Claude, denial tests | Unverified |
| Mender server | Upstream-supported pinned bundle | Device, artifact, deployment, backup | Unverified |

This document is intentionally Draft until the live compatibility spike supplies evidence.
