---
id: IMPL-SEC-001
title: Release Security Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - SEC-REQ-003
  - SEC-REQ-004
verified_by:
  []
---

# Release Security Step by Step

## Branch control

### UI steps

GitHub repository → **Settings** → **Branches** or **Rulesets** → protect `main`.

Require pull requests, successful repository validation, and review for changes to `meta-sensornode/`, `.github/workflows/`, `infra/`, `ci/jenkins/`, and security policy files.

## Source integrity

Generate and commit `kas/source-lock.yml`. Release workflow validates exact 40-hex commits.

## Artifact identity

The release candidate includes Git commit, layer revisions, builder identity, image checksum, SBOM checksum, and test evidence. `sensornode-release.bb` writes immutable identity into the image and does not mark it as a mutable conffile.

## SBOM

`kas/release.yml` enables Yocto SPDX. `scripts/generate-sbom.sh` collects the generated SBOM into release evidence.

## Signing

Only the `release` runner has `/var/lib/tusker-release/mender-signing.pem`. The build runner never receives the signing key.

## MinIO separation

Use distinct cache-write, release-write, and release-read identities. Promotion receives only release-read access.

## AI separation

AI cannot sign, publish, deploy, or approve. Jenkins approval remains authenticated and independent of the model.
