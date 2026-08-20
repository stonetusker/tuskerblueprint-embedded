#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

operation="${1:-}"
[[ "$operation" == "pull" || "$operation" == "push" ]] || die "usage: $0 pull|push"
require_command mc
require_env MINIO_ALIAS
require_env MINIO_DOWNLOADS_BUCKET
require_env MINIO_SSTATE_BUCKET

CACHE_DIR="${CACHE_DIR:-$PROJECT_ROOT/cache}"
mkdir -p "$CACHE_DIR/downloads" "$CACHE_DIR/sstate"

if [[ "$operation" == "pull" ]]; then
  mc mirror --overwrite --remove=false "$MINIO_ALIAS/$MINIO_DOWNLOADS_BUCKET" "$CACHE_DIR/downloads" || warn "downloads cache pull failed"
  mc mirror --overwrite --remove=false "$MINIO_ALIAS/$MINIO_SSTATE_BUCKET" "$CACHE_DIR/sstate" || warn "sstate cache pull failed"
else
  [[ "${CACHE_WRITE_ALLOWED:-0}" == "1" ]] || die "cache write is not authorized"
  mc mirror --overwrite --remove=false "$CACHE_DIR/downloads" "$MINIO_ALIAS/$MINIO_DOWNLOADS_BUCKET"
  mc mirror --overwrite --remove=false "$CACHE_DIR/sstate" "$MINIO_ALIAS/$MINIO_SSTATE_BUCKET"
fi
