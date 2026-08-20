---
id: DIR-MENDER-README-MD
title: Mender Documentation
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

# Mender

Mender implementation follows ARCH-008, COMP-009, COMP-010, and the OTA test plan.

## Implementation Boundary

The repository includes artifact creation, signing, health checks, promotion wrappers, and deployment scenarios. The exact self-hosted Mender bundle and A/B boot integration are deliberately version-gated because they must be validated together with the selected Yocto release.

Release code fails closed when the required Mender CLI, credentials, artifact, or approval input is absent.
