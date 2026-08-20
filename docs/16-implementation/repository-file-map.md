---
id: IMPL-016
title: Repository File Map
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  - TEST-DOC-001
---

# Repository File Map

## Product Source

| Path | Responsibility |
|---|---|
| `app/sensornode/cmd/sensornode/main.go` | HTTP application, health, version, sensor simulation, structured logging |
| `app/sensornode/cmd/sensornode/main_test.go` | Application unit tests |
| `app/sensornode/go.mod` | Go module and language baseline |

## Yocto

| Path | Responsibility |
|---|---|
| `meta-sensornode/conf/layer.conf` | Layer discovery, priority, dependencies, release compatibility |
| `meta-sensornode/conf/distro/sensornode.conf` | SensorNode distribution policy |
| `meta-sensornode/recipes-core/images/` | Development, CI, release, and failure image definitions |
| `meta-sensornode/recipes-core/packagegroups/` | Runtime package policy |
| `meta-sensornode/recipes-core/sensornode-release/` | Image identity files |
| `meta-sensornode/recipes-sensornode/sensornode-app/` | Application build, user, systemd unit, health script |
| `meta-sensornode/lib/oeqa/runtime/cases/` | QEMU runtime test gate |
| `meta-sensornode/recipes-mender/` | Mender client boundary and pre-commit health check |
| `kas/` | Reproducible source and build configurations |

## Delivery Automation

| Path | Responsibility |
|---|---|
| `scripts/build-image.sh` | Provider-independent Yocto build entry point |
| `scripts/run-qemu-tests.sh` | CI image testimage/OEQA gate |
| `scripts/run-release-qemu-tests.sh` | Exact release root filesystem test |
| `scripts/cache-sync.sh` | MinIO cache synchronization with trust control |
| `scripts/collect-build-outputs.sh` | Immutable deploy-output collection and hashes |
| `scripts/generate-sbom.sh` | SPDX evidence collection |
| `scripts/create-mender-artifact.sh` | Root filesystem to Mender artifact conversion |
| `.github/workflows/` | Pull request, main, nightly, signing, and promotion orchestration |
| `ci/jenkins/Jenkinsfile` | Parallel diagnostic build and human approval |

## Platform

| Path | Responsibility |
|---|---|
| `infra/ansible/` | VPS8 provisioning and identity separation |
| `infra/compose/minio/` | Shared cache and evidence object storage |
| `infra/compose/jenkins/` | Jenkins controller only |
| `infra/compose/reverse-proxy/` | TLS ingress for restricted services |
| `qemu-fleet/` | Direct QEMU device launch and service definitions |
| `mender/` | Artifact and rollback scenario assets |

## Governance and Review

| Path | Responsibility |
|---|---|
| `docs/` | Controlled specification set |
| `tools/validate_*.py` | Specification, traceability, YAML, workflow, link, and policy validation |
| `tools/review_repository.py` | Reproducible principal-engineer review report |
| `MANIFEST.sha256` | Package-integrity manifest generated before distribution |
