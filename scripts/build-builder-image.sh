#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/lib/common.sh"
require_command docker
version="$(tr -d '[:space:]' < "$root/VERSION")"
image="${BUILDER_IMAGE:-stonetusker/yocto-builder:$version}"
uid="${BUILDER_UID:-$(id -u)}"
gid="${BUILDER_GID:-$(id -g)}"
kas_version="${KAS_VERSION:-4.5}"
info "building $image for $(uname -m) with uid=$uid gid=$gid kas=$kas_version"
docker build --progress=plain\
  --build-arg USER_ID="$uid" \
  --build-arg GROUP_ID="$gid" \
  --build-arg KAS_VERSION="$kas_version" \
  --tag "$image" \
  "$root/containers/yocto-builder"
