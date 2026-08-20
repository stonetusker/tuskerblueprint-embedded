#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"
mkdir -p "$ARTIFACT_DIR"
commit="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
short="$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
builder="${BUILDER_IMAGE:-stonetusker/yocto-builder:0.2.0}"
image="${IMAGE:-sensornode-image-ci}"

python3 "$PROJECT_ROOT/tools/generate_release_manifest.py" \
  --product SensorNode \
  --version "${SENSORNODE_VERSION:-0.2.0}" \
  --git-commit "$commit" \
  --build-number "${GITHUB_RUN_NUMBER:-${BUILD_NUMBER:-local}}" \
  --machine qemuarm64 \
  --distro sensornode \
  --image "$image" \
  --builder "$builder" \
  --artifact-root "$ARTIFACT_DIR" \
  --output "$ARTIFACT_DIR/release-manifest.json"
info "release metadata generated for $short"
