#!/usr/bin/env bash
set -euo pipefail

MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://127.0.0.1:9000}"
BOOTSTRAP_ALIAS="local-admin"

echo "[*] Waiting for MinIO endpoint at ${MINIO_ENDPOINT} to become healthy..."
until curl -sf "${MINIO_ENDPOINT}/minio/health/live" > /dev/null 2>&1; do
  sleep 2
done

# Set up local admin alias
mc alias set "${BOOTSTRAP_ALIAS}" "${MINIO_ENDPOINT}" "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}" > /dev/null

# 1. Create Buckets
BUCKETS=("yocto-downloads" "yocto-sstate" "release-artifacts" "release-evidence")
for b in "${BUCKETS[@]}"; do
  if ! mc ls "${BOOTSTRAP_ALIAS}/${b}" > /dev/null 2>&1; then
    echo "[+] Creating bucket: ${b}"
    mc mb "${BOOTSTRAP_ALIAS}/${b}"
  fi
done

# 2. Add Policies
POLICY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/policies" && pwd)"
mc admin policy create "${BOOTSTRAP_ALIAS}" yocto-cache-write "${POLICY_DIR}/yocto-cache-write.json" || true
mc admin policy create "${BOOTSTRAP_ALIAS}" yocto-cache-read "${POLICY_DIR}/yocto-cache-read.json" || true
mc admin policy create "${BOOTSTRAP_ALIAS}" release-evidence-write "${POLICY_DIR}/release-evidence-write.json" || true
mc admin policy create "${BOOTSTRAP_ALIAS}" release-evidence-read "${POLICY_DIR}/release-evidence-read.json" || true

# 3. Create Identities & Attach Policies
create_user() {
  local user="$1" pass="$2" policy="$3"
  mc admin user add "${BOOTSTRAP_ALIAS}" "${user}" "${pass}" || true
  mc admin policy attach "${BOOTSTRAP_ALIAS}" "${policy}" --user "${user}"
}

create_user "${MINIO_CACHE_WRITE_USER}" "${MINIO_CACHE_WRITE_PASSWORD}" "yocto-cache-write"
create_user "${MINIO_CACHE_READ_USER}" "${MINIO_CACHE_READ_PASSWORD}" "yocto-cache-read"
create_user "${MINIO_RELEASE_WRITE_USER}" "${MINIO_RELEASE_WRITE_PASSWORD}" "release-evidence-write"
create_user "${MINIO_RELEASE_READ_USER}" "${MINIO_RELEASE_READ_PASSWORD}" "release-evidence-read"

# 4. Set Retention Policy (Expire stale sstate after 90 days)
mc ilm rule add "${BOOTSTRAP_ALIAS}/yocto-sstate" --expire-days 90 || true

# Clean up admin alias
mc alias remove "${BOOTSTRAP_ALIAS}" > /dev/null
echo "[+] MinIO bootstrap complete."
