---
id: ADR-002
title: Use qemuarm64 as the Initial Machine
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

# Use qemuarm64 as the Initial Machine

## Status

Approved

## Context

It provides standard virtual validation without overclaiming board-specific BSP behavior.

## Decision

Use `qemuarm64` for release 1 and describe it as an ARM64 QEMU reference target representing a Cortex-A53-class SensorNode.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Custom QEMU machine
- Raspberry Pi BSP
- physical board
