#!/usr/bin/env bash
# Bring every host service back after a reboot and verify it is demo-ready.
# Safe to re-run: services already running are left alone.
#
#   scripts/demo-services-up.sh            start + verify
#   scripts/demo-services-up.sh --check    verify only, start nothing
#   scripts/demo-services-up.sh --backup   also snapshot Mender data first
#
# See docs/16-implementation/host-service-restart.md.
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"

MENDER_DIR="${MENDER_DIR:-$HOME/mender}"
MENDER_BUNDLE="${MENDER_BUNDLE:-integration-3.8.5}"
MENDER_URL="${MENDER_URL:-https://docker.mender.io}"
JENKINS_URL="${JENKINS_URL:-http://127.0.0.1:8088}"
MINIO_CONSOLE_URL="${MINIO_CONSOLE_URL:-http://127.0.0.1:9001}"
DEMO_INPUTS="${DEMO_INPUTS:-$HOME/tbtest/ota-inputs}"
RUNNER_UNIT="${RUNNER_UNIT:-actions.runner.stonetusker-tuskerblueprint-embedded.subeesh-ubuntu24-laptop.service}"
AGENT_UNIT="${AGENT_UNIT:-jenkins-agent.service}"
WAIT_SECONDS="${WAIT_SECONDS:-180}"

check_only=0
backup=0
for arg in "$@"; do
  case "$arg" in
    --check) check_only=1 ;;
    --backup) backup=1 ;;
    *) die "unknown argument: $arg" ;;
  esac
done

require_command docker
require_command curl
failures=0
pass() { info "PASS $*"; }
fail() { warn "FAIL $*"; failures=$((failures + 1)); }

mender_compose() {
  (cd "$MENDER_DIR" && docker compose \
    -f "$MENDER_BUNDLE/docker-compose.yml" \
    -f "$MENDER_BUNDLE/docker-compose.storage.minio.yml" \
    -f docker-compose.override.yml \
    --env-file mender.env "$@")
}

# 1. systemd services that should have come back on their own
for unit in docker.service "$RUNNER_UNIT" "$AGENT_UNIT"; do
  if ! systemctl is-active --quiet "$unit" && (( ! check_only )); then
    info "starting $unit"
    sudo systemctl start "$unit"
  fi
  systemctl is-active --quiet "$unit" && pass "$unit active" || fail "$unit not active"
done

# 2. Jenkins and MinIO cache (restart: unless-stopped, normally already up)
for stack in jenkins minio; do
  if (( ! check_only )); then
    (cd "$PROJECT_ROOT/infra/compose/$stack" && docker compose up -d --quiet-pull >/dev/null)
  fi
done

# 3. Mender server (restart: on-failure, never comes back after a reboot)
if (( backup )); then
  dest="$MENDER_DIR/backups/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$dest"
  for c in $(docker ps -a --format '{{.Names}}' | grep -E 'mender-mongo-1$|-minio-1$' | grep integration); do
    case "$c" in
      *mongo*) docker run --rm --volumes-from "$c" -v "$dest:/out" alpine:3 tar czf /out/mongo.tgz -C / data/db ;;
      *minio*) docker cp "$c:/export" - | gzip >"$dest/minio-export.tar.gz" ;;
    esac
  done
  info "Mender data backed up to $dest"
fi
if (( ! check_only )); then
  info "starting Mender server ($MENDER_BUNDLE)"
  mender_compose up -d >/dev/null 2>&1 || mender_compose up -d
fi

# 4. Wait until nothing is starting/restarting, then report stragglers
end=$((SECONDS + WAIT_SECONDS))
while (( SECONDS < end )); do
  docker ps --format '{{.Status}}' | grep -qiE 'starting|restarting' || break
  sleep 5
done
mender_up="$(docker ps --format '{{.Names}}' | grep -c '^.*integration-385-' || true)"
(( mender_up >= 15 )) && pass "Mender containers up ($mender_up)" || fail "only $mender_up of 15 Mender containers up"
stuck="$(docker ps -a --format '{{.Names}} {{.Status}}' | grep -E 'integration-385|jenkins|minio' | grep -viE ' up ' || true)"
[[ -z "$stuck" ]] && pass "no Exited/Restarting containers" || fail "containers not running: $stuck"

# 5. Endpoints
probe() {
  local name="$1" url="$2" want="$3" code
  code="$(curl -sk -o /dev/null -m 10 -w '%{http_code}' "$url" || true)"
  [[ "$code" =~ ^($want)$ ]] && pass "$name $url -> $code" || fail "$name $url -> $code (want $want)"
}
probe "Mender UI" "$MENDER_URL/ui/" 200
probe "Jenkins" "$JENKINS_URL/login" 200
probe "MinIO console" "$MINIO_CONSOLE_URL/" 200

# 6. Mender API: login, enrolled devices, uploaded artifacts
if [[ -f "$MENDER_DIR/automation.env" ]]; then
  set -a; source "$MENDER_DIR/automation.env"; set +a
  token="$(curl -sk -m 10 -X POST -u "$MENDER_AUTOMATION_USER:$MENDER_AUTOMATION_PASSWORD" \
    "$MENDER_URL/api/management/v1/useradm/auth/login" || true)"
  if [[ ${#token} -gt 100 ]]; then
    pass "Mender API login"
    count() { curl -sk -m 10 -H "Authorization: Bearer $token" "$MENDER_URL/api/management$1" |
      python3 -c 'import json,sys; print(len(json.load(sys.stdin)))'; }
    info "Mender devices: $(count '/v2/devauth/devices?per_page=500'), artifacts: $(count /v1/deployments/artifacts)"
  else
    fail "Mender API login"
  fi
else
  warn "skipping Mender API check: $MENDER_DIR/automation.env not found"
fi

# 7. Demo inputs for mender/demo-scenarios/run-ota-e2e.sh
for f in 101/sensornode-image-release-qemuarm64.uefiimg \
         102/sensornode-image-release-qemuarm64.mender \
         103/sensornode-image-release-broken-qemuarm64.mender; do
  [[ -f "$DEMO_INPUTS/$f" ]] && pass "demo input $f" || fail "demo input missing: $DEMO_INPUTS/$f"
done

if (( failures )); then
  die "$failures check(s) failed; see docs/16-implementation/host-service-restart.md"
fi
info "all services up; ready for docs/16-implementation/demo-guide.md"
