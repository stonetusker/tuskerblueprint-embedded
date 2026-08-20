#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
require_command curl
require_env JENKINS_URL
require_env JENKINS_USER
require_env JENKINS_API_TOKEN
require_env JENKINS_REPOSITORY_URL

job="${JENKINS_JOB_NAME:-sensornode-diagnostic-build}"
template="$PROJECT_ROOT/ci/jenkins/job-config/sensornode-diagnostic-build.xml.template"
require_file "$template"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
python3 - "$template" "$tmp" "$JENKINS_REPOSITORY_URL" <<'PY'
from pathlib import Path
import html, sys
src, dst, url = sys.argv[1:]
Path(dst).write_text(Path(src).read_text().replace('__REPOSITORY_URL__', html.escape(url)), encoding='utf-8')
PY

code="$(curl -sS -o /tmp/jenkins-job-response.$$ -w '%{http_code}' \
  -u "$JENKINS_USER:$JENKINS_API_TOKEN" \
  -H 'Content-Type: application/xml' \
  --data-binary "@$tmp" \
  "$JENKINS_URL/createItem?name=$job" || true)"
if [[ "$code" == "200" ]]; then
  info "created Jenkins job $job"
  rm -f /tmp/jenkins-job-response.$$
  exit 0
fi
if [[ "$code" == "400" || "$code" == "409" ]]; then
  code="$(curl -sS -o /tmp/jenkins-job-response.$$ -w '%{http_code}' \
    -u "$JENKINS_USER:$JENKINS_API_TOKEN" \
    -H 'Content-Type: application/xml' \
    --data-binary "@$tmp" \
    "$JENKINS_URL/job/$job/config.xml" || true)"
  [[ "$code" == "200" ]] && { info "updated Jenkins job $job"; rm -f /tmp/jenkins-job-response.$$; exit 0; }
fi
cat /tmp/jenkins-job-response.$$ >&2 || true
rm -f /tmp/jenkins-job-response.$$
die "Jenkins job configuration failed with HTTP $code"
