#!/usr/bin/env bash
# Create a Mender deployment of one artifact to an explicit list of devices
# (Deployments management API). Used for canary deployments only.
#
#   ARTIFACT_NAME        Mender artifact name, for example sensornode-0.4.0-12-1a2b3c4
#   DEVICE_IDS           comma-separated Mender device IDs
#   MENDER_SERVER_URL    for example https://docker.mender.io
#   MENDER_ACCESS_TOKEN  Mender personal access token
#   MENDER_CA_CERT       optional CA or server certificate for a self-signed server
#   DEPLOYMENT_NAME      optional, default sensornode-<artifact>-canary
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

require_command curl
require_command python3
require_env MENDER_SERVER_URL
require_env MENDER_ACCESS_TOKEN
require_env ARTIFACT_NAME
require_env DEVICE_IDS

DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-sensornode-${ARTIFACT_NAME}-canary}"
body="$(python3 -c '
import json, sys
name, artifact, ids = sys.argv[1:4]
devices = [d.strip() for d in ids.split(",") if d.strip()]
if not devices:
    raise SystemExit("DEVICE_IDS has no device IDs")
print(json.dumps({"name": name, "artifact_name": artifact, "devices": devices}))
' "$DEPLOYMENT_NAME" "$ARTIFACT_NAME" "$DEVICE_IDS")"

curl_opts=(--silent --show-error)
[[ -n "${MENDER_CA_CERT:-}" ]] && curl_opts+=(--cacert "$MENDER_CA_CERT")

headers="$(mktemp)"; response="$(mktemp)"
trap 'rm -f "$headers" "$response"' EXIT
status="$(curl "${curl_opts[@]}" -D "$headers" -o "$response" -w '%{http_code}' -X POST \
  -H "Authorization: Bearer $MENDER_ACCESS_TOKEN" \
  -H 'Content-Type: application/json' \
  -d "$body" \
  "${MENDER_SERVER_URL%/}/api/management/v1/deployments/deployments")"
if [[ "$status" != 201 ]]; then
  cat "$response" >&2; echo >&2
  die "Mender deployment creation failed with HTTP $status"
fi
deployment_id="$(awk -F/ 'tolower($1) ~ /^location:/ {print $NF}' "$headers" | tr -d '\r')"
info "created deployment $DEPLOYMENT_NAME (${deployment_id:-id not returned}) for devices: $DEVICE_IDS"
