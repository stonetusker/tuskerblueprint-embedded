#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
count=0

# Only the repository's own files: CI workspaces also hold kas-fetched layers and build output.
list_files() {
  if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$root" ls-files -z --cached --others --exclude-standard -- '*.sh' '*mender-device-identity' '*Artifact*' |
      while IFS= read -r -d '' f; do [[ -f "$root/$f" ]] && printf '%s\0' "$root/$f"; done
  else
    find "$root" \( -path "$root/poky" -o -path "$root/meta-openembedded" -o -path "$root/meta-mender" -o -path "$root/build" \
      -o -path "$root/cache" -o -path "$root/artifacts" -o -path "$root/.git" \) -prune -o \
      -type f \( -name '*.sh' -o -name 'mender-device-identity' -o -name 'Artifact*' \) -print0
  fi
}

while IFS= read -r -d '' file; do
  bash -n "$file"
  count=$((count + 1))
done < <(list_files)

echo "Validated shell syntax for ${count} files."
