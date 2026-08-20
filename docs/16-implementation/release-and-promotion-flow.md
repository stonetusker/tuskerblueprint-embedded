---
id: IMPL-019
title: Release and Promotion Flow
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Security Reviewer
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ARCH-008
  - SEC-REQ-003
verified_by:
  - TEST-OTA-001
  - TEST-SEC-004
---

# Release and Promotion Flow

## Build and Test

The release-candidate workflow accepts a semantic version and full commit. It verifies that the commit is an ancestor of `origin/main`, builds with `kas/mender.yml`, and runs the exact release root filesystem in direct QEMU.

The release test does not substitute the debug-enabled CI image. It uses the release ext4 output and validates health, version, and sensor behavior over the forwarded application port.

## SBOM and Unsigned Candidate

Yocto `create-spdx` executes during the original release build. The collection step copies existing SPDX output; it does not rebuild. The unsigned Mender artifact and all evidence are uploaded as a short-retention workflow artifact.

## Isolated Signing

A second job runs on the `release` runner under the protected `firmware-signing` environment. The runner:

- has no Docker group membership
- does not share the Yocto cache
- owns the signing key with mode 0600
- receives verified `mender-artifact` and MinIO client binaries
- signs the exact downloaded candidate
- recalculates its checksum
- publishes the signed candidate to immutable release evidence storage

## Promotion

The Mender promotion workflow runs under the separate `firmware-production` environment. It downloads a candidate by immutable URI, verifies the caller-supplied SHA-256, uploads the signed artifact, and creates only the canary deployment.

Fleet expansion is deliberately separate from candidate creation and signing.

## Immutable Publication Controls

The signing job creates an isolated publication directory containing only the signed Mender artifact, its checksum, the release manifest, SBOM evidence, and direct-QEMU test evidence. The unsigned artifact is not published to the release-evidence namespace.

`publish_candidate.py` fails when the target version-and-commit namespace already exists. This prevents a later job from overwriting an accepted candidate while retaining the same URI. Promotion downloads one exact object and verifies its caller-supplied SHA-256 digest before contacting Mender.
