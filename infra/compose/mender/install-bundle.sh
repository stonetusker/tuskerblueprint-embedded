#!/usr/bin/env bash
set -Eeuo pipefail

# Controlled adapter for an upstream self-hosted Mender bundle.
# The bundle itself is third-party software and therefore is not vendored here.
: "${MENDER_BUNDLE_ARCHIVE:?set MENDER_BUNDLE_ARCHIVE}"
: "${MENDER_BUNDLE_SHA256:?set MENDER_BUNDLE_SHA256}"
MENDER_INSTALL_ROOT="${MENDER_INSTALL_ROOT:-/srv/tuskerblueprint-embedded/mender/bundle}"
MENDER_COMPOSE_RELATIVE="${MENDER_COMPOSE_RELATIVE:-docker-compose.yml}"
MENDER_ENV_FILE="${MENDER_ENV_FILE:-}"

command -v docker >/dev/null 2>&1 || { echo 'docker is required' >&2; exit 1; }
actual="$(sha256sum "$MENDER_BUNDLE_ARCHIVE" | awk '{print $1}')"
[[ "$actual" == "$MENDER_BUNDLE_SHA256" ]] || {
  printf 'Mender bundle checksum mismatch: expected %s got %s\n' "$MENDER_BUNDLE_SHA256" "$actual" >&2
  exit 1
}

mkdir -p "$MENDER_INSTALL_ROOT"
tar -xzf "$MENDER_BUNDLE_ARCHIVE" -C "$MENDER_INSTALL_ROOT"
compose="$MENDER_INSTALL_ROOT/$MENDER_COMPOSE_RELATIVE"
[[ -f "$compose" ]] || {
  printf 'Mender bundle does not satisfy the reference contract; missing %s\n' "$compose" >&2
  exit 1
}

args=(-f "$compose")
if [[ -n "$MENDER_ENV_FILE" ]]; then
  [[ -f "$MENDER_ENV_FILE" ]] || { echo "missing env file: $MENDER_ENV_FILE" >&2; exit 1; }
  args=(--env-file "$MENDER_ENV_FILE" "${args[@]}")
fi

docker compose "${args[@]}" config >/dev/null
docker compose "${args[@]}" up -d
printf 'Mender bundle started from %s\n' "$compose"
