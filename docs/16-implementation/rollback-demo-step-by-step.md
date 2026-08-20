---
id: IMPL-RB-001
title: Rollback Demonstration Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - PRD-REQ-006
  - PRD-REQ-007
verified_by:
  []
---

# Rollback Demonstration Step by Step

Project C demonstrates two independent safety controls.

## Scenario A: pipeline prevention

```bash
KAS_FILE=kas/broken-demo.yml IMAGE=sensornode-image-broken scripts/build-image.sh
KAS_FILE=kas/broken-demo.yml IMAGE=sensornode-image-broken scripts/run-qemu-tests.sh
```

Expected result: QEMU health test fails, the CI job is red, no release candidate is promoted, and Mender receives no deployment.

## Scenario B: device rollback

1. Build a controlled artifact that boots but fails the Mender pre-commit health script.
2. Deploy only to the canary.
3. Capture the device's current artifact name.
4. Allow install and reboot.
5. Confirm the health script exits non-zero.
6. Confirm the selected Mender client/boot integration rolls back to the prior slot.
7. Confirm the wider cohort remains untouched.
8. Save server state, serial logs, application logs, and before/after artifact names.

Do not claim automatic rollback until Scenario B has been proven on the locked Mender/meta-mender versions.
