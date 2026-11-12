---
id: IMPL-MENDER-OTA-002
title: Mender OTA Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - PRD-REQ-005
verified_by:
  []
---

# Mender OTA Step by Step

## 1. Set the server URL

Copy `config/project.env.example` to `config/project.env` and set the real HTTPS endpoint:

```text
MENDER_SERVER_URL=https://mender.example.com
```

## 2. Build the Mender-capable release image

```bash
make source-lock-check
SENSORNODE_VERSION=1.0.0 \
SOURCE_LOCK_CONFIG=kas/source-lock.yml \
KAS_FILE=kas/release.yml \
IMAGE=sensornode-image-release \
scripts/build-image.sh
```

`kas/release.yml` composes `kas/base.yml` and `kas/mender.yml`, so the image gets `meta-mender-core`, `meta-mender-qemu`, `mender-full`, the client, `sensornode-mender-config`, and release-only SPDX generation. `kas/mender.yml` alone has no `machine`, `distro`, or `target` and cannot be built standalone.

`kas/mender.yml` sets the values the QEMU target depends on:

| Variable | Value | Why |
|---|---|---|
| `MENDER_STORAGE_DEVICE` | `/dev/vda` | QEMU `virt` exposes the disk as virtio-blk; the meta-mender default `/dev/mmcblk0` leaves `/boot/efi` and `/data` unmountable and boots into emergency mode. |
| `MENDER_ARTIFACT_NAME` | `sensornode-${SENSORNODE_IMAGE_VERSION}` | Every build must have a unique artifact name or Mender reports "already installed". |
| `MENDER_DEMO_HOST_IP_ADDRESS` | `10.0.2.2` | Adds `docker.mender.io` and `s3.docker.mender.io` to the device `/etc/hosts`, pointing at the host through QEMU user networking. |

`SENSORNODE_IMAGE_VERSION` comes from `SENSORNODE_VERSION`, `BUILD_NUMBER`/`GITHUB_RUN_NUMBER` and `GIT_COMMIT`/`GITHUB_SHA`. These reach BitBake only because `kas/base.yml` declares them under `env:`; kas drops undeclared variables.

## 3. Validate the exact release disk image

```bash
scripts/run-release-qemu-tests.sh
```

The test boots the complete `sensornode-image-release-qemuarm64.uefiimg` (GPT: EFI boot, rootfs A, rootfs B, data) through UEFI firmware (`qemu-efi-aarch64`) and the Mender GRUB integration, so partition layout, fstab, and slot selection are exercised exactly as on a device. `qemu-fleet/launch/qemu-device.sh` uses `-machine virt,acpi=off` because the Yocto kernel needs the device tree from firmware. It also sets a per-device SMBIOS serial, which becomes the SensorNode and Mender `device_id`.

## 4. Create/sign candidate

The preferred path is `.github/workflows/release-candidate.yml`. It builds and tests on the Yocto runner, then signs on the isolated release runner.

## 5. Upload and canary

Use `.github/workflows/promote-mender.yml` with the immutable candidate URI, expected SHA-256, artifact name, and only the canary device ID.

## 6. Device health

`meta-sensornode/dynamic-layers/mender/recipes-mender/sensornode-mender-config/files/ArtifactCommit_Enter_50_sensornode-health` verifies the SensorNode service, `/health`, and the absence of failed units for up to 120 seconds after the update reboot. The recipe inherits `mender-state-scripts`, so the script is embedded in the `.mender` artifact. A non-zero exit refuses the commit and Mender boots the previous root filesystem.

## 7. Prove install, commit, and rollback end to end

Build a factory image and two candidates with distinct build numbers, then run the scenario against one QEMU canary:

```bash
KAS_FILE=kas/release.yml BUILD_NUMBER=101 IMAGE=sensornode-image-release scripts/build-image.sh
# keep the factory .uefiimg and .mender, then:
KAS_FILE=kas/release.yml BUILD_NUMBER=102 IMAGE=sensornode-image-release scripts/build-image.sh
KAS_FILE=kas/release.yml BUILD_NUMBER=103 IMAGE=sensornode-image-release-broken scripts/build-image.sh

MENDER_USER=... MENDER_PASSWORD=... \
MENDER_CA_CERT=~/mender/integration-3.8.5/cert/cert.crt \
FACTORY_DISK=<101>.uefiimg GOOD_ARTIFACT=<102>.mender BROKEN_ARTIFACT=<103-broken>.mender \
mender/demo-scenarios/run-ota-e2e.sh
```

The script boots the factory disk, accepts the device (including a new key from a fresh disk), deploys the healthy candidate and expects `success` and the new `/version`, then deploys `sensornode-image-release-broken` (`SENSORNODE_FAILURE_MODE=health`) and expects `failure` and the previous version. API responses, device deployment logs, serial console, and `SHA256SUMS` are written to `artifacts/ota/<run>/`.

The device app is forwarded to `127.0.0.1:18091` (`APP_PORT`) on the host only while the QEMU device runs; the script stops it on exit unless `KEEP_DEVICE=1` is set. See [Demo Guide](demo-guide.md#the-device-app-port-18091).

The self-hosted server must hand out presigned artifact URLs that devices can resolve. With the bundled MinIO, set `DEPLOYMENTS_AWS_EXTERNAL_URI: https://s3.docker.mender.io` on `mender-deployments`. Otherwise downloads fail with `Host not found ... http://minio:9000/...`.

## 8. Expand rollout

Only after the canary reports the expected artifact and remains healthy should the pilot and fleet cohorts be started.
