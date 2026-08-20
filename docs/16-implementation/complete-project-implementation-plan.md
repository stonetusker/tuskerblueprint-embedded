---
id: IMPL-PLAN-001
title: Complete Project Implementation Plan
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - GOV-001
  - PRD-003
verified_by:
  []
---

# Complete Project Implementation Plan

## Objective

Build Project C as a reproducible embedded delivery platform on Ubuntu 24.x using Yocto, GitHub Actions, QEMU, MinIO, Mender, Jenkins, and constrained AI-assisted diagnostics.

## Delivery sequence

| Phase | Outcome | Primary paths | Exit gate |
|---|---|---|---|
| 0 | Host and compatibility baseline | `scripts/bootstrap-ubuntu24.sh`, `docs/16-implementation/external-version-pinning.md` | Host doctor passes; third-party versions are pinned |
| 1 | Specification baseline | `docs/00-governance/`, `docs/03-requirements/` | Requirements and tests are traceable |
| 2 | SensorNode application | `app/sensornode/` | Go unit and endpoint tests pass |
| 3 | Yocto layer | `meta-sensornode/`, `kas/` | CI image builds and boots |
| 4 | Build acceleration | `cache/`, `infra/compose/minio/` | Clean/cached benchmark is recorded |
| 5 | CI gate | `.github/workflows/` | Main build and QEMU test pass |
| 6 | Release controls | `scripts/generate-sbom.sh`, `tools/generate_release_manifest.py` | SBOM, checksums and exact artifact identity exist |
| 7 | OTA | `kas/mender.yml`, `mender/` | Canary installs, reboots and commits |
| 8 | Rollback | `mender/demo-scenarios/` | Unhealthy update returns to last known good |
| 9 | Jenkins | `ci/jenkins/`, `infra/compose/jenkins/` | Diagnostic job runs common scripts |
| 10 | AI diagnostics | `ci/jenkins/mcp/`, `docs/10-ai-governance/` | AI can read evidence but cannot approve or execute |
| 11 | Operations | `infra/ansible/`, `docs/09-operations/` | Reprovision, backup and recovery are exercised |
| 12 | Public release | `docs/11-content-series/` | Claims map to evidence and Git tags |

## Work breakdown

### Phase 0: host and dependency control

1. Run `scripts/bootstrap-ubuntu24.sh`.
2. Run `scripts/doctor-ubuntu24.sh`.
3. Select exact external tool/container versions using `docs/16-implementation/external-version-pinning.md`.
4. Generate `kas/source-lock.yml` with `make source-lock`.
5. Commit the lock before enabling release workflows.

### Phase 1: specification gate

Run:

```bash
make docs-check
make yaml-check
```

Do not implement a behavior that has no requirement or test identifier.

### Phase 2: application

Run:

```bash
make app-test
make app-integration
```

The service contract is controlled by `docs/06-interface-specifications/application-api.md`.

### Phase 3: Yocto

Build `sensornode-image-ci` first. Do not begin Mender until the non-OTA image is stable.

```bash
make builder-image
KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci make yocto-build
make qemu-test
```

### Phase 4: cache

Deploy MinIO, create least-privilege identities, run one clean build and one cache-reuse build, then store the benchmark evidence.

### Phase 5: GitHub Actions

Provision the build runner with label `yocto`. Configure MinIO cache credentials. Merge only after the self-hosted build and QEMU gate are stable.

### Phase 6: release control

Create an isolated release runner with label `release`. It owns only signing and publication tools. It must not perform the Yocto build. The release workflow downloads the already-tested candidate and signs the exact file.

### Phase 7 and 8: OTA and rollback

Lock a compatible Mender bundle and `meta-mender` commit. Prove one-device install/commit/rollback before creating a fleet. Only then scale to three devices.

### Phase 9 and 10: Jenkins and AI

Jenkins runs the same `scripts/build-image.sh` and `scripts/run-qemu-tests.sh`. AI receives read-only build evidence. Jenkins itself enforces the approval gate through the `input` step.

### Phase 11: operations

Exercise backup, restore, runner replacement, cache cleanup, Jenkins recovery, Mender recovery, and signing-key revocation.

### Phase 12: publication

Use only measured values in the episodes. Never present QEMU as physical-board validation or the AI as autonomous release authority.

## Critical path

The critical dependency is the Mender/Yocto compatibility spike. Everything before OTA can be implemented and demonstrated independently. Do not block application, Yocto, cache, CI, or QEMU work while Mender is being validated.

## Definition of complete

Project C is complete when `docs/16-implementation/end-to-end-acceptance.md` passes and every Must requirement in `docs/02-product/product-requirements.md` has reviewed evidence.
