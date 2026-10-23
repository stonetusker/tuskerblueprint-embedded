#!/usr/bin/env bash
# End-to-end OTA proof on one QEMU canary:
#   1. boot the factory disk image (v1) and accept the device in Mender
#   2. deploy a healthy candidate (v2): expect install, reboot, health gate, commit
#   3. deploy an unhealthy candidate: expect the health gate to fail and the device
#      to roll back to v2
# Evidence (API responses, device logs, serial console) lands in $ARTIFACT_DIR/ota/<run>/.
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
source "$root/scripts/lib/common.sh"

MENDER_SERVER_URL="${MENDER_SERVER_URL:-https://docker.mender.io}"
FACTORY_DISK="${FACTORY_DISK:-}"
GOOD_ARTIFACT="${GOOD_ARTIFACT:-}"
BROKEN_ARTIFACT="${BROKEN_ARTIFACT:-}"
DEVICE_NAME="${DEVICE_NAME:-sensornode-canary-01}"
APP_PORT="${APP_PORT:-18091}"
SSH_PORT="${SSH_PORT:-12291}"
DEPLOY_TIMEOUT_SECONDS="${DEPLOY_TIMEOUT_SECONDS:-3600}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"
evidence="$ARTIFACT_DIR/ota/$(date -u +%Y%m%dT%H%M%SZ)"
require_env MENDER_USER
require_env MENDER_PASSWORD
require_file "$FACTORY_DISK"
require_file "$GOOD_ARTIFACT"
require_command curl
require_command python3
mkdir -p "$evidence"

curl_opts=(--silent --show-error --fail-with-body)
[[ "${MENDER_INSECURE_TLS:-0}" == "1" ]] && curl_opts+=(--insecure)
[[ -n "${MENDER_CA_CERT:-}" ]] && curl_opts+=(--cacert "$MENDER_CA_CERT")

token="$(curl "${curl_opts[@]}" -X POST -u "$MENDER_USER:$MENDER_PASSWORD" \
  "$MENDER_SERVER_URL/api/management/v1/useradm/auth/login")"
api() {
  local method="$1" path="$2"
  shift 2
  curl "${curl_opts[@]}" -X "$method" -H "Authorization: Bearer $token" "$@" "$MENDER_SERVER_URL/api/management$path"
}
json() { python3 -c "import json,sys; d=json.load(sys.stdin); print($1)"; }
artifact_name() { python3 "$root/tools/mender_artifact_name.py" "$1"; }
device_version() { curl --fail --silent --max-time 5 "http://127.0.0.1:$APP_PORT/version" | json 'd["image_version"]'; }

pid=""
stop_device() {
  [[ -z "$pid" ]] || { kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true; }
  local state="$PROJECT_ROOT/qemu-fleet/state/$DEVICE_NAME"
  [[ -f "$state/serial.log" ]] && cp "$state/serial.log" "$evidence/serial.log"
  return 0
}
trap stop_device EXIT

info "evidence directory: $evidence"
launched_at="$(date -u +%Y-%m-%dT%H:%M:%S)"
DISK_IMAGE="$FACTORY_DISK" RESET_DISK=1 DEVICE_NAME="$DEVICE_NAME" APP_PORT="$APP_PORT" SSH_PORT="$SSH_PORT" \
  "$PROJECT_ROOT/qemu-fleet/launch/qemu-device.sh" >"$evidence/qemu.stdout.log" 2>"$evidence/qemu.stderr.log" &
pid=$!
DEVICE_HOST=127.0.0.1 APP_PORT="$APP_PORT" TIMEOUT_SECONDS=900 "$PROJECT_ROOT/qemu-fleet/launch/wait-for-device.sh"
factory_version="$(device_version)"
info "canary $DEVICE_NAME is healthy on factory image $factory_version"

# Enrollment: a factory-fresh disk generates a new device key, which appears as a
# new pending auth set even when the identity was accepted before. Accept pending
# sets until the newest auth set (submitted after launch) is accepted.
device_id=""
enrolled=0
for _ in $(seq 1 120); do
  device_id="$(api GET "/v2/devauth/devices?per_page=500" |
    json "next((x['id'] for x in d if x['identity_data'].get('device_id')=='$DEVICE_NAME'),'')")"
  if [[ -n "$device_id" ]]; then
    api GET "/v2/devauth/devices/$device_id" >"$evidence/device-before.json"
    for auth_id in $(json "' '.join(a['id'] for a in d['auth_sets'] if a['status']=='pending')" <"$evidence/device-before.json"); do
      api PUT "/v2/devauth/devices/$device_id/auth/$auth_id/status" \
        -H 'Content-Type: application/json' -d '{"status":"accepted"}' >/dev/null
      info "accepted auth set $auth_id for $DEVICE_NAME"
    done
    newest="$(api GET "/v2/devauth/devices/$device_id" |
      json "max(d['auth_sets'], key=lambda a: a['ts'])['status'] if max(a['ts'] for a in d['auth_sets']) >= '$launched_at' else ''")"
    if [[ "$newest" == "accepted" ]]; then
      enrolled=1
      break
    fi
  fi
  sleep 5
done
(( enrolled )) || die "device $DEVICE_NAME was not enrolled with its current key"
info "device $DEVICE_NAME accepted as $device_id"

upload() {
  local file="$1" name
  name="$(artifact_name "$file")"
  if ! api GET "/v1/deployments/artifacts?name=$name" | json "len(d)" | grep -qx 1; then
    api POST /v1/deployments/artifacts -F "description=$(basename "$file")" -F "artifact=@$file" >/dev/null
  fi
  printf '%s\n' "$name"
}

# deploy <label> <artifact-name> -> prints the per-device deployment status
deploy() {
  local label="$1" name="$2" location deployment_id end status
  location="$(api POST /v1/deployments/deployments -D - -o /dev/null \
    -H 'Content-Type: application/json' \
    -d "{\"name\":\"$label-$name\",\"artifact_name\":\"$name\",\"devices\":[\"$device_id\"]}" |
    tr -d '\r' | sed -n 's/^[Ll]ocation: //p')"
  deployment_id="${location##*/}"
  [[ -n "$deployment_id" ]] || die "deployment for $name was not created"
  info "$label deployment $deployment_id for $name created"
  end=$((SECONDS + DEPLOY_TIMEOUT_SECONDS))
  while (( SECONDS < end )); do
    status="$(api GET "/v1/deployments/deployments/$deployment_id" | json 'd["status"]')"
    [[ "$status" == "finished" ]] && break
    sleep 15
  done
  api GET "/v1/deployments/deployments/$deployment_id" >"$evidence/$label-deployment.json"
  api GET "/v1/deployments/deployments/$deployment_id/statistics" >"$evidence/$label-statistics.json"
  api GET "/v1/deployments/deployments/$deployment_id/devices" >"$evidence/$label-devices.json"
  api GET "/v1/deployments/deployments/$deployment_id/devices/$device_id/log" -o "$evidence/$label-device.log" 2>/dev/null || true
  json 'd[0]["status"]' <"$evidence/$label-devices.json"
}

good_name="$(upload "$GOOD_ARTIFACT")"
result="$(deploy canary "$good_name")"
[[ "$result" == "success" ]] || die "healthy canary deployment ended with $result"
DEVICE_HOST=127.0.0.1 APP_PORT="$APP_PORT" TIMEOUT_SECONDS=600 "$PROJECT_ROOT/qemu-fleet/launch/wait-for-device.sh"
good_version="$(device_version)"
[[ "$good_version" != "$factory_version" ]] || die "device still reports factory version $factory_version"
info "canary committed $good_name and reports $good_version"

if [[ -n "$BROKEN_ARTIFACT" ]]; then
  broken_name="$(upload "$BROKEN_ARTIFACT")"
  result="$(deploy rollback "$broken_name")"
  [[ "$result" == "failure" ]] || die "unhealthy deployment ended with $result, expected failure"
  DEVICE_HOST=127.0.0.1 APP_PORT="$APP_PORT" TIMEOUT_SECONDS=600 "$PROJECT_ROOT/qemu-fleet/launch/wait-for-device.sh"
  after_version="$(device_version)"
  [[ "$after_version" == "$good_version" ]] || die "device reports $after_version after rollback, expected $good_version"
  info "unhealthy $broken_name was rejected and the device rolled back to $after_version"
fi

api GET "/v2/devauth/devices/$device_id" >"$evidence/device-after.json"
api GET "/v1/inventory/devices/$device_id" >"$evidence/inventory-after.json" || true
stop_device
pid=""
cat >"$evidence/summary.json" <<EOF
{
  "device_name": "$DEVICE_NAME",
  "mender_device_id": "$device_id",
  "factory_image_version": "$factory_version",
  "canary_artifact": "$good_name",
  "canary_image_version": "$good_version",
  "rollback_artifact": "${broken_name:-}",
  "image_version_after_rollback": "${after_version:-}",
  "completed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
(cd "$evidence" && sha256sum ./* > SHA256SUMS)
info "OTA end-to-end passed; evidence in $evidence"
