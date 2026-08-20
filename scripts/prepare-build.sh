#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
CACHE_DIR="${CACHE_DIR:-$PROJECT_ROOT/cache}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"

mkdir -p "$BUILD_DIR" "$CACHE_DIR/downloads" "$CACHE_DIR/sstate" "$ARTIFACT_DIR"
info "build directory: $BUILD_DIR"
info "cache directory: $CACHE_DIR"
info "artifact directory: $ARTIFACT_DIR"
