---
id: IMPL-QEMU-001
title: QEMU Validation Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - PRD-REQ-004
verified_by:
  []
---

# QEMU Validation Step by Step

Two QEMU paths exist.

## Yocto testimage gate

```bash
make qemu-test
```

This uses Yocto's `runqemu` integration and custom OEQA cases. It is the authoritative CI gate for `sensornode-image-ci`.

## Direct release-rootfs gate

After a release build:

```bash
scripts/run-release-qemu-tests.sh
```

The script finds the exact release `Image` and ext4 root filesystem, starts `qemu-fleet/launch/qemu-device.sh`, waits for `/health`, and runs `tests/qemu/`.

### Host acceleration

- `x86_64`: defaults to TCG with `cortex-a53`
- `aarch64` with `/dev/kvm`: defaults to KVM and CPU `host`
- Override with `QEMU_ACCEL=tcg` or `QEMU_CPU=cortex-a53`

Ports are forwarded only on `127.0.0.1`.

## Evidence

Review:

- `artifacts/release-qemu/serial.log`
- `artifacts/release-qemu/junit.xml`
- `artifacts/deploy/qemuarm64/SHA256SUMS`

QEMU proves software image behavior on a virtual ARM64 target. It does not prove board-specific peripherals, timings, power, thermal behavior, or safety properties.
