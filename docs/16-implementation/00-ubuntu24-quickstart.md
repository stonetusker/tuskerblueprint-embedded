---
id: IMPL-U24-000
title: Ubuntu 24.04 Quick Start
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - PRD-REQ-001
  - PRD-REQ-010
verified_by:
  []
---

# Ubuntu 24.04 Quick Start

This is the shortest supported path from a clean Ubuntu 24.x machine to a running SensorNode application and then to a Yocto/QEMU build.

## 1. Minimum host

Supported host architectures are `x86_64` and `aarch64`. Use at least 8 GiB RAM, 16 GiB is recommended, and 24 GiB is preferred for comfortable Yocto work. Keep at least 120 GiB free disk for repeated builds and caches.

## 2. Clone and bootstrap

```bash
git clone <your-repository-url> tuskerblueprint-embedded
cd tuskerblueprint-embedded
scripts/bootstrap-ubuntu24.sh
```

If Docker group membership was added by the bootstrap:

```bash
newgrp docker
scripts/doctor-ubuntu24.sh
```

Expected result: no `FAIL` lines. Warnings about TCG or missing source lock are acceptable before the first build.

## 3. Verify the application first

```bash
make app-test
make app-integration
```

## 4. Create immutable upstream source lock

This step requires internet access to the official Git remotes.

```bash
make source-lock
make source-lock-check
git add kas/source-lock.yml
git commit -m "build: lock Yocto and Mender source revisions"
```

Do not create a release from moving branches.

## 5. Build the Yocto builder image

```bash
make builder-image
```

## 6. Build the CI image

```bash
make yocto-build
```

Outputs appear under `artifacts/deploy/qemuarm64/`.

## 7. Run QEMU validation

```bash
make qemu-test
```

This runs Yocto `testimage` and the custom OEQA test in `meta-sensornode/lib/oeqa/runtime/cases/sensornode.py`.

## 8. Continue the platform implementation

Follow these documents in order:

1. `docs/16-implementation/complete-project-implementation-plan.md`
2. `docs/16-implementation/minio-cache-step-by-step.md`
3. `docs/16-implementation/github-actions-step-by-step.md`
4. `docs/16-implementation/jenkins-step-by-step.md`
5. `docs/16-implementation/mender-server-step-by-step.md`
6. `docs/16-implementation/mender-ota-step-by-step.md`
7. `docs/16-implementation/end-to-end-acceptance.md`
