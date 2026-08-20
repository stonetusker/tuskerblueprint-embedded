---
id: ADR-010
title: Enforce Rebuild Approval in Jenkins
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

# Enforce Rebuild Approval in Jenkins

## Status

Approved

## Context

Approval must be a system control rather than prompt convention.

## Decision

Use an authenticated Jenkins input or protected approval stage before executing an AI-proposed rebuild.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Chat confirmation only
- autonomous rebuild
