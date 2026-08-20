#!/bin/sh
set -eu
systemctl is-active --quiet sensornode.service
curl --fail --silent --show-error --max-time 5 http://127.0.0.1:8080/health >/dev/null
[ -z "$(systemctl --failed --no-legend --plain || true)" ]
