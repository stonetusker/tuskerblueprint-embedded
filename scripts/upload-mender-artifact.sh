#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

ARTIFACT="${ARTIFACT:-}"
require_file "$ARTIFACT"
require_command "${MENDER_CLI_BIN:-mender-cli}"
require_env MENDER_SERVER_URL
require_env MENDER_ACCESS_TOKEN

"${MENDER_CLI_BIN:-mender-cli}" --server "$MENDER_SERVER_URL" --token "$MENDER_ACCESS_TOKEN" \
  artifacts upload "$ARTIFACT"
info "artifact uploaded to Mender"
