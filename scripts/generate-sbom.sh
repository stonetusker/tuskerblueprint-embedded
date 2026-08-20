#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"
BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
DEPLOY_DIR="${DEPLOY_DIR:-$BUILD_DIR/tmp/deploy/images/qemuarm64}"
out="$ARTIFACT_DIR/sbom"
mkdir -p "$out"

count=0
while IFS= read -r -d '' file; do
  cp -a --reflink=auto "$file" "$out/"
  count=$((count + 1))
done < <(find "$BUILD_DIR/tmp/deploy" -type f \( -name '*.spdx.json' -o -name '*.spdx.tar.zst' \) -print0 2>/dev/null)

[[ "$count" -gt 0 ]] || die "no Yocto SPDX output found; release.yml must build with create-spdx"
(
  cd "$out"
  sha256sum ./* > SHA256SUMS
)
info "collected $count SBOM files"
