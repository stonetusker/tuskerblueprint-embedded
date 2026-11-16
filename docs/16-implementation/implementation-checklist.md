---
id: IMPL-CHECK-001
title: Project C Implementation Checklist
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-11-16
traces_to:
  []
verified_by:
  []
---

# Project C Implementation Checklist

## Host

- [ ] Ubuntu 24.x detected
- [ ] Docker and Compose v2 operational
- [ ] QEMU ARM installed
- [ ] At least 8 GiB RAM and sufficient disk
- [ ] `scripts/doctor-ubuntu24.sh` has no failures

## Source and specifications

- [ ] `make validate` passes
- [ ] `kas/source-lock.yml` generated and committed
- [ ] All external container/binary versions pinned with checksums/digests

## Embedded image

- [ ] SensorNode Go tests pass
- [ ] CI Yocto image builds
- [ ] QEMU OEQA gate passes
- [ ] Release image direct-QEMU test passes
- [ ] SPDX evidence generated

## Cache

- [ ] MinIO started
- [ ] Four least-privilege identities created
- [ ] Clean build measured
- [ ] Cached build measured
- [ ] Evidence summary updated

## CI and release

- [ ] Jenkins `yocto-vps8` agent online and jobs created
- [ ] Separate `release` runner registered
- [ ] `firmware-signing-approvers` group has members
- [ ] `firmware-production-approvers` group has members
- [ ] `sensornode-ci` passes on `main`
- [ ] Release candidate is immutable and signed

## OTA

- [ ] Mender server bundle pinned and deployed
- [ ] `meta-mender` commit locked
- [ ] One QEMU device registers
- [ ] Canary installs and commits update
- [ ] Pipeline prevention demonstrated
- [ ] Device rollback demonstrated

## Jenkins and AI

- [ ] Jenkins controller deployed
- [ ] Host build agent labeled `yocto-vps8`
- [ ] Diagnostic job created
- [ ] AI account is read-only
- [ ] MCP tool allowlist verified
- [ ] Unauthorized tool tests denied
- [ ] Human approval enforced in Jenkins

## Operations and publication

- [ ] Backup/restore exercised
- [ ] Signing-key revocation documented
- [ ] Secrets scan passes
- [ ] Public claims reviewed against evidence
- [ ] Six episode tags prepared
