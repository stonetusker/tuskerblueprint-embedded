---
id: ADR-005
title: Use a Pinned Unprivileged Builder Container
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

# Use a Pinned Unprivileged Builder Container

## Status

Approved

## Context

This standardizes dependencies and improves local/CI consistency.

## Decision

Build in a versioned container image identified by digest, running as a non-root build user.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Host-native packages
- ephemeral VM per build
