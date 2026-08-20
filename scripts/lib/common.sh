#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Optional non-secret project defaults. Environment variables set by CI or the
# caller take precedence because project.env is loaded only for unset values.
if [[ -f "$PROJECT_ROOT/config/project.env" ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || continue
    key="${line%%=*}"
    value="${line#*=}"
    if [[ -z "${!key+x}" ]]; then
      printf -v "$key" "%s" "$value"
      export "$key"
    fi
  done < "$PROJECT_ROOT/config/project.env"
fi

project_version() { tr -d '[:space:]' < "$PROJECT_ROOT/VERSION"; }

log() { printf '%s [%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" >&2; }
info() { log INFO "$*"; }
warn() { log WARN "$*"; }
die() { log ERROR "$*"; exit 1; }
require_command() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"; }
require_file() { [[ -f "$1" ]] || die "required file not found: $1"; }
require_env() { [[ -n "${!1:-}" ]] || die "required environment variable not set: $1"; }
sha256_file() { sha256sum "$1" | awk '{print $1}'; }
cleanup_dir() { [[ -n "$1" && "$1" != "/" ]] || die "unsafe cleanup path"; rm -rf -- "$1"; }
