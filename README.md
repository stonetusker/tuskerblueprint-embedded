---
id: DOC-ROOT-001
title: TuskerBlueprint Embedded Specification Repository
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---

# TuskerBlueprint Embedded

TuskerBlueprint Embedded is Stonetusker Systems' specification-driven reference architecture for embedded Linux delivery. It demonstrates a complete SensorNode lifecycle using Yocto/OpenEmbedded, shared build caching, GitHub Actions, QEMU validation, Mender OTA, Jenkins diagnostics, and governed AI assistance.

## Repository Purpose

This repository pack defines the approved engineering intent before implementation. It is designed to be copied into the future `tuskerblueprint-embedded` Git repository and evolved through reviewed pull requests.

## Governing Rule

> Specifications define intent. Deterministic automation verifies implementation. Immutable evidence proves results. AI assists diagnosis and recommendation. Humans authorize consequential actions.

## Start Here

1. Read [Project Charter](docs/00-governance/project-charter.md).
2. Read [Product Requirements](docs/02-product/product-requirements.md).
3. Review [Architecture Overview](docs/04-architecture/architecture-overview.md).
4. Review [System Requirements](docs/03-requirements/system-requirements.md).
5. Use the [Development Lifecycle](docs/00-governance/development-lifecycle.md).
6. Consult the [Traceability Matrix](docs/13-traceability/requirement-traceability-matrix.md).

## Controlled Documentation

All controlled project documentation is Markdown. Executable implementation will use native formats such as BitBake recipes, YAML, shell, Python, Go, Dockerfiles, and Jenkinsfiles, with every implementation component traced to a Markdown specification.

## Project Boundary

Project C is delivered before Project A and Project B. It is operationally standalone but architected for later integration with shared Ansible, k3s, Argo CD, Harbor, MinIO, observability, and secret-management services.

## Implementation Baseline

This version includes an implementation-ready starter repository rather than specifications alone:

- SensorNode Go application with tests and controlled failure modes
- `meta-sensornode` Yocto layer
- Development, CI, release, and broken-demo images
- Custom OEQA runtime tests
- `kas` build manifests
- Yocto builder container
- Shared-cache synchronization scripts
- GitHub Actions workflows
- Direct QEMU fleet launcher and host tests
- Mender artifact, signing, health, and canary wrappers
- Jenkins diagnostic pipeline with enforced human approval
- Ansible and container infrastructure scaffolding
- Automated repository review tools

### Fast Validation

```bash
python3 -m venv .venv
.venv/bin/pip install -r tools/requirements.txt
make validate
```

### Important Compatibility Boundary

The repository is syntactically and structurally reviewed, and the Go application is locally tested. The exact Yocto/Mender/Jenkins-MCP version combination still requires the documented live Phase 0 compatibility spike before being represented as validated.

## Ubuntu 24.04 Implementation Path

For a clean Ubuntu 24.x machine, start with [`docs/16-implementation/00-ubuntu24-quickstart.md`](docs/16-implementation/00-ubuntu24-quickstart.md).

The reviewed full implementation sequence is in [`docs/16-implementation/complete-project-implementation-plan.md`](docs/16-implementation/complete-project-implementation-plan.md). It covers host preparation, immutable source locking, SensorNode, Yocto, shared cache, QEMU, GitHub Actions, signing, Mender OTA, rollback, Jenkins, MCP/Claude governance, and end-to-end acceptance.

Quick host verification:

```bash
scripts/bootstrap-ubuntu24.sh
newgrp docker
scripts/doctor-ubuntu24.sh
make validate
make source-lock
make builder-image
make yocto-build
make qemu-test
```

Release workflows intentionally require a committed `kas/source-lock.yml`; the first source lock must be generated online from the official upstream repositories rather than fabricated in this package.
