#!/usr/bin/env bash
set -euo pipefail

: "${MINIO_ENDPOINT:?Error: MINIO_ENDPOINT is required}"
: "${MINIO_ACCESS_KEY:?Error: MINIO_ACCESS_KEY is required}"
: "${MINIO_SECRET_KEY:?Error: MINIO_SECRET_KEY is required}"
: "${MINIO_ALIAS:=tusker}"

# Trust internal CA cert if present
if [[ -n "${MINIO_CA_CERT:-}" && -f "${MINIO_CA_CERT}" ]]; then
  mkdir -p "${HOME}/.mc/certs/CAs"
  cp "${MINIO_CA_CERT}" "${HOME}/.mc/certs/CAs/tusker-ca.crt"
fi

# Configure client alias silently to avoid leaking credentials in logs
mc alias set "${MINIO_ALIAS}" "${MINIO_ENDPOINT}" "${MINIO_ACCESS_KEY}" "${MINIO_SECRET_KEY}" --api S3v4 > /dev/null

# Verify connection
if ! mc ls "${MINIO_ALIAS}" > /dev/null 2>&1; then
  echo "[-] ERROR: Failed to authenticate to MinIO alias '${MINIO_ALIAS}' at ${MINIO_ENDPOINT}" >&2
  exit 1
fi

echo "[+] MinIO client configured and verified for alias '${MINIO_ALIAS}'."
