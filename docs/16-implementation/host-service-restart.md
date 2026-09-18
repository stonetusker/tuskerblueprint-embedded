---
id: IMPL-SVC-001
title: Host Service Restart After Reboot
status: Approved
version: 0.1.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-09-18
updated: 2026-09-18
traces_to:
  - OPS-001
  - RUN-MENDER-001
  - RUN-JENKINS-001
verified_by:
  []
---

# Host Service Restart After Reboot

Concrete recovery procedure for the single Ubuntu 24 host (`docker.mender.io`) after a reboot, a Docker daemon restart, or an intentional `docker compose down`. This is the implementation of the intent set out in `docs/09-operations/operating-model.md`, `mender-runbook.md`, and `jenkins-runbook.md`.

## Purpose

Restore Jenkins, MinIO, the GitHub Actions runner, and the Mender server to a known-good running state with the fewest manual steps, and confirm each one before relying on it (e.g. before recording a demo).

## What restarts automatically

Docker itself (`systemctl is-enabled docker`) and the GitHub Actions runner service are both `enabled`, so they come back on their own after a reboot.

| Service | Compose `restart:` policy | Comes back after reboot on its own? |
|---|---|---|
| Jenkins (`infra/compose/jenkins`) | `unless-stopped` | Yes |
| MinIO cache (`infra/compose/minio`) | `unless-stopped` | Yes |
| GitHub Actions runner | systemd, `enabled` | Yes |
| Mender server (`~/mender/integration-3.8.5` + storage/override) | `on-failure` (from `common.yml`) | **No** — `on-failure` only restarts a crashed container while the daemon keeps running, not after the daemon/host restarts. This stack needs the manual step below every time. |
| Reverse proxy (`infra/compose/reverse-proxy`) | `unless-stopped` | Not applicable today — not deployed; no `BASE_DOMAIN`/`ACME_EMAIL` configured. Only fronts Jenkins/MinIO on a public domain, not the Mender server itself. |

In short: after a reboot, only the Mender server needs a manual start. Give Jenkins/MinIO/the runner a minute to come up, then confirm with the checks below.

## Preconditions

- SSH access: `ssh subeesh@docker.mender.io`
- Repository checked out at `/home/subeesh/tuskerblueprint-embedded`
- Mender bundle and env files present at `/home/subeesh/mender/` (`integration-3.8.5/`, `mender.env`, `docker-compose.override.yml`) — these are host-local, not part of the git repository

## Procedure

### 1. Confirm what came back on its own

```bash
ssh subeesh@docker.mender.io
docker ps --format 'table {{.Names}}\t{{.Status}}'
systemctl is-active actions.runner.stonetusker-tuskerblueprint-embedded.subeesh-ubuntu24-laptop.service
```

Expect `jenkins-jenkins-1` and `minio-minio-1` already `Up (healthy)`, and the runner `active`. If either compose service is missing, start it directly:

```bash
cd /home/subeesh/tuskerblueprint-embedded/infra/compose/jenkins && docker compose up -d
cd /home/subeesh/tuskerblueprint-embedded/infra/compose/minio && docker compose up -d
```

### 2. Start the Mender server (manual every time)

```bash
cd /home/subeesh/mender
docker compose \
  -f integration-3.8.5/docker-compose.yml \
  -f integration-3.8.5/docker-compose.storage.minio.yml \
  -f docker-compose.override.yml \
  --env-file mender.env up -d
```

This brings up all 14 Mender containers (`mongo`, `nats`, `useradm`, `device-auth`, `inventory`, `deployments`, `deviceconnect`, `deviceconfig`, `iot-manager`, `workflows-server`, `workflows-worker`, `create-artifact-worker`, the internal `minio` object store, `gui`, and `mender-api-gateway`). Mongo data is a persistent volume, so existing users, devices, and deployment history survive the restart — do not recreate the admin account; log in with the credentials already in use.

Startup takes roughly 30–60 seconds for every service to report healthy.

## Verification

```bash
# From the host or your workstation
curl -sk -o /dev/null -w 'Mender UI: HTTP %{http_code}\n' https://docker.mender.io/ui/
curl -sk -o /dev/null -w 'Jenkins:   HTTP %{http_code}\n' http://docker.mender.io:8088/
curl -sk -o /dev/null -w 'MinIO:     HTTP %{http_code}\n' http://docker.mender.io:9001/
```

Expect `Mender UI: HTTP 200`, `Jenkins: HTTP 403` (reachable, login required — not an error), `MinIO: HTTP 200`.

```bash
# On the host, confirm no container is stuck restarting
docker ps -a --format '{{.Names}} {{.Status}}' | grep -vi 'up '
```

Expect no output. Anything listed as `Restarting` or `Exited` needs its own log check (`docker logs <name>`) before you continue.

## Rollback

If a fresh `up -d` leaves a service unhealthy, stop only the Mender stack and retry rather than touching Jenkins/MinIO, which are independent:

```bash
cd /home/subeesh/mender
docker compose -f integration-3.8.5/docker-compose.yml -f integration-3.8.5/docker-compose.storage.minio.yml -f docker-compose.override.yml --env-file mender.env down
# investigate, then repeat the "Start the Mender server" step
```

`down` (without `-v`) preserves the named volumes, so Mongo/MinIO data is not lost.

## Evidence

Record in the completion log: operator, timestamp, which services required a manual start, and the verification output above.

## Escalation

If containers stay unhealthy after two retries, capture `docker compose logs --tail 200 <service>` for the failing service and escalate per `docs/09-operations/incident-response.md` rather than repeating restarts indefinitely.
