#!/usr/bin/env bash
# Upload a signed Mender Artifact to the Mender server (Deployments management API).
#
#   ARTIFACT             path to the .mender file
#   MENDER_SERVER_URL    for example https://docker.mender.io
#   MENDER_ACCESS_TOKEN  Mender personal access token
#   MENDER_CA_CERT       optional CA or server certificate for a self-signed server
#
# An artifact with the same name and device type that is already on the server is
# reported (HTTP 409) and treated as uploaded, so a retried promotion is safe.
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

ARTIFACT="${ARTIFACT:-}"
require_file "$ARTIFACT"
require_command curl
require_env MENDER_SERVER_URL
require_env MENDER_ACCESS_TOKEN

curl_opts=(--silent --show-error)
[[ -n "${MENDER_CA_CERT:-}" ]] && curl_opts+=(--cacert "$MENDER_CA_CERT")

response="$(mktemp)"
trap 'rm -f "$response"' EXIT
status="$(curl "${curl_opts[@]}" -o "$response" -w '%{http_code}' -X POST \
  -H "Authorization: Bearer $MENDER_ACCESS_TOKEN" \
  -F "artifact=@${ARTIFACT}" \
  "${MENDER_SERVER_URL%/}/api/management/v1/deployments/artifacts")"

case "$status" in
  201) info "artifact uploaded to Mender: $(basename "$ARTIFACT")" ;;
  409) info "artifact already on the Mender server: $(basename "$ARTIFACT")" ;;
  *) cat "$response" >&2; die "Mender artifact upload failed with HTTP $status" ;;
esac
