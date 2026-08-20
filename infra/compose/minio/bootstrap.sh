#!/usr/bin/env bash
set -Eeuo pipefail
: "${MINIO_ENDPOINT:?set MINIO_ENDPOINT}"
: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"
: "${MINIO_CACHE_READ_USER:?set MINIO_CACHE_READ_USER}"
: "${MINIO_CACHE_READ_PASSWORD:?set MINIO_CACHE_READ_PASSWORD}"
: "${MINIO_CACHE_WRITE_USER:?set MINIO_CACHE_WRITE_USER}"
: "${MINIO_CACHE_WRITE_PASSWORD:?set MINIO_CACHE_WRITE_PASSWORD}"
: "${MINIO_RELEASE_USER:?set MINIO_RELEASE_USER}"
: "${MINIO_RELEASE_PASSWORD:?set MINIO_RELEASE_PASSWORD}"
: "${MINIO_RELEASE_READ_USER:?set MINIO_RELEASE_READ_USER}"
: "${MINIO_RELEASE_READ_PASSWORD:?set MINIO_RELEASE_READ_PASSWORD}"
command -v mc >/dev/null 2>&1 || { echo 'mc is required' >&2; exit 1; }
root="$(cd "$(dirname "$0")" && pwd)"
mc alias set bootstrap "$MINIO_ENDPOINT" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
for bucket in yocto-downloads yocto-sstate build-evidence release-evidence; do
  mc mb --ignore-existing "bootstrap/$bucket"
done
for policy in yocto-cache-read yocto-cache-write release-evidence-write release-evidence-read; do
  mc admin policy create bootstrap "$policy" "$root/policies/$policy.json"
done
mc admin user add bootstrap "$MINIO_CACHE_READ_USER" "$MINIO_CACHE_READ_PASSWORD"
mc admin user add bootstrap "$MINIO_CACHE_WRITE_USER" "$MINIO_CACHE_WRITE_PASSWORD"
mc admin user add bootstrap "$MINIO_RELEASE_USER" "$MINIO_RELEASE_PASSWORD"
mc admin user add bootstrap "$MINIO_RELEASE_READ_USER" "$MINIO_RELEASE_READ_PASSWORD"
mc admin policy attach bootstrap yocto-cache-read --user "$MINIO_CACHE_READ_USER"
mc admin policy attach bootstrap yocto-cache-write --user "$MINIO_CACHE_WRITE_USER"
mc admin policy attach bootstrap release-evidence-write --user "$MINIO_RELEASE_USER"
mc admin policy attach bootstrap release-evidence-read --user "$MINIO_RELEASE_READ_USER"
mc ilm rule add --expire-days 90 bootstrap/build-evidence || true
printf 'MinIO buckets, users, and least-privilege policies are configured.\n'
