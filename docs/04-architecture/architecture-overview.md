---
id: ARCH-001
title: Architecture Overview
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

# Architecture Overview

## Purpose

The system separates source control, orchestration, build execution, cache, virtual validation, release packaging, OTA control, fleet execution, and AI diagnostics. GitHub Actions is authoritative for CI; Jenkins is a parallel diagnostic demonstration. The tested artifact is promoted immutably.


```mermaid
flowchart LR
  Dev[Developer] --> Git[GitHub]
  Git --> GHA[GitHub Actions]
  GHA --> Runner[VPS8 Runner]
  Runner --> Build[Yocto Builder]
  Build --> Cache[MinIO Cache]
  Build --> QEMU[QEMU Gate]
  QEMU -->|Pass| Candidate[Signed Candidate]
  Candidate --> Mender[Mender]
  Mender --> Fleet[QEMU Fleet]
  Jenkins[Jenkins] --> MCP[MCP]
  MCP --> Claude[Claude]
  Claude --> Human[Human Approval]
  Human --> Jenkins
```

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
