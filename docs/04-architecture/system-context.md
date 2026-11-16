---
id: ARCH-002
title: System Context
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-11-16
traces_to:
  - SYS-REQ-001
  - SEC-REQ-002
verified_by:
  []
---

# System Context

## Purpose

Developers push to the GitHub repository. Jenkins polls it and schedules work on the VPS8 build agent. The builder consumes pinned Yocto sources and shared caches, emits an image, and passes it to QEMU tests. Passing candidates are signed on the isolated release agent after approval and uploaded to Mender by a separately approved Jenkins job. QEMU devices poll Mender. Jenkins exposes selected evidence to Claude through MCP, with human approval enforced before rebuild.


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
