---
id: IMPL-020
title: Mender A/B State Model
status: In Review
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Security Reviewer
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ADR-008
  - OTA-REQ-004
verified_by:
  - TEST-SPIKE-003
---

# Mender A/B State Model

## Intended State Flow

```text
Idle on rootfs A
→ Download signed artifact
→ Verify signature and device compatibility
→ Install rootfs B
→ Mark B as next boot candidate
→ Reboot
→ Run SensorNode and system health checks
→ Commit B when healthy
→ Continue on B
```

Failure flow:

```text
Boot B
→ Health or boot criterion fails
→ Do not commit B
→ Boot integration restores A
→ Report failure
→ Stop wider deployment
```

## Required Partition Model

The selected QEMU integration must provide two root filesystem slots, persistent Mender state, and a boot mechanism capable of selecting and reverting the active slot. Exact partition sizes and boot variables are locked only after image-size and rollback evidence.

## Health Criteria

Commit requires:

- SensorNode service active
- `/health` successful
- expected image version running
- no mandatory failed systemd unit
- required persistent state writable

## Compatibility Warning

State-script names, client commands, image classes, and bootloader integration differ across Mender generations. The included code defines the intended contract but remains `In Review` until the selected versions pass `TEST-SPIKE-003`.
