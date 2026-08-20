#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
require_command mc
require_env MINIO_ENDPOINT
require_env MINIO_ACCESS_KEY
require_env MINIO_SECRET_KEY
MINIO_ALIAS="${MINIO_ALIAS:-tusker}"
export MINIO_ALIAS
mc alias set "$MINIO_ALIAS" "$MINIO_ENDPOINT" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" >/dev/null
info "configured MinIO alias $MINIO_ALIAS for $MINIO_ENDPOINT"
