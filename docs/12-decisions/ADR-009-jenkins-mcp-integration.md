---
id: ADR-009
title: Use a Constrained Jenkins MCP Integration
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

# Use a Constrained Jenkins MCP Integration

## Status

Proposed

## Context

The AI story depends on safe evidence access, not plugin novelty.

## Decision

Use an official or community MCP integration only if it supports read-only diagnostics, auditability, and tool restriction. Otherwise implement an equivalent constrained adapter without creating a Yocto-specific MCP server.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Direct Jenkins API wrapper
- no AI integration
