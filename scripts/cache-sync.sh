#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-pull}"
MINIO_ALIAS="${MINIO_ALIAS:-tusker}"
DL_BUCKET="${MINIO_DOWNLOADS_BUCKET:-yocto-downloads}"
SSTATE_BUCKET="${MINIO_SSTATE_BUCKET:-yocto-sstate}"

# Support both cache/ and build/ directory structures
BASE_CACHE_DIR="${CACHE_DIR:-cache}"

DL_DIR="${BASE_CACHE_DIR}/downloads"
# Check if cache/sstate exists; otherwise fall back to cache/sstate-cache
if [[ -d "${BASE_CACHE_DIR}/sstate" || ! -d "${BASE_CACHE_DIR}/sstate-cache" ]]; then
  SSTATE_DIR="${BASE_CACHE_DIR}/sstate"
else
  SSTATE_DIR="${BASE_CACHE_DIR}/sstate-cache"
fi

mkdir -p "${DL_DIR}" "${SSTATE_DIR}"

case "${ACTION}" in
  pull)
    echo "[+] Pulling downloads and sstate cache from MinIO..."
    mc mirror --quiet --exclude "*.lock" "${MINIO_ALIAS}/${DL_BUCKET}" "${DL_DIR}" || true
    mc mirror --quiet --exclude "*.lock" "${MINIO_ALIAS}/${SSTATE_BUCKET}" "${SSTATE_DIR}" || true
    ;;

  push)
    if [[ "${CACHE_WRITE_ALLOWED:-0}" != "1" ]]; then
      echo "[!] CACHE_WRITE_ALLOWED is not set to 1. Skipping cache push."
      exit 0
    fi
    echo "[+] Pushing build downloads and sstate cache to MinIO..."
    mc mirror --quiet --exclude "*.lock" --exclude "*.done" "${DL_DIR}" "${MINIO_ALIAS}/${DL_BUCKET}"
    mc mirror --quiet --exclude "*.lock" "${SSTATE_DIR}" "${MINIO_ALIAS}/${SSTATE_BUCKET}"
    ;;

  *)
    echo "Usage: $0 {pull|push}" >&2
    exit 1
    ;;
esac
