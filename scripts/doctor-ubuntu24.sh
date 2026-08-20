#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/lib/common.sh"

strict=0
[[ "${1:-}" == "--strict" ]] && strict=1
failures=0
warnings=0

pass() { printf 'PASS  %s\n' "$*"; }
warning() { printf 'WARN  %s\n' "$*"; warnings=$((warnings+1)); }
failure() { printf 'FAIL  %s\n' "$*"; failures=$((failures+1)); }

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == 24.* ]]; then
    pass "Ubuntu ${VERSION_ID}"
  else
    failure "requires Ubuntu 24.x; detected ${ID:-unknown} ${VERSION_ID:-unknown}"
  fi
else
  failure "/etc/os-release is unavailable"
fi

case "$(uname -m)" in
  x86_64|aarch64) pass "host architecture $(uname -m)" ;;
  *) failure "unsupported host architecture $(uname -m)" ;;
esac

for cmd in git curl jq make python3 docker qemu-system-aarch64 qemu-img rsync sha256sum; do
  command -v "$cmd" >/dev/null 2>&1 && pass "command $cmd" || failure "missing command $cmd"
done

if command -v go >/dev/null 2>&1; then
  pass "Go $(go version | awk '{print $3}')"
else
  warning "Go is missing; Yocto can still build the embedded app, but local app tests need Go"
fi

if docker info >/dev/null 2>&1; then
  pass "Docker daemon access"
  docker compose version >/dev/null 2>&1 && pass "Docker Compose v2" || failure "Docker Compose v2 is unavailable"
else
  failure "cannot access Docker daemon; log out/in after docker-group change or run newgrp docker"
fi

mem_kib="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
mem_gib=$((mem_kib / 1024 / 1024))
if ((mem_gib >= 16)); then
  pass "memory ${mem_gib} GiB"
elif ((mem_gib >= 8)); then
  warning "memory ${mem_gib} GiB; 16 GiB minimum recommended and 24 GiB preferred"
else
  failure "memory ${mem_gib} GiB is too small for a reliable Yocto build"
fi

free_kib="$(df -Pk "$root" | awk 'NR==2 {print $4}')"
free_gib=$((free_kib / 1024 / 1024))
if ((free_gib >= 120)); then
  pass "free disk ${free_gib} GiB"
elif ((free_gib >= 60)); then
  warning "free disk ${free_gib} GiB; use at least 120 GiB for repeated Yocto builds"
else
  failure "free disk ${free_gib} GiB; at least 60 GiB is required for this reference build"
fi

if [[ "$(uname -m)" == "aarch64" && -r /dev/kvm && -w /dev/kvm ]]; then
  pass "ARM64 KVM acceleration available"
else
  warning "QEMU will use TCG unless ARM64 KVM is available; this is valid but slower"
fi

version="$(tr -d '[:space:]' < "$root/VERSION")"
builder="${BUILDER_IMAGE:-stonetusker/yocto-builder:$version}"
if docker image inspect "$builder" >/dev/null 2>&1; then
  pass "builder image $builder"
else
  warning "builder image $builder not built; run scripts/build-builder-image.sh"
fi

if [[ -x "$root/.venv/bin/python" ]]; then
  pass "repository Python virtual environment"
else
  warning "repository virtual environment missing; run make setup"
fi

printf '\nSummary: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
if ((failures > 0)); then
  exit 1
fi
if ((strict == 1 && warnings > 0)); then
  exit 2
fi
