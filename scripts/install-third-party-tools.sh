#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/lib/common.sh"

pins="${THIRD_PARTY_PINS_FILE:-$root/config/third-party-pins.env}"
[[ -f "$pins" ]] || die "copy config/third-party-pins.env.example to config/third-party-pins.env and populate verified URLs/checksums"
# shellcheck disable=SC1090
source "$pins"
install_dir="${TOOLS_INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$install_dir"

install_verified() {
  local name="$1" url="$2" expected="$3"
  [[ -n "$url" && -n "$expected" ]] || { warn "$name pin is empty; skipping"; return 0; }
  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN
  curl --fail --location --proto '=https' --tlsv1.2 "$url" -o "$tmp"
  local actual
  actual="$(sha256sum "$tmp" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || die "$name checksum mismatch"
  install -m 0755 "$tmp" "$install_dir/$name"
  info "installed verified $name to $install_dir/$name"
}

install_verified mc "${MINIO_CLIENT_URL:-}" "${MINIO_CLIENT_SHA256:-}"
install_verified mender-artifact "${MENDER_ARTIFACT_URL:-}" "${MENDER_ARTIFACT_SHA256:-}"
install_verified mender-cli "${MENDER_CLI_URL:-}" "${MENDER_CLI_SHA256:-}"
