---
id: EVID-003
title: OTA Deployment Summary
status: In Review
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-10-23
traces_to:
  - OTA-REQ-001
  - OTA-REQ-003
  - OTA-REQ-004
verified_by:
  - TEST-OTA-001
  - TEST-OTA-002
  - TEST-OTA-003
---

# OTA Deployment Summary

## Scope

This summary records artifact upload, canary install, reboot, health, and commit for one QEMU canary device. A three-device fleet has not been exercised yet.

## Environment

| Item | Value |
|---|---|
| Host | Ubuntu 24.04.4 LTS, x86_64, 12 vCPU, 14 GiB RAM (`192.168.0.109`, `docker.mender.io`) |
| Device | `sensornode-canary-01`: QEMU 8.2.2 `virt,acpi=off`, TCG `cortex-a53`, 512 MiB, UEFI `qemu-efi-aarch64` 2024.02-2ubuntu0.9 |
| Mender server | Self-hosted `integration-3.8.5` bundle; service images resolve to tag `main` (see Open Points) |
| Mender client | `mender` 5.1.0 from `meta-mender` `720d1d1c` (scarthgap) |
| Source | `ff2bd03` plus the uncommitted `fix/release-qemu-ota` changes of 2026-10-23 |

## Source and Artifact Identifiers

| Role | Artifact name | File | SHA-256 |
|---|---|---|---|
| Factory disk (v101) | `sensornode-0.3.0-101-ff2bd03` | `sensornode-image-release-qemuarm64.uefiimg` | `164128f931c7260bb126423a2f3dd81cf7dcbc6c8a7bbafa43bd9117167a2bd1` |
| Canary candidate (v102) | `sensornode-0.3.0-102-ff2bd03` | `sensornode-image-release-qemuarm64.mender` | `0734bb8152b0b1561b47a959f05f8fe420c05e72aa15b5b7b3e5db8852e78c3f` |

## Procedure

`mender/demo-scenarios/run-ota-e2e.sh` with `FACTORY_DISK`, `GOOD_ARTIFACT`, and `BROKEN_ARTIFACT` set, run against the server over verified TLS (`MENDER_CA_CERT`). The steps are documented in `docs/16-implementation/mender-ota-step-by-step.md` section 7.

## Expected Result

The canary enrolls, downloads and installs v102 into the inactive slot, reboots, passes `ArtifactCommit_Enter_50_sensornode-health`, commits, and `/version` reports `0.3.0-102-ff2bd03`.

## Actual Result

| Step | Time (UTC) | Result |
|---|---|---|
| Factory boot healthy | 13:08:34 | `/version` = `0.3.0-101-ff2bd03` |
| New device key accepted | 13:08:44 | auth set `e16901bd-…` accepted for device `2c9b0811-fe35-483a-af7d-9ff4518a537d` |
| Deployment created | 13:08:46 | `04c32df5-4f8c-4f33-a48a-4eb9a598f11b` |
| Deployment finished | 13:10:10 | statistics `success: 1`, `failure: 0` |
| Post-update check | 13:10:17 | `/version` = `0.3.0-102-ff2bd03` |

Install-to-commit took 84 seconds. The same scenario passed in three runs on 2026-10-23: `20261023T121937Z`, `20261023T124422Z`, and `20261023T130809Z`. The last run is the reference.

## Evidence URI

`subeesh@192.168.0.109:/home/subeesh/tuskerblueprint-embedded/artifacts/ota/20261023T130809Z/` (host-local; not yet copied to immutable storage).

## Checksums

From that directory's `SHA256SUMS`:

| File | SHA-256 |
|---|---|
| `canary-deployment.json` | `d52e3ee3e2bc5a2b7e32ab54daab26f866e7521ab2c17ba5a41bc4fac1f27938` |
| `canary-statistics.json` | `99d0510f83cc91c4c009c100e13f6258f7d30bd27a8b5fc5fe1f6c453319e709` |
| `serial.log` | `f30da3c0c8e2b131a514cd3fec57a27372b05b547e9e6f948ae903886d39ae41` |
| `summary.json` | `8773ae14944e318952dfca957270f31e0c420ddd3b4c1a4a1b2a4f525ec612b6` |

## Open Points

- Artifacts are unsigned and the client does not enforce `ArtifactVerifyKey`; signing requires the isolated `release` runner and key described in `docs/08-security/artifact-signing.md`.
- `~/mender/mender.env` sets `MENDER_SERVER_TAG=main`, so server images are not pinned to 3.8.5.
- Evidence is on the build host only; publish it to the `release-evidence` MinIO bucket before external use.
- QEMU validation is not physical-board validation.

## Reviewer Conclusion

Pending reviewer sign-off.
