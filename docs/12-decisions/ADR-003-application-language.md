---
id: ADR-003
title: Use Go for the Initial SensorNode Application
status: Proposed
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

# Use Go for the Initial SensorNode Application

## Status

Proposed

## Context

A single binary, simple HTTP support, structured logging, and clear cross-build behavior keep focus on delivery.

## Decision

Use Go unless the compatibility spike identifies a material Yocto or footprint constraint.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- C++
- Rust
- Python
