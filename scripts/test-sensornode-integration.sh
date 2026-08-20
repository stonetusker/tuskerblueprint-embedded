#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

require_command go
if [[ -x "$PROJECT_ROOT/.venv/bin/pytest" ]]; then
  pytest_bin="$PROJECT_ROOT/.venv/bin/pytest"
else
  require_command pytest
  pytest_bin=pytest
fi

work="$(mktemp -d)"
pid=""
cleanup() {
  [[ -z "$pid" ]] || kill "$pid" 2>/dev/null || true
  [[ -z "$pid" ]] || wait "$pid" 2>/dev/null || true
  rm -rf "$work"
}
trap cleanup EXIT

(
  cd "$PROJECT_ROOT/app/sensornode"
  CGO_ENABLED=0 go build -trimpath -o "$work/sensornode" ./cmd/sensornode
)
printf 'integration-test-image\n' > "$work/image-version"
SENSORNODE_IMAGE_VERSION_FILE="$work/image-version" \
SENSORNODE_DEVICE_ID=sensornode-integration \
  "$work/sensornode" --listen 127.0.0.1:18081 >"$work/app.log" 2>&1 &
pid=$!

for _ in $(seq 1 50); do
  curl --fail --silent --max-time 1 http://127.0.0.1:18081/health >/dev/null && break
  sleep 0.1
done
curl --fail --silent --max-time 2 http://127.0.0.1:18081/health >/dev/null
SENSORNODE_URL=http://127.0.0.1:18081 EXPECTED_IMAGE_VERSION=integration-test-image \
  "$pytest_bin" -q -m integration "$PROJECT_ROOT/tests/qemu"
