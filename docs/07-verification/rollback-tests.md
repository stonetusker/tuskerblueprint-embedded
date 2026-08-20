---
id: TEST-ROLLBACK-DOC
title: Rollback Tests
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - PRD-003
verified_by:
  []
---

# Rollback Tests

## Objective

Verify both pre-deployment prevention and post-install rollback. A failed build creates no deployment; an unhealthy installed update returns to the previous artifact and stops rollout.

## Evidence Requirements

- Test identifier and version
- Requirement identifiers
- Environment and input revisions
- Start and end time
- Result and failure reason
- Artifact checksums
- Evidence location
- Reviewer

## Pass Rule

A pass requires all mandatory expectations. A partial result is recorded as failed or blocked, never silently accepted.
