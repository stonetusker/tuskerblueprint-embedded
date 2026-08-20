---
id: IMPL-MENDER-OTA-002
title: Mender OTA Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - PRD-REQ-005
verified_by:
  []
---

# Mender OTA Step by Step

## 1. Set the server URL

Copy `config/project.env.example` to `config/project.env` and set the real HTTPS endpoint:

```text
MENDER_SERVER_URL=https://mender.example.com
```

## 2. Build the Mender-capable release image

```bash
make source-lock-check
SENSORNODE_VERSION=1.0.0 \
SOURCE_LOCK_CONFIG=kas/source-lock.yml \
KAS_FILE=kas/mender.yml \
IMAGE=sensornode-image-release \
scripts/build-image.sh
```

`kas/mender.yml` includes `meta-mender-core`, `meta-mender-qemu`, `mender-full`, the client, and `sensornode-mender-config`.

## 3. Validate the exact release root filesystem

```bash
scripts/run-release-qemu-tests.sh
```

This is a pre-OTA software gate. The Mender A/B boot path must also be validated using the selected meta-mender QEMU integration.

## 4. Create/sign candidate

The preferred path is `.github/workflows/release-candidate.yml`. It builds and tests on the Yocto runner, then signs on the isolated release runner.

## 5. Upload and canary

Use `.github/workflows/promote-mender.yml` with the immutable candidate URI, expected SHA-256, artifact name, and only the canary device ID.

## 6. Device health

`meta-sensornode/recipes-mender/sensornode-mender-config/files/ArtifactCommit_Enter_50_sensornode-health` verifies the SensorNode service and `/health` before commit.

## 7. Expand rollout

Only after the canary reports the expected artifact and remains healthy should the pilot and fleet cohorts be started.
