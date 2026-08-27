#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/lib/common.sh"

build_builder=1
while (($#)); do
  case "$1" in
    --skip-builder) build_builder=0 ;;
    --help|-h)
      cat <<'USAGE'
Usage: scripts/bootstrap-ubuntu24.sh [--skip-builder]

Installs the Ubuntu 24.04 host packages required for local development,
Yocto container builds, QEMU validation, Docker Compose services, Ansible,
and repository verification. The script does not install or configure
third-party SaaS credentials, GitHub runners, Jenkins, or Mender server data.
USAGE
      exit 0
      ;;
    *) die "unknown option: $1" ;;
  esac
  shift
done

require_file /etc/os-release
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "Ubuntu is required; detected ${ID:-unknown}"
[[ "${VERSION_ID:-}" == 24.* ]] || die "Ubuntu 24.x is required; detected ${VERSION_ID:-unknown}"

arch="$(uname -m)"
case "$arch" in
  x86_64|aarch64) ;;
  *) die "unsupported host architecture: $arch (supported: x86_64, aarch64)" ;;
esac

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
  login_user="${SUDO_USER:-root}"
else
  require_command sudo
  SUDO=(sudo)
  login_user="${USER}"
fi

info "Ensure that Docker is installed on your machine"

info "installing Ubuntu 24 host dependencies"
"${SUDO[@]}" apt-get update
"${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ansible-core ca-certificates curl git golang-go jq make openssh-client \
  python3 python3-pip python3-venv qemu-system-arm qemu-utils rsync shellcheck socat \
  unzip xz-utils zstd

# Ubuntu 24.04 uses docker-compose-v2 in the standard archive. Keep a fallback
# for derivative 24.x images that expose the plugin under a different package.
if ! docker compose version >/dev/null 2>&1; then
  if ! "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose-v2; then
    "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose-plugin
  fi
fi

"${SUDO[@]}" systemctl enable --now docker
if [[ "$login_user" != "root" ]]; then
  "${SUDO[@]}" usermod -aG docker "$login_user"
fi

mkdir -p "$root/cache/downloads" "$root/cache/sstate" "$root/artifacts" "$root/build" "$root/bin"

if [[ ! -x "$root/.venv/bin/python" ]]; then
  python3 -m venv "$root/.venv"
fi
"$root/.venv/bin/pip" install --upgrade pip
"$root/.venv/bin/pip" install -r "$root/tools/requirements.txt"

if [[ "$build_builder" == 1 ]]; then
  if docker info >/dev/null 2>&1; then
    "$root/scripts/build-builder-image.sh"
  else
    warn "Docker is installed, but this shell cannot access the daemon yet."
    warn "Log out/in or run: newgrp docker"
    warn "Then run: scripts/build-builder-image.sh"
  fi
fi

info "bootstrap completed"
info "run scripts/doctor-ubuntu24.sh before the first Yocto build"
