#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

IMAGE="${IMAGE:-sensornode-image-ci}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"
BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
DEPLOY_DIR="${DEPLOY_DIR:-$BUILD_DIR/tmp/deploy/images/qemuarm64}"
out="$ARTIFACT_DIR/deploy/qemuarm64"
mkdir -p "$out"

if [[ ! -d "$DEPLOY_DIR" ]]; then
  warn "Yocto deploy directory not found: $DEPLOY_DIR"
  exit 0
fi

patterns=(
  "${IMAGE}-qemuarm64*.rootfs.ext4"
  "${IMAGE}-qemuarm64*.rootfs.tar.bz2"
  "${IMAGE}-qemuarm64*.mender"
  "${IMAGE}-qemuarm64*.wic*"
  "Image"
  "Image-*"
  "*.spdx.json"
  "*.spdx.tar.zst"
)

for pattern in "${patterns[@]}"; do
  while IFS= read -r -d '' file; do
    cp -a --reflink=auto "$file" "$out/"
  done < <(find "$DEPLOY_DIR" -maxdepth 1 -type f -name "$pattern" -print0)
done

(
  cd "$out"
  find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 -r sha256sum > SHA256SUMS
)
info "collected deploy outputs in $out"
