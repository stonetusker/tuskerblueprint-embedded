---
id: IMPL-009
title: Local Development Guide
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
  []
---


# Local Development Guide

## Fast Validation

```bash
python3 -m venv .venv
.venv/bin/pip install -r tools/requirements.txt
make validate
```

## Application

```bash
make app-test app-build
./bin/sensornode --listen :8080 --image-version-file app/sensornode/image-version
```

## Yocto

Build the builder image, then use `scripts/build-image.sh`. Allocate at least 16 GiB RAM and substantial SSD storage. The first build may require hundreds of gigabytes once downloads, sstate, work, and artifacts are included.
