#!/usr/bin/env bash
set -Eeuo pipefail
host="${DEVICE_HOST:-127.0.0.1}"
port="${APP_PORT:-8081}"
timeout="${TIMEOUT_SECONDS:-180}"
end=$((SECONDS + timeout))
while (( SECONDS < end )); do
  if curl --fail --silent --max-time 2 "http://${host}:${port}/health" >/dev/null; then
    exit 0
  fi
  sleep 2
done
printf 'device readiness timeout after %s seconds\n' "$timeout" >&2
exit 1
