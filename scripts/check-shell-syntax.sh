#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
count=0

while IFS= read -r -d '' file; do
  bash -n "$file"
  count=$((count + 1))
done < <(find "$root" -type f \( -name '*.sh' -o -name 'mender-device-identity' -o -name 'Artifact*' \) -print0)

echo "Validated shell syntax for ${count} files."
