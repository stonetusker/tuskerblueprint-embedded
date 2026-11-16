---
id: ARCH-004
title: Deployment Architecture
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

# Deployment Architecture

## Purpose

Release 1 uses standalone VPS8 infrastructure provisioned with Ansible. The Jenkins build and release agents are host-managed, builds run in a container, and persistent services run in supported containers. Administrative endpoints are restricted; only the required Mender device endpoint is externally reachable.


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
