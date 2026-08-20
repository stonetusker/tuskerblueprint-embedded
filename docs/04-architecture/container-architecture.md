---
id: ARCH-003
title: Container Architecture
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

# Container Architecture

## Purpose

The Yocto builder runs as a pinned, unprivileged container with mounted workspace and cache paths. Jenkins, MinIO, Mender services, reverse proxy, and selected observability components may run as containers. QEMU access to KVM, networking, and persistent device disks is explicitly controlled.


## Key Decisions

- Build and release implementation lives in repository scripts, not CI-specific logic.
- GitHub Actions is authoritative for continuous build.
- Jenkins exists for the enterprise diagnostic story and cannot promote OTA releases.
- QEMU is a virtual validation gate, not physical-board certification.
- Promotion uses the exact tested artifact.
- AI remains advisory and least-privileged.

## Failure Handling

Failures must be classified, retained as evidence, and prevented from silently producing a release. Timeouts, cleanup, retries, and escalation are component responsibilities.

## Evolution

Any move to shared Project A infrastructure must preserve artifact identity, approval boundaries, least privilege, and evidence continuity.
