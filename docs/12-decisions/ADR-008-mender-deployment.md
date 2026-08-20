---
id: ADR-008
title: Validate Mender Topology in a Compatibility Spike
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

# Validate Mender Topology in a Compatibility Spike

## Status

Proposed

## Context

Mender packaging, partitioning, and supported versions are high-risk dependencies.

## Decision

Choose the exact Mender server and Yocto integration only after a one-device install, reboot, commit, and rollback spike succeeds.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Alternative OTA framework
- hosted service
