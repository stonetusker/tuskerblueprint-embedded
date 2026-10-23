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

# The release candidate is the full Mender disk image; boot it through UEFI and
# GRUB exactly as a device would, so partition layout and fstab are exercised.
if [[ -n "${DISK_IMAGE:-}" ]]; then
  disk="$DISK_IMAGE"
elif [[ -e "$DEPLOY_DIR/${IMAGE}-qemuarm64.uefiimg" ]]; then
  disk="$(readlink -f "$DEPLOY_DIR/${IMAGE}-qemuarm64.uefiimg")"
else
  disk="$(find "$DEPLOY_DIR" -maxdepth 1 -type f -name "${IMAGE}-qemuarm64*.uefiimg" -print -quit)"
fi
require_file "$disk"
require_command qemu-system-aarch64
if [[ -x "$PROJECT_ROOT/.venv/bin/pytest" ]]; then
  PYTEST_BIN="$PROJECT_ROOT/.venv/bin/pytest"
else
  require_command pytest
  PYTEST_BIN=pytest
fi

mkdir -p "$ARTIFACT_DIR/release-qemu"
export DEVICE_NAME DISK_IMAGE="$disk" RESET_DISK=1 APP_PORT SSH_PORT
"$PROJECT_ROOT/qemu-fleet/launch/qemu-device.sh" >"$ARTIFACT_DIR/release-qemu/qemu.stdout.log" 2>"$ARTIFACT_DIR/release-qemu/qemu.stderr.log" &
pid=$!
cleanup() {
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  state="$PROJECT_ROOT/qemu-fleet/state/$DEVICE_NAME"
  [[ -f "$state/serial.log" ]] && cp "$state/serial.log" "$ARTIFACT_DIR/release-qemu/serial.log"
}
trap cleanup EXIT

DEVICE_HOST=127.0.0.1 APP_PORT="$APP_PORT" TIMEOUT_SECONDS="${BOOT_TIMEOUT_SECONDS:-480}" "$PROJECT_ROOT/qemu-fleet/launch/wait-for-device.sh"
SENSORNODE_URL="http://127.0.0.1:$APP_PORT" EXPECTED_DEVICE_ID="$DEVICE_NAME" "$PYTEST_BIN" -q -m integration "$PROJECT_ROOT/tests/qemu" \
  --junitxml="$ARTIFACT_DIR/release-qemu/junit.xml"
info "release disk image passed QEMU tests"
