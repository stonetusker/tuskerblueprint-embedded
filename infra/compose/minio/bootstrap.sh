#!/usr/bin/env bash
set -euo pipefail

export TERM=dumb

# 1. Verify required environment variables
: "${MINIO_ROOT_USER:?Error: MINIO_ROOT_USER is not set in environment}"
: "${MINIO_ROOT_PASSWORD:?Error: MINIO_ROOT_PASSWORD is not set in environment}"
: "${MINIO_CACHE_WRITE_USER:?Error: MINIO_CACHE_WRITE_USER is not set}"
: "${MINIO_CACHE_WRITE_PASSWORD:?Error: MINIO_CACHE_WRITE_PASSWORD is not set}"
: "${MINIO_CACHE_READ_USER:?Error: MINIO_CACHE_READ_USER is not set}"
: "${MINIO_CACHE_READ_PASSWORD:?Error: MINIO_CACHE_READ_PASSWORD is not set}"
: "${MINIO_RELEASE_WRITE_USER:?Error: MINIO_RELEASE_WRITE_USER is not set}"
: "${MINIO_RELEASE_WRITE_PASSWORD:?Error: MINIO_RELEASE_WRITE_PASSWORD is not set}"
: "${MINIO_RELEASE_READ_USER:?Error: MINIO_RELEASE_READ_USER is not set}"
: "${MINIO_RELEASE_READ_PASSWORD:?Error: MINIO_RELEASE_READ_PASSWORD is not set}"

# 2. Verify mc binary is present
if ! command -v mc > /dev/null 2>&1; then
  echo "[-] ERROR: 'mc' (MinIO client) binary not found in PATH." >&2
  echo "    Install it with: sudo curl -sSfL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && sudo chmod +x /usr/local/bin/mc" >&2
  exit 1
fi

MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://127.0.0.1:9000}"
BOOTSTRAP_ALIAS="local-admin"

echo "[*] Waiting for MinIO endpoint at ${MINIO_ENDPOINT} to become ready..."
until curl -sf "${MINIO_ENDPOINT}/minio/health/live" > /dev/null 2>&1; do
  sleep 2
done

echo "[*] Configuring temporary admin alias '${BOOTSTRAP_ALIAS}'..."
mc --no-color alias set "${BOOTSTRAP_ALIAS}" "${MINIO_ENDPOINT}" "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"

# 3. Create Buckets
BUCKETS=("yocto-downloads" "yocto-sstate" "release-artifacts" "release-evidence")
for b in "${BUCKETS[@]}"; do
  if ! mc --no-color ls "${BOOTSTRAP_ALIAS}/${b}" > /dev/null 2>&1; then
    echo "[+] Creating bucket: ${b}"
    mc --no-color mb "${BOOTSTRAP_ALIAS}/${b}"
  fi
done

# Allow BitBake to stream sstate and downloads without authentication
echo "[*] Setting anonymous read permissions for build mirrors..."
mc --no-color anonymous set download "${BOOTSTRAP_ALIAS}/yocto-sstate"
mc --no-color anonymous set download "${BOOTSTRAP_ALIAS}/yocto-downloads"


# 4. Create Policies
POLICY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/policies" && pwd)"
echo "[*] Registering IAM policies..."
mc --no-color admin policy create "${BOOTSTRAP_ALIAS}" yocto-cache-write "${POLICY_DIR}/yocto-cache-write.json" || true
mc --no-color admin policy create "${BOOTSTRAP_ALIAS}" yocto-cache-read "${POLICY_DIR}/yocto-cache-read.json" || true
mc --no-color admin policy create "${BOOTSTRAP_ALIAS}" release-evidence-write "${POLICY_DIR}/release-evidence-write.json" || true
mc --no-color admin policy create "${BOOTSTRAP_ALIAS}" release-evidence-read "${POLICY_DIR}/release-evidence-read.json" || true

# 5. Create Service Users and Attach Policies
create_user() {
  local user="$1" pass="$2" policy="$3"
  echo "[+] Configuring identity: ${user} -> ${policy}"
  mc --no-color admin user add "${BOOTSTRAP_ALIAS}" "${user}" "${pass}" || true
  mc --no-color admin policy attach "${BOOTSTRAP_ALIAS}" "${policy}" --user "${user}"
}

create_user "${MINIO_CACHE_WRITE_USER}" "${MINIO_CACHE_WRITE_PASSWORD}" "yocto-cache-write"
create_user "${MINIO_CACHE_READ_USER}" "${MINIO_CACHE_READ_PASSWORD}" "yocto-cache-read"
create_user "${MINIO_RELEASE_WRITE_USER}" "${MINIO_RELEASE_WRITE_PASSWORD}" "release-evidence-write"
create_user "${MINIO_RELEASE_READ_USER}" "${MINIO_RELEASE_READ_PASSWORD}" "release-evidence-read"

# 6. Apply ILM lifecycle rules
echo "[*] Setting 90-day retention rule for yocto-sstate..."
mc --no-color ilm rule add "${BOOTSTRAP_ALIAS}/yocto-sstate" --expire-days 90 || true

# Clean up admin alias
mc --no-color alias remove "${BOOTSTRAP_ALIAS}" > /dev/null
echo "[+] MinIO bootstrap completed successfully."
