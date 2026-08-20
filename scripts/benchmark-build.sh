#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

require_command python3
RESULT_DIR="${RESULT_DIR:-$PROJECT_ROOT/artifacts/benchmark/$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$RESULT_DIR"
clean_cache="$(mktemp -d "$PROJECT_ROOT/.benchmark-clean-cache.XXXXXX")"
clean_build="$(mktemp -d "$PROJECT_ROOT/.benchmark-clean-build.XXXXXX")"
cached_build="$(mktemp -d "$PROJECT_ROOT/.benchmark-cached-build.XXXXXX")"
trap 'rm -rf "$clean_cache" "$clean_build" "$cached_build"' EXIT

run_case() {
  local name="$1" cache_dir="$2" build_dir="$3"
  local start end result=pass
  mkdir -p "$cache_dir" "$build_dir" "$RESULT_DIR/$name"
  start="$(date +%s)"
  if ! CACHE_DIR="$cache_dir" BUILD_DIR="$build_dir" ARTIFACT_DIR="$RESULT_DIR/$name" \
      KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci "$PROJECT_ROOT/scripts/build-image.sh"; then
    result=fail
  fi
  end="$(date +%s)"
  printf '%s,%s,%s,%s,%s\n' "$name" "$((end-start))" "$result" "$build_dir" "$cache_dir" >> "$RESULT_DIR/results.csv"
  [[ "$result" == pass ]]
}

printf 'case,elapsed_seconds,result,build_dir,cache_dir\n' > "$RESULT_DIR/results.csv"
run_case clean "$clean_cache" "$clean_build"
run_case cached "${CACHE_DIR:-$PROJECT_ROOT/cache}" "$cached_build"
python3 "$PROJECT_ROOT/tools/render_benchmark_summary.py" "$RESULT_DIR/results.csv" "$RESULT_DIR/summary.md"
info "benchmark evidence: $RESULT_DIR"
