---
id: IMPL-017
title: Yocto Layer Technical Walkthrough
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - COMP-003
  - COMP-004
verified_by:
  - TEST-BUILD-001
  - TEST-QEMU-001
---

# Yocto Layer Technical Walkthrough

## Layer Registration

`conf/layer.conf` adds recipe globs, declares the `sensornode` collection, assigns priority 8, records the Scarthgap compatibility candidate, and requires OE-Core plus `meta-oe`.

The compatibility string is not a substitute for a successful build. It is accepted only after the Phase 0 build locks exact commits.

## Distribution

`sensornode.conf` derives from Poky while changing policy:

- systemd is the init manager
- graphical, audio, Bluetooth, and NFC features are removed
- package output uses IPK for the reference environment
- build history and build statistics are enabled
- image version is an explicit project variable

## Images

### Development

Adds SSH, debugging, tracing, and profiling tools. It is never promoted through Mender.

### CI

Adds SSH and `testimage`. It is optimized for deterministic OEQA validation rather than release hardening.

### Release

Removes SSH and debug features, locks the root account, enables SPDX through the release `kas` configuration, and contains only the runtime package group.

### Broken Demo

Uses the CI image but injects `SENSORNODE_FAILURE_MODE=health`. The image can boot while the application health gate fails, proving that a successful BitBake task alone is insufficient.

## Application Recipe

The recipe fetches the monorepo's Go module and command source through `FILESEXTRAPATHS`. It uses Yocto's Go class, creates an unprivileged system user, injects version metadata through linker flags, installs the binary and systemd unit, and installs a startup health script.

The systemd unit uses:

- `NoNewPrivileges=true`
- empty capability bounding and ambient sets
- `ProtectSystem=strict`
- `ProtectHome=true`
- systemd-managed state and runtime directories
- restart and startup-rate controls

## Image Identity

`sensornode-release.bb` writes `/etc/sensornode/image-version` and `/etc/sensornode/release.json`. The application reads the same image version and returns it through `/version`, creating a traceable comparison between build metadata and the running guest.

## Runtime Tests

The custom OEQA test:

1. waits for SSH through the standard target abstraction
2. verifies `sensornode.service` is active
3. verifies `/health` returns `healthy`
4. compares `/version` with `/etc/sensornode/image-version`
5. fails on mandatory failed systemd units

This test is run through `bitbake -c testimage sensornode-image-ci`.
