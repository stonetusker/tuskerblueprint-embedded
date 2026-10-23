---
id: DEMO-OTA-002
title: Device Rollback Scenario
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - PRD-REQ-007
verified_by:
  []
---


# Device Rollback Scenario

1. Build and sign a controlled unhealthy Mender artifact.
2. Deploy only to the canary device.
3. Allow installation and reboot.
4. Fail the pre-commit SensorNode health script.
5. Confirm the selected Mender integration returns to the previous root filesystem.
6. Confirm the wider cohort is not started.
7. Retain deployment, device, serial, and application evidence.

`run-ota-e2e.sh` in this directory automates the scenario on one QEMU canary (healthy candidate first, then `sensornode-image-release-broken`). With the locked `meta-mender` (client 5.1.0, GRUB on UEFI), the gate is `ArtifactCommit_Enter_50_sensornode-health`; a non-zero exit refuses the commit and GRUB boots the previous slot. See `docs/15-evidence/rollback-summary.md`.
