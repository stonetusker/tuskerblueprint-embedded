---
id: IMPL-MANIFEST-002
title: Implementation Asset Manifest
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
  - TEST-DOC-001
---

# Implementation Asset Manifest

## Source and Configuration Inventory

| Asset class | Count |
|---|---:|
| Markdown documents | 217 |
| Yocto metadata | 12 |
| Shell scripts | 32 |
| GitHub workflows | 6 |
| Python source files | 21 |
| Go source files | 2 |
| Ansible/YAML files | 36 |

## Ubuntu 24 Portability

- `scripts/bootstrap-ubuntu24.sh`
- `scripts/doctor-ubuntu24.sh`
- `scripts/build-builder-image.sh`
- `config/project.env.example`
- `config/third-party-pins.env.example`
- `tools/lock_sources.py`
- `tools/validate_source_lock.py`

## Embedded Product

- SensorNode Go source under `app/sensornode/`
- Complete `meta-sensornode/` Yocto layer
- `kas/` development, CI, release, broken-demo, and Mender configurations
- OEQA runtime tests and host-side QEMU tests

## Delivery Platform

- GitHub Actions workflows under `.github/workflows/`
- Jenkins pipeline and job template under `ci/jenkins/`
- MinIO least-privilege cache/release configuration
- Mender server bundle adapter and client/OTA configuration
- Ansible roles for host, runners, Jenkins, MinIO, Mender, QEMU fleet, and reverse proxy

## Step-by-Step Documentation

The ordered Ubuntu 24 implementation path starts at `docs/16-implementation/00-ubuntu24-quickstart.md` and is completed by `docs/16-implementation/end-to-end-acceptance.md`.
