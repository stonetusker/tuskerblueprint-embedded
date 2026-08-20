#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

ROOTFS_IMAGE="${ROOTFS_IMAGE:-}"
OUTPUT="${OUTPUT:-$PROJECT_ROOT/artifacts/sensornode.mender}"
ARTIFACT_NAME="${ARTIFACT_NAME:-}"
DEVICE_TYPE="${DEVICE_TYPE:-qemuarm64-sensornode}"

require_command mender-artifact
require_file "$ROOTFS_IMAGE"
[[ -n "$ARTIFACT_NAME" ]] || die "ARTIFACT_NAME is required"
mkdir -p "$(dirname "$OUTPUT")"

mender-artifact write rootfs-image \
  --device-type "$DEVICE_TYPE" \
  --artifact-name "$ARTIFACT_NAME" \
  --file "$ROOTFS_IMAGE" \
  --output-path "$OUTPUT"

sha256sum "$OUTPUT" > "$OUTPUT.sha256"
info "created $OUTPUT"
