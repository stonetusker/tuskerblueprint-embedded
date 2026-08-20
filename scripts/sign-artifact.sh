#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

ARTIFACT="${ARTIFACT:-}"
SIGNING_KEY="${SIGNING_KEY:-}"
require_command mender-artifact
require_file "$ARTIFACT"
require_file "$SIGNING_KEY"

mender-artifact sign "$ARTIFACT" --key "$SIGNING_KEY"
sha256sum "$ARTIFACT" > "$ARTIFACT.sha256"
info "signed $ARTIFACT"
