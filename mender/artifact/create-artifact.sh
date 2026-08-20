#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
exec "$root/scripts/create-mender-artifact.sh" "$@"
