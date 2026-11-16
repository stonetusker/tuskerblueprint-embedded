---
id: SEC-ARCH-004
title: Artifact Signing
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-11-16
traces_to:
  - SEC-REQ-DOC
verified_by:
  []
---

# Artifact Signing

## Policy

Mender artifacts are signed with a protected release key. CI build jobs do not receive unrestricted long-lived signing authority. Verification occurs before upload and on the device path where supported.

## Required Controls

- Least privilege
- Authentication and authorization
- Audit logging
- Secret redaction
- Fail-closed behavior for release controls
- Documented recovery and revocation

## Lab Implementation

| Item | Value |
|---|---|
| Key | EC P-256, SEC1 PEM (`BEGIN EC PRIVATE KEY`, the format `mender-artifact` 3.9 accepts), generated on the host on 2026-11-16 |
| Private key | `/var/lib/tusker-release/mender-signing.pem`, owner `release-agent`, mode 0600, directory 0700; never in Git, Jenkins credentials or the build agent |
| Public key | `mender/keys/artifact-verify-lab.pem` (also `/var/lib/tusker-release/mender-verify.pem`) |
| Who signs | `sensornode-release-candidate`, stage **Sign and publish**, on the `firmware-release` agent, only after a member of `firmware-signing-approvers` approves |
| Check after signing | `mender-artifact validate` with the public key, before publication |
| Storage | `minio://release-evidence/<version>/<commit>/`: versioned bucket; the release agent's MinIO user can write and read but not delete |

The lab key is for the demonstration only. A production key lives in an HSM or an offline-generated key in Ansible Vault (`vault_mender_signing_key`), with a documented rotation and revocation.

### Device enforcement (open)

Devices do not set `ArtifactVerifyKey` yet. The Mender client then accepts signed and unsigned artifacts alike. Enabling it in the release image (install the public key and set `ArtifactVerifyKey` in `mender.conf`) makes those devices reject unsigned artifacts, so the unsigned CI and demo artifacts can no longer be deployed to them. Enable it only on release-image devices.

### Rotation

1. Generate a new key on the release agent as `release-agent`: `openssl ecparam -genkey -name prime256v1 -noout -out mender-signing.pem.new` (mode 0600).
2. Ship the new public key in a release signed with the old key.
3. Replace `mender-signing.pem`, regenerate `mender-verify.pem`, and update `mender/keys/`.

## Verification

Controls are verified by the security test plan and reviewed before each public release.
