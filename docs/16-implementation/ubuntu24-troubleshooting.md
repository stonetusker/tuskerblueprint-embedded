---
id: IMPL-U24-TRBL-001
title: Ubuntu 24 Troubleshooting
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  []
verified_by:
  []
---

# Ubuntu 24 Troubleshooting

## Docker permission denied

```bash
sudo usermod -aG docker "$USER"
newgrp docker
docker info
```

## Yocto build is killed

Check memory and kernel logs:

```bash
free -h
journalctl -k --since '-10 min' | grep -i -E 'oom|killed process'
```

Lower `BB_NUMBER_THREADS` and `PARALLEL_MAKE` in `config/project.env`.

## Disk full

```bash
du -sh build cache artifacts
df -h .
```

Use the cache-retention policy before deleting sstate. Never delete release evidence as cache cleanup.

## QEMU is slow

On x86_64, ARM64 uses TCG and is expected to be slower. On aarch64 verify `/dev/kvm` permission. Force TCG for consistency with:

```bash
QEMU_ACCEL=tcg scripts/run-release-qemu-tests.sh
```

## QEMU health timeout

Review `artifacts/release-qemu/serial.log` and `artifacts/release-qemu/qemu.stderr.log`. Check kernel root device, DHCP, systemd service state, and application startup.

## `mender-full` parse or build error

The selected meta-mender revision is incompatible with the current Yocto lock. Stop and resolve the compatibility spike; do not remove the OTA class merely to make CI green.

## Mender server install fails

Run `docker compose config` against the exact upstream bundle. Confirm `mender_bundle_compose_relative` matches the selected archive. Do not substitute a hand-written topology.

## Jenkins cannot build

Verify the job is executing on the host agent with label `yocto-vps8`, Docker access works for `jenkins-agent`, and the cache directory is writable. The controller itself should not execute Yocto builds.
