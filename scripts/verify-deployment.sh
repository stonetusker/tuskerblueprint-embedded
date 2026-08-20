#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

require_command curl
DEVICE_URL="${DEVICE_URL:-}"
EXPECTED_VERSION="${EXPECTED_VERSION:-}"
[[ -n "$DEVICE_URL" && -n "$EXPECTED_VERSION" ]] || die "DEVICE_URL and EXPECTED_VERSION are required"

for attempt in $(seq 1 30); do
  response="$(curl --fail --silent --max-time 5 "$DEVICE_URL/version" || true)"
  if [[ -n "$response" ]] && python3 -c 'import json,sys; d=json.load(sys.stdin); sys.exit(0 if d["image_version"]==sys.argv[1] else 1)' "$EXPECTED_VERSION" <<<"$response"; then
    info "device reports expected version"
    exit 0
  fi
  sleep 10
done
die "device did not report expected version"
