#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

require_command "${MENDER_CLI_BIN:-mender-cli}"
require_env MENDER_SERVER_URL
require_env MENDER_ACCESS_TOKEN
require_env ARTIFACT_NAME
require_env DEVICE_IDS

DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-sensornode-${ARTIFACT_NAME}-canary}"
"${MENDER_CLI_BIN:-mender-cli}" --server "$MENDER_SERVER_URL" --token "$MENDER_ACCESS_TOKEN" \
  deployments create --name "$DEPLOYMENT_NAME" --artifact-name "$ARTIFACT_NAME" --devices "$DEVICE_IDS"
info "created deployment $DEPLOYMENT_NAME"
