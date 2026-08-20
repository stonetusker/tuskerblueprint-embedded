---
id: IMPL-014
title: Command Reference
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---


# Command Reference

```bash
make validate
make app-test
make app-build
make yocto-build
make qemu-test
make benchmark
make release-manifest
make review
```

```bash
KAS_FILE=kas/development.yml IMAGE=sensornode-image-dev scripts/build-image.sh
KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci scripts/run-qemu-tests.sh
KAS_FILE=kas/release.yml IMAGE=sensornode-image-release scripts/generate-sbom.sh
```
