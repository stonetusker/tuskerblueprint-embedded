---
id: IMPL-012
title: Phase 0 Compatibility Spike Plan
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---


# Phase 0 Compatibility Spike Plan

## Spike 1 — Yocto Baseline

Build `sensornode-image-ci`, boot with `testimage`, and lock Poky and meta-openembedded commits.

## Spike 2 — Builder and Host

Measure Linux host resource use, container behavior, KVM access, storage growth, and cache reuse.

## Spike 3 — Mender A/B

Lock meta-mender and server versions. Prove artifact creation, install, reboot, health, commit, and rollback on one QEMU device.

## Spike 4 — Jenkins MCP

Evaluate the selected plugin or adapter against tool allowlists, bounded logs, audit records, Claude compatibility, and denied actions.

## Exit

Update ADR-001, ADR-004, ADR-008, ADR-009, compatibility matrix, lock files, and evidence summaries.
