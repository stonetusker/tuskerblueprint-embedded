#!/usr/bin/env bash
# Create (or, with --update, replace) the SensorNode Jenkins jobs from
# ci/jenkins/job-config/*.xml.template through the Jenkins REST API.
#
#   scripts/configure-jenkins-job.sh [--update] [job-name ...]
#
# With no job names, every template is applied. Existing jobs are left alone
# unless --update is given: replacing a job's config drops the parameters that
# Declarative Pipeline registers on the first run, so update deliberately.
#
# Required: JENKINS_URL, JENKINS_USER, JENKINS_API_TOKEN, JENKINS_REPOSITORY_URL
# Optional: JENKINS_GIT_CREDENTIALS_ID (Jenkins credential used to clone the repository)
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
require_command curl
require_command python3
require_env JENKINS_URL
require_env JENKINS_USER
require_env JENKINS_API_TOKEN
require_env JENKINS_REPOSITORY_URL

update=0
jobs=()
for arg in "$@"; do
  case "$arg" in
    --update) update=1 ;;
    -*) die "unknown option: $arg" ;;
    *) jobs+=("$arg") ;;
  esac
done
template_dir="$PROJECT_ROOT/ci/jenkins/job-config"
if [[ ${#jobs[@]} -eq 0 ]]; then
  for t in "$template_dir"/*.xml.template; do
    jobs+=("$(basename "$t" .xml.template)")
  done
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
api() { # method path [data-file]
  local args=(-sS -o "$tmp/response" -w '%{http_code}' -u "$JENKINS_USER:$JENKINS_API_TOKEN" -X "$1")
  [[ -n "${3:-}" ]] && args+=(-H 'Content-Type: application/xml' --data-binary "@$3")
  curl "${args[@]}" "$JENKINS_URL$2" || true
}

for job in "${jobs[@]}"; do
  template="$template_dir/$job.xml.template"
  require_file "$template"
  python3 - "$template" "$tmp/$job.xml" "$JENKINS_REPOSITORY_URL" "${JENKINS_GIT_CREDENTIALS_ID:-}" <<'PY'
from pathlib import Path
import html, re, sys
src, dst, url, cred = sys.argv[1:]
text = Path(src).read_text(encoding='utf-8').replace('__REPOSITORY_URL__', html.escape(url))
if cred:
    text = text.replace('__GIT_CREDENTIALS_ID__', html.escape(cred))
else:
    text = re.sub(r'\s*<credentialsId>__GIT_CREDENTIALS_ID__</credentialsId>', '', text)
Path(dst).write_text(text, encoding='utf-8')
PY
  if [[ "$(api GET "/job/$job/api/json")" == "200" ]]; then
    if (( update )); then
      code="$(api POST "/job/$job/config.xml" "$tmp/$job.xml")"
      [[ "$code" == "200" ]] || { cat "$tmp/response" >&2; die "updating $job failed with HTTP $code"; }
      info "updated Jenkins job $job"
    else
      info "Jenkins job $job exists; left unchanged (use --update to replace it)"
    fi
  else
    code="$(api POST "/createItem?name=$job" "$tmp/$job.xml")"
    [[ "$code" == "200" ]] || { cat "$tmp/response" >&2; die "creating $job failed with HTTP $code"; }
    info "created Jenkins job $job"
  fi
done
