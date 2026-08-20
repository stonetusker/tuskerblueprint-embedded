---
id: ADR-007
title: Provision Project C Standalone with Ansible
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

# Provision Project C Standalone with Ansible

## Status

Approved

## Context

This preserves delivery sequence and enables later migration without duplicated manual configuration.

## Decision

Provision VPS8 services through modular Ansible roles before Project A exists.

## Consequences

- The decision becomes part of release traceability.
- Changes require a superseding ADR.
- Implementation and tests must match the decision.

## Alternatives Considered

- Wait for Project A
- manual Docker setup
