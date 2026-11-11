#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

KAS_FILE="${KAS_FILE:-kas/ci.yml}"
IMAGE="${IMAGE:-sensornode-image-ci}"
BUILDER_IMAGE="${BUILDER_IMAGE:-stonetusker/yocto-builder:$(project_version)}"
BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
CACHE_DIR="${CACHE_DIR:-$PROJECT_ROOT/cache}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"
BUILD_RELATIVE="${BUILD_DIR#$PROJECT_ROOT/}"
[[ "$BUILD_RELATIVE" != "$BUILD_DIR" ]] || die "BUILD_DIR must be inside PROJECT_ROOT for container builds"
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
# Optional overlay, e.g. kas/benchmark-clean.yml for the clean benchmark case.
if [[ -n "${KAS_EXTRA_CONFIG:-}" ]]; then
    require_file "$PROJECT_ROOT/$KAS_EXTRA_CONFIG"
    KAS_CONFIG="$KAS_CONFIG:$KAS_EXTRA_CONFIG"
fi

require_file "$PROJECT_ROOT/$KAS_FILE"
if [[ "$USE_CONTAINER" == "1" ]]; then
    require_command docker
    # Bind-mount targets inside PROJECT_ROOT must exist and be owned by us;
    # otherwise dockerd creates them as root and the unprivileged build fails
    # with "Cannot write to /work/build".
    mkdir -p "$PROJECT_ROOT/cache" "$PROJECT_ROOT/artifacts"
    ensure_writable() {
        local dir="$1" owner
        [[ -d "$dir" ]] || return 0
        if [[ -w "$dir" ]] && [[ -z "$(find "$dir" -maxdepth 2 ! -user "$(id -u)" -print -quit 2>/dev/null)" ]]; then
            return 0
        fi
        owner="$(stat -c '%u:%g' "$dir" 2>/dev/null || echo unknown)"
        warn "$dir (owner $owner) is not owned by $(id -u):$(id -g); repairing ownership via $BUILDER_IMAGE"
        docker run --rm --user 0:0 --entrypoint chown -v "$dir:/fix" "$BUILDER_IMAGE" \
          -R "$(id -u):$(id -g)" /fix \
          || die "cannot repair ownership of $dir; run: sudo chown -R $(id -u):$(id -g) $dir"
    }
    for d in "$BUILD_DIR" "$PROJECT_ROOT/cache" "$CACHE_DIR" "$ARTIFACT_DIR" "$PROJECT_ROOT/artifacts"; do
        ensure_writable "$d"
    done
fi
"$PROJECT_ROOT/scripts/prepare-build.sh"

start="$(date +%s)"
info "building $IMAGE with $KAS_FILE"

if [[ "$USE_CONTAINER" == "1" ]]; then
    require_command docker
    docker run --rm \
      --user "$(id -u):$(id -g)" \
      --add-host=host.docker.internal:host-gateway \
      -e HOME=/tmp/builder-home \
      -e GITHUB_SHA="${GITHUB_SHA:-}" \
      -e GITHUB_RUN_NUMBER="${GITHUB_RUN_NUMBER:-}" \
      -e GIT_COMMIT="${GIT_COMMIT:-}" \
      -e BUILD_NUMBER="${BUILD_NUMBER:-}" \
      -e SENSORNODE_VERSION="${SENSORNODE_VERSION:-$(project_version)}" \
      -e BB_NUMBER_THREADS="${BB_NUMBER_THREADS:-}" \
      -e PARALLEL_MAKE="${PARALLEL_MAKE:-}" \
      -e MENDER_SERVER_URL="${MENDER_SERVER_URL:-}" \
      -e BB_ENV_PASSTHROUGH_ADDITIONS="GITHUB_SHA GITHUB_RUN_NUMBER GIT_COMMIT BUILD_NUMBER SENSORNODE_VERSION BB_NUMBER_THREADS PARALLEL_MAKE MENDER_SERVER_URL" \
      -e KAS_BUILD_DIR="$CONTAINER_BUILD_DIR" \
      -v "$PROJECT_ROOT:/work" \
      -v "$CACHE_DIR:/work/cache" \
      -v "$ARTIFACT_DIR:/work/artifacts" \
      "$BUILDER_IMAGE" kas build --target "$IMAGE" "$KAS_CONFIG"
else
    require_command kas
    (cd "$PROJECT_ROOT" && BB_ENV_PASSTHROUGH_ADDITIONS="${BB_ENV_PASSTHROUGH_ADDITIONS:-} GITHUB_SHA GITHUB_RUN_NUMBER GIT_COMMIT BUILD_NUMBER SENSORNODE_VERSION BB_NUMBER_THREADS PARALLEL_MAKE MENDER_SERVER_URL" KAS_BUILD_DIR="$BUILD_DIR" kas build --target "$IMAGE" "$KAS_CONFIG")
fi

end="$(date +%s)"
printf '%s\n' "$((end-start))" > "$ARTIFACT_DIR/build-duration-seconds"
info "build completed in $((end-start)) seconds"
"$PROJECT_ROOT/scripts/collect-build-outputs.sh"
"$PROJECT_ROOT/scripts/collect-build-metadata.sh"
