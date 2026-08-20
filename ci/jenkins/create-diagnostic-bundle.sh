#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
source "$root/scripts/lib/common.sh"
out="${ARTIFACT_DIR:-$root/artifacts}/diagnostics"
build_dir="${BUILD_DIR:-$root/build}"
mkdir -p "$out"

{
  printf 'job=%s\n' "${JOB_NAME:-local}"
  printf 'build_number=%s\n' "${BUILD_NUMBER:-local}"
  printf 'commit=%s\n' "$(git -C "$root" rev-parse HEAD 2>/dev/null || echo unknown)"
  printf 'result=%s\n' "${INITIAL_RESULT:-unknown}"
} > "$out/build.properties"

find "$build_dir" -type f \( -name 'log.do_*' -o -name 'console-latest.log' -o -name '*.xml' \) -size -10M \
  -exec cp --parents {} "$out" \; 2>/dev/null || true
python3 "$root/tools/redact_build_logs.py" --root "$out"
