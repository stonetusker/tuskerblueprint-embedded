#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

ARTIFACT="${ARTIFACT:-}"
SIGNING_KEY="${SIGNING_KEY:-}"
require_command mender-artifact
require_file "$ARTIFACT"
require_file "$SIGNING_KEY"

mender-artifact sign "$ARTIFACT" --key "$SIGNING_KEY"
# Name only, so "sha256sum -c" works next to the downloaded file.
(cd "$(dirname "$ARTIFACT")" && sha256sum "$(basename "$ARTIFACT")") > "$ARTIFACT.sha256"
info "signed $ARTIFACT"
