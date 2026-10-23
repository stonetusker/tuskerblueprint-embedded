---
id: EVID-002
title: QEMU Test Summary
status: In Review
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-10-23
traces_to:
  - QEMU-REQ-001
  - QEMU-REQ-003
verified_by:
  - TEST-QEMU-001
  - TEST-QEMU-003
---

# QEMU Test Summary

## Scope

This summary records boot, systemd, application, network, and version results for the CI image (OEQA `testimage`) and the release disk image (direct QEMU harness).

## Environment

Ubuntu 24.04.4 LTS x86_64 host `192.168.0.109`, QEMU 8.2.2 (TCG), Yocto scarthgap with `meta-mender` `720d1d1c`, builder container `stonetusker/yocto-builder:0.3.0`. Source `ff2bd03` plus the uncommitted `fix/release-qemu-ota` changes of 2026-10-23.

## CI Image: `sensornode-image-ci`

Procedure: `KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci scripts/build-image.sh && scripts/run-qemu-tests.sh` (2026-10-23 12:57–13:01 UTC).

Result: `ping`, `ssh`, `systemd`, and `sensornode` suites passed. 14 tests passed; `test_systemd_coredump_minidebuginfo` and `test_systemd_disable_enable_ro` were skipped by their upstream preconditions. No failures.

Before this run, `systemd.SystemdBasicTests.test_systemd_failed` failed because `mender-grow-data` and `mender-configure-apply-device-config` failed on the bare-rootfs `testimage` boot. They are now skipped by `ConditionPathExists`/`ConditionPathIsMountPoint` drop-ins when no Mender data partition is present.

## Release Image: `sensornode-image-release`

Procedure: `DISK_IMAGE=<101>.uefiimg EXPECTED_IMAGE_VERSION=0.3.0-101-ff2bd03 scripts/run-release-qemu-tests.sh` (2026-10-23 13:07:44–13:08:09 UTC). The full GPT disk boots through UEFI and Mender GRUB (`root=/dev/vda2`), mounts `/boot/efi` and `/data`, and gets DHCP on `enp0s2`.

Result: `tests/qemu` 3 passed, 0 failed (`junit.xml`). `/version` reported `image_version` `0.3.0-101-ff2bd03` and `device_id` `sensornode-release-test` from the SMBIOS serial.

Previously the same test booted `rootfs.ext4` directly and reached emergency mode, because fstab referenced `/dev/mmcblk0p1` and `/dev/mmcblk0p4`.

## Evidence URI

- `subeesh@192.168.0.109:/home/subeesh/tuskerblueprint-embedded/artifacts/release-qemu/` (`junit.xml`, `serial.log`)
- `subeesh@192.168.0.109:/home/subeesh/tuskerblueprint-embedded/artifacts/oeqa/`
- Factory disk SHA-256 `164128f931c7260bb126423a2f3dd81cf7dcbc6c8a7bbafa43bd9117167a2bd1`

## Reviewer Conclusion

Pending reviewer sign-off.
