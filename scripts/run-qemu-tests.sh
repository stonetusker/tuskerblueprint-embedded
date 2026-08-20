#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

KAS_FILE="${KAS_FILE:-kas/ci.yml}"
IMAGE="${IMAGE:-sensornode-image-ci}"
BUILDER_IMAGE="${BUILDER_IMAGE:-stonetusker/yocto-builder:$(project_version)}"
CACHE_DIR="${CACHE_DIR:-$PROJECT_ROOT/cache}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"
BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
BUILD_RELATIVE="${BUILD_DIR#$PROJECT_ROOT/}"
[[ "$BUILD_RELATIVE" != "$BUILD_DIR" ]] || die "BUILD_DIR must be inside PROJECT_ROOT for container tests"
CONTAINER_BUILD_DIR="/work/$BUILD_RELATIVE"
USE_CONTAINER="${USE_CONTAINER:-1}"

if [[ -z "${SOURCE_LOCK_CONFIG:-}" && -f "$PROJECT_ROOT/kas/source-lock.yml" ]]; then
    SOURCE_LOCK_CONFIG="kas/source-lock.yml"
fi
KAS_CONFIG="$KAS_FILE"
if [[ -n "${SOURCE_LOCK_CONFIG:-}" ]]; then
    require_file "$PROJECT_ROOT/$SOURCE_LOCK_CONFIG"
    KAS_CONFIG="$KAS_FILE:$SOURCE_LOCK_CONFIG"
fi

mkdir -p "$ARTIFACT_DIR/oeqa"
info "running Yocto testimage for $IMAGE"

if [[ "$USE_CONTAINER" == "1" ]]; then
  require_command docker
  docker run --rm --privileged \
    --user "$(id -u):$(id -g)" \
    -e HOME=/tmp/builder-home \
    -e KAS_BUILD_DIR="$CONTAINER_BUILD_DIR" \
    -v "$PROJECT_ROOT:/work" \
    -v "$CACHE_DIR:/work/cache" \
    -v "$ARTIFACT_DIR:/work/artifacts" \
    "$BUILDER_IMAGE" kas shell "$KAS_CONFIG" -c "bitbake -c testimage $IMAGE"
else
  require_command kas
  (cd "$PROJECT_ROOT" && KAS_BUILD_DIR="$BUILD_DIR" kas shell "$KAS_CONFIG" -c "bitbake -c testimage $IMAGE")
fi

(cd "$PROJECT_ROOT" && find "$BUILD_RELATIVE" -path '*/log/oeqa/*' -type f -exec cp --parents {} "$ARTIFACT_DIR/oeqa" \;) 2>/dev/null || true
info "QEMU runtime tests passed"
