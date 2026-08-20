#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/lib/common.sh"
mkdir -p "$root/cache/downloads" "$root/cache/sstate" "$root/artifacts" "$root/build" "$root/bin"
[[ -f "$root/config/project.env" ]] || cp "$root/config/project.env.example" "$root/config/project.env"
if [[ ! -x "$root/.venv/bin/python" ]]; then
  python3 -m venv "$root/.venv"
  "$root/.venv/bin/pip" install -r "$root/tools/requirements.txt"
fi
info "workspace initialized"
