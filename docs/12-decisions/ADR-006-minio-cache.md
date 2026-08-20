---
id: ADR-006
title: Use MinIO for Shared Downloads and sstate
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

# Use MinIO for Shared Downloads and sstate

## Status

Approved

## Context

It supports standalone VPS8 operation and later shared-platform reuse.

## Decision

Use separate MinIO buckets and least-privilege identities for downloads, sstate, build evidence, and release evidence.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- AWS S3
- NFS
- local-only cache
