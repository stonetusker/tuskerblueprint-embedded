---
id: IMPL-CACHE-001
title: MinIO Cache Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - PRD-REQ-003
verified_by:
  []
---

# MinIO Cache Step by Step

## 1. Start MinIO

Copy and populate the environment file:

```bash
cd infra/compose/minio
cp .env.example .env
$EDITOR .env
docker compose up -d
```

Use a verified immutable MinIO image tag or digest.

## 2. Install/configure the MinIO client

Use the verified `mc` binary pinned in the Ansible inventory, or install it under a controlled local path.

Export bootstrap credentials and run:

```bash
export MINIO_ENDPOINT=http://127.0.0.1:9000
set -a
source infra/compose/minio/.env
set +a
infra/compose/minio/bootstrap.sh
```

The script creates four buckets and four least-privilege identities: cache read, cache write, release write, and release read.

## 3. Configure a build runner

```bash
export MINIO_ENDPOINT=https://minio.example.com
export MINIO_ACCESS_KEY='<cache-write-user>'
export MINIO_SECRET_KEY='<cache-write-password>'
export MINIO_ALIAS=tusker
scripts/configure-minio-client.sh
```

## 4. Pull and push cache

```bash
export MINIO_DOWNLOADS_BUCKET=yocto-downloads
export MINIO_SSTATE_BUCKET=yocto-sstate
scripts/cache-sync.sh pull
CACHE_WRITE_ALLOWED=1 scripts/cache-sync.sh push
```

Untrusted pull requests must never receive write credentials.

## 5. Benchmark

Run `scripts/benchmark-build.sh` under equivalent CPU, RAM, disk, image and source revisions. Record the output in `docs/15-evidence/build-benchmark-summary.md`.
