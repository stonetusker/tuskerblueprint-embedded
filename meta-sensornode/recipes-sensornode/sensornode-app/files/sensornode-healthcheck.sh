#!/bin/sh
set -eu

attempts=30
interval=1
[ "${1:-}" = "--startup" ] || attempts=3

while [ "$attempts" -gt 0 ]; do
    if curl --fail --silent --show-error --max-time 2 http://127.0.0.1:8080/health >/dev/null; then
        exit 0
    fi
    attempts=$((attempts - 1))
    sleep "$interval"
done

journalctl -u sensornode.service --no-pager -n 100 >&2 || true
exit 1
