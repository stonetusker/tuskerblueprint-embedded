---
id: OPS-004
title: Cache Maintenance
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - OPS-REQ-DOC
verified_by:
  []
---

# Cache Maintenance

## Objective

Monitor size and object age, preserve active release compatibility, remove abandoned entries by lifecycle policy, and never delete release evidence as part of cache cleanup.

## Preconditions

- Authorized operator
- Current infrastructure inventory
- Known service version
- Backup or rollback path
- Evidence destination

## Completion Record

Record operator, time, target, actions, result, exceptions, and follow-up.
