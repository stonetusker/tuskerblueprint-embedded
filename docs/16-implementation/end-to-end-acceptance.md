---
id: IMPL-ACCEPT-001
title: End-to-End Acceptance Procedure
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - GOV-007
verified_by:
  []
---

# End-to-End Acceptance Procedure

Use this procedure before declaring Project C complete.

## Repository

```bash
make validate
```

Expected: all local static/application checks pass.

## Host

```bash
scripts/doctor-ubuntu24.sh
```

Expected: no failures.

## Source lock

```bash
make source-lock-check
```

Expected: Poky, meta-openembedded, and meta-mender are immutable commits.

## Build and QEMU

```bash
KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci scripts/build-image.sh
scripts/run-qemu-tests.sh
```

Expected: image and OEQA tests pass.

## Cache

Run controlled clean and cached builds. Record environment and elapsed time. Do not use estimated numbers.

## Release

Run the release-candidate workflow from a commit already on `main`. Confirm the signing job signs the exact tested candidate and publishes to a previously unused MinIO path.

## OTA

Deploy to one canary. Verify install, reboot, `/health`, artifact identity, and commit.

## Rollback

Execute both pipeline prevention and device rollback. Confirm wider rollout does not start after failure.

## Jenkins/AI

Run a controlled failure. Confirm Claude reads only permitted evidence, cites the failure, proposes an action, and cannot execute it. Confirm a named human approves one rebuild in Jenkins.

## Operations

Exercise runner replacement, Jenkins backup/restore, MinIO data backup, Mender backup/restore, certificate renewal path, and signing-key revocation procedure.

## Publication gate

Review `docs/11-content-series/claims-validation.md`. Every public claim must have retained evidence.
