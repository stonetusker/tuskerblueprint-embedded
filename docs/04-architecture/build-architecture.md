---
id: ARCH-005
title: Build Architecture
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - SYS-REQ-001
  - SEC-REQ-002
verified_by:
  []
---

# Build Architecture

## Purpose

`kas` manifests pin Poky and required layers. Common scripts prepare, build, collect metadata, generate SBOM, and package release artifacts. Build configuration supports development, CI, release, and broken-demo variants.


## Key Decisions

- Build and release implementation lives in repository scripts, not CI-specific logic.
- Jenkins is the only CI/CD orchestrator; GitHub hosts the Git repository only (ADR-011).
- Signing and OTA promotion run only in the dedicated Jenkins release jobs, after named approval and on the isolated release agent; the CI and diagnostic jobs cannot sign or deploy.
- QEMU is a virtual validation gate, not physical-board certification.
- Promotion uses the exact tested artifact.
- AI remains advisory and least-privileged.

## Failure Handling

Failures must be classified, retained as evidence, and prevented from silently producing a release. Timeouts, cleanup, retries, and escalation are component responsibilities.

## Evolution

Any move to shared Project A infrastructure must preserve artifact identity, approval boundaries, least privilege, and evidence continuity.
