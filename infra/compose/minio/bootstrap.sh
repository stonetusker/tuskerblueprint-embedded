#!/usr/bin/env bash
set -Eeuo pipefail
: "${MINIO_ENDPOINT:?set MINIO_ENDPOINT}"
: "${MINIO_ROOT_USER:?set MINIO_ROOT_USER}"
: "${MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD}"
command -v mc >/dev/null 2>&1 || { echo 'mc is required' >&2; exit 1; }
root="$(cd "$(dirname "$0")" && pwd)"
mc alias set bootstrap "$MINIO_ENDPOINT" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
for bucket in yocto-downloads yocto-sstate build-evidence release-evidence; do
  mc mb --ignore-existing "bootstrap/$bucket"
done
mc admin policy create bootstrap yocto-cache-read "$root/policies/yocto-cache-read.json"
mc admin policy create bootstrap yocto-cache-write "$root/policies/yocto-cache-write.json"
mc admin policy create bootstrap release-evidence-write "$root/policies/release-evidence-write.json"
mc ilm rule add --expire-days 90 bootstrap/build-evidence || true
