#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

IMAGE="${IMAGE:-sensornode-image-release}"
BUILD_DIR="${BUILD_DIR:-$PROJECT_ROOT/build}"
DEPLOY_DIR="${DEPLOY_DIR:-$BUILD_DIR/tmp/deploy/images/qemuarm64}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"
APP_PORT="${APP_PORT:-18081}"
SSH_PORT="${SSH_PORT:-12222}"
DEVICE_NAME="${DEVICE_NAME:-sensornode-release-test}"

if [[ -n "${KERNEL_IMAGE:-}" ]]; then
  kernel="$KERNEL_IMAGE"
elif [[ -e "$DEPLOY_DIR/Image" ]]; then
  kernel="$(readlink -f "$DEPLOY_DIR/Image")"
else
  kernel="$(find "$DEPLOY_DIR" -maxdepth 1 -type f -name 'Image-*' -print -quit)"
fi
if [[ -n "${ROOTFS_IMAGE:-}" ]]; then
  rootfs="$ROOTFS_IMAGE"
elif [[ -e "$DEPLOY_DIR/${IMAGE}-qemuarm64.rootfs.ext4" ]]; then
  rootfs="$(readlink -f "$DEPLOY_DIR/${IMAGE}-qemuarm64.rootfs.ext4")"
else
  rootfs="$(find "$DEPLOY_DIR" -maxdepth 1 -type f -name "${IMAGE}-qemuarm64*.ext4" -print -quit)"
fi
require_file "$kernel"
require_file "$rootfs"
require_command qemu-system-aarch64
if [[ -x "$PROJECT_ROOT/.venv/bin/pytest" ]]; then
  PYTEST_BIN="$PROJECT_ROOT/.venv/bin/pytest"
else
  require_command pytest
  PYTEST_BIN=pytest
fi

mkdir -p "$ARTIFACT_DIR/release-qemu"
export DEVICE_NAME KERNEL_IMAGE="$kernel" ROOTFS_IMAGE="$rootfs" APP_PORT SSH_PORT
"$PROJECT_ROOT/qemu-fleet/launch/qemu-device.sh" >"$ARTIFACT_DIR/release-qemu/qemu.stdout.log" 2>"$ARTIFACT_DIR/release-qemu/qemu.stderr.log" &
pid=$!
cleanup() {
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  state="$PROJECT_ROOT/qemu-fleet/state/$DEVICE_NAME"
  [[ -f "$state/serial.log" ]] && cp "$state/serial.log" "$ARTIFACT_DIR/release-qemu/serial.log"
}
trap cleanup EXIT

DEVICE_HOST=127.0.0.1 APP_PORT="$APP_PORT" TIMEOUT_SECONDS=240 "$PROJECT_ROOT/qemu-fleet/launch/wait-for-device.sh"
SENSORNODE_URL="http://127.0.0.1:$APP_PORT" "$PYTEST_BIN" -q -m integration "$PROJECT_ROOT/tests/qemu" \
  --junitxml="$ARTIFACT_DIR/release-qemu/junit.xml"
info "release image passed direct QEMU tests"
