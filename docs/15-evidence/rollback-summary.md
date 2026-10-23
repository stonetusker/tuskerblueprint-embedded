---
id: EVID-004
title: Rollback Summary
status: In Review
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-10-23
traces_to:
  - OTA-REQ-005
verified_by:
  - TEST-ROLLBACK-002
---

# Rollback Summary

## Scope

This summary records device recovery: an installed but unhealthy update returns to the last known good root filesystem. CI prevention (TEST-ROLLBACK-001) is not recorded yet; the `FAILURE_DRILL` Jenkins parameter exists for it.

## Environment

Same host, device, server, and client as `docs/15-evidence/ota-deployment-summary.md`. The device was already running the committed canary v102.

## Source and Artifact Identifiers

| Role | Artifact name | SHA-256 |
|---|---|---|
| Last known good | `sensornode-0.3.0-102-ff2bd03` | `0734bb8152b0b1561b47a959f05f8fe420c05e72aa15b5b7b3e5db8852e78c3f` |
| Unhealthy candidate | `sensornode-0.3.0-103-ff2bd03-broken` | `fae227baa3d0e4fd9639c3317aed837889fc60d859c2427b3c771fd4b9eb5cf4` |

The unhealthy candidate is `sensornode-image-release-broken`: the release image with `SENSORNODE_FAILURE_MODE=health`, so `/health` returns HTTP 503 while the service stays active.

## Procedure

The second half of `mender/demo-scenarios/run-ota-e2e.sh`: deploy the unhealthy candidate to the canary only, wait for the deployment to finish, and check `/version`.

## Expected Result

Install and reboot succeed. `ArtifactCommit_Enter_50_sensornode-health` fails, Mender refuses the commit, reboots into the previous slot, reports `failure`, and the device reports `0.3.0-102-ff2bd03`.

## Actual Result

Device log of deployment `5bc54e59-244a-40b8-833c-26bc5daa16f9`:

```text
13:10:46 info: Calling `reboot` command and waiting for system to restart.
13:11:14 info: Running State Script: /var/lib/mender/scripts/ArtifactCommit_Enter_50_sensornode-health
13:13:19 info: Collected output (stderr) while running script: sensornode health gate failed after 120s; refusing commit
13:13:19 error: Received error: (NonZero exit code error: Received error code: 1) when running the State Script scripts ArtifactCommitEnter
13:13:23 info: Calling `reboot` command and waiting for system to restart.
```

Deployment statistics `failure: 1`, `success: 0`. After the rollback reboot `/version` reported `0.3.0-102-ff2bd03` at 13:14:05, about 4 minutes after the deployment was created. Only the canary was targeted, so no wider rollout started.

## Evidence URI

`subeesh@192.168.0.109:/home/subeesh/tuskerblueprint-embedded/artifacts/ota/20261023T130809Z/` (`rollback-*.json`, `rollback-device.log`, `serial.log`).

## Checksums

| File | SHA-256 |
|---|---|
| `rollback-deployment.json` | `9cba4f2b5e16dc057690cc0147872ab0440337dadf617cebfaef4b3d3afa7265` |
| `rollback-device.log` | `5b9a558ad5ce3654af1b0a11348999ce730f5afd51d002026de0aac8d36214e6` |
| `rollback-statistics.json` | `37a2bd592098650d9d182728380f481637c727d86020f213fb85829d2b5a7e5f` |

## Reviewer Conclusion

Pending reviewer sign-off.
