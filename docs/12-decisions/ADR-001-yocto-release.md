---
id: ADR-001
title: Select a Supported Yocto Release
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

# Select a Supported Yocto Release

## Status

Proposed

## Context

Using an unverified release risks integration failure; live compatibility must be confirmed during the spike.

## Decision

Select a currently supported Yocto release only after verifying compatibility with the selected Mender integration and builder host. Pin exact commits.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Older LTS
- newest feature release
- vendor fork
