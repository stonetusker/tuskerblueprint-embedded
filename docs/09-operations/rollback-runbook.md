---
id: RUN-RB-001
title: Rollback Runbook
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

# Rollback Runbook

## Objective

Pause rollout, identify affected devices, verify last known good artifact, trigger or confirm rollback, validate health, retain evidence, and open corrective action.

## Preconditions

- Authorized operator
- Current infrastructure inventory
- Known service version
- Backup or rollback path
- Evidence destination

## Completion Record

Record operator, time, target, actions, result, exceptions, and follow-up.
