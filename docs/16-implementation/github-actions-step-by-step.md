---
id: IMPL-GHA-001
title: GitHub Actions Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - CI-REQ-001
  - CI-REQ-002
verified_by:
  []
---

# GitHub Actions Step by Step

## Build runner

Provision one Ubuntu 24.x runner with label `yocto`. The workflows deliberately do not require `x64`, so x86_64 and aarch64 hosts are supported.

### UI steps

GitHub repository → **Settings** → **Actions** → **Runners** → **New self-hosted runner**.

Register the runner with labels:

```text
self-hosted,linux,yocto
```

The Ansible implementation is `infra/ansible/roles/github_runner/tasks/main.yml`.

## Release runner

Create a separate OS user/runner with label `release`. It owns the Mender signing key, `mender-artifact`, `mender-cli`, and release-evidence MinIO credential. It does not receive Docker/Yocto build authority.

### UI steps

GitHub repository → **Settings** → **Environments** → create:

- `firmware-signing`
- `firmware-production`

Configure required reviewers for both.

## Required secrets

Build/cache environment:

- `MINIO_ENDPOINT`
- `MINIO_CACHE_WRITE_ACCESS_KEY`
- `MINIO_CACHE_WRITE_SECRET_KEY`

Release/signing environment:

- `MINIO_RELEASE_ACCESS_KEY`
- `MINIO_RELEASE_SECRET_KEY`

Promotion environment:

- `MINIO_RELEASE_READ_ACCESS_KEY`
- `MINIO_RELEASE_READ_SECRET_KEY`
- `MENDER_SERVER_URL`
- `MENDER_ACCESS_TOKEN`

## Workflows

- `.github/workflows/pull-request.yml`
- `.github/workflows/build-image.yml`
- `.github/workflows/nightly.yml`
- `.github/workflows/release-candidate.yml`
- `.github/workflows/promote-mender.yml`

The main principle is that CI YAML orchestrates repository scripts instead of implementing build logic inside the workflow.
