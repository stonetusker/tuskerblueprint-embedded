---
id: IMPL-PIN-001
title: External Version and Checksum Pinning
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

# External Version and Checksum Pinning

This repository intentionally does not invent current third-party release URLs or checksums. Before deployment, obtain them from the official release source and record the immutable version and SHA-256 in the deployment inventory.

## Items that must be pinned

- GitHub Actions runner version and archive SHA-256
- MinIO server image digest or immutable tag
- MinIO client binary URL and SHA-256
- Jenkins LTS image digest or immutable tag
- Caddy image digest or immutable tag
- Mender self-hosted bundle URL, SHA-256, and Compose-relative path
- `mender-artifact` binary URL and SHA-256
- `mender-cli` binary URL and SHA-256
- Poky, meta-openembedded, and meta-mender Git commits

## Local third-party CLI installation

Copy the version-pin template and populate only values obtained from official release sources:

```bash
cp config/third-party-pins.env.example config/third-party-pins.env
$EDITOR config/third-party-pins.env
scripts/install-third-party-tools.sh
```

The installer verifies SHA-256 before placing `mc`, `mender-artifact`, or `mender-cli` in `$HOME/.local/bin`. Empty entries are skipped, so a local Yocto-only developer does not need Mender tools.

## Yocto source pinning

```bash
make source-lock
cat kas/source-lock.yml
make source-lock-check
```

The generated file contains only 40-character Git commits and is safe to commit.

## Deployment inventory

Populate `infra/ansible/group_vars/all.yml` through inventory overrides or encrypted variable files. Never replace `required` with an unverified floating value such as `latest`.

## Review evidence

For each external dependency record the source URL, version, SHA-256 or digest, retrieval date, license, and reviewer in a Markdown evidence document.
