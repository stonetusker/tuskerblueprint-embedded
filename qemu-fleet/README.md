---
id: DIR-QEMU-FLEET-README-MD
title: Qemu-Fleet Documentation
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

# Qemu-Fleet

The virtual fleet follows COMP-011, the QEMU fleet runbook, and rollback tests.

## Baseline Mode

`launch/qemu-device.sh` directly boots the Yocto `Image` kernel and ext4 root filesystem with a Cortex-A53 CPU model. This validates the application and operating system.

## Mender Mode

Set `DISK_IMAGE` to a Mender `.uefiimg` instead of `KERNEL_IMAGE`/`ROOTFS_IMAGE`. The launcher boots it through UEFI firmware (`qemu-efi-aarch64`, `-machine virt,acpi=off`) and the Mender GRUB integration, so A/B install, commit, and rollback behave as on a device (`TEST-SPIKE-003`).

| Variable | Default | Meaning |
|---|---|---|
| `DISK_IMAGE` | — | Factory disk image; copied to `state/<name>/disk.img` on first launch |
| `RESET_DISK` | `0` | `1` re-copies the factory image, discarding installed updates |
| `QEMU_EFI_FIRMWARE` | `/usr/share/qemu-efi-aarch64/QEMU_EFI.fd` | UEFI firmware |

The disk persists across launches because it holds the installed slot. Each device gets an SMBIOS serial equal to `DEVICE_NAME` (its SensorNode and Mender `device_id`) and a stable MAC derived from it.
