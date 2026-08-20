---
id: ADR-004
title: Use kas for Layer and Build Configuration
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

# Use kas for Layer and Build Configuration

## Status

Proposed

## Context

It provides reviewable source pinning and repeatable local and CI entry points.

## Decision

Use pinned `kas` manifests to fetch and configure Poky and dependent layers.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Git submodules
- repo tool
- manual setup
