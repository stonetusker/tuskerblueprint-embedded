---
id: IMPL-SVC-001
title: Host Service Restart After Reboot
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-09-18
updated: 2026-11-07
traces_to:
  - OPS-001
  - RUN-MENDER-001
  - RUN-JENKINS-001
verified_by:
  []
---

# Host Service Restart After Reboot

Concrete recovery procedure for the single Ubuntu 24 host (`192.168.0.109`, `docker.mender.io`) after a reboot, a Docker daemon restart, or an intentional stop. This is the implementation of the intent set out in `docs/09-operations/operating-model.md`, `mender-runbook.md`, and `jenkins-runbook.md`. To give a demo once the services are up, continue with [Demo Guide](demo-guide.md).

## Purpose

Restore Jenkins, MinIO, the GitHub Actions runner, the Jenkins agent, and the Mender server to a known-good running state with the fewest manual steps, and confirm each one before relying on it (e.g. before a demo).

## Quick path (one command)

```bash
ssh subeesh@192.168.0.109
cd /home/subeesh/tuskerblueprint-embedded
scripts/demo-services-up.sh            # start anything that is down, then verify
```

Expected: every line is `PASS` and the last line reads `all services up`. The script is idempotent; running it when everything is already up changes nothing.

| Option | Effect |
|---|---|
| `--check` | Verify only, start nothing. Use it right before a demo. |
| `--backup` | Snapshot Mender Mongo and artifact storage to `~/mender/backups/<timestamp>/` before starting. |

A `FAIL` line names the failing service; use the manual procedure below for that service. Expected run time after a cold boot is 1–2 minutes.

## What restarts automatically

Docker itself (`systemctl is-enabled docker`), the GitHub Actions runner, and the Jenkins agent are systemd units that are `enabled`, so they come back on their own after a reboot.

| Service | Restart mechanism | Comes back after reboot on its own? |
|---|---|---|
| Jenkins (`infra/compose/jenkins`) | Compose `restart: unless-stopped` | Yes |
| MinIO cache (`infra/compose/minio`) | Compose `restart: unless-stopped` | Yes |
| GitHub Actions runner | systemd, `enabled` | Yes |
| Jenkins agent `ubuntu24` (label `yocto-vps8`) | systemd `jenkins-agent.service`, `enabled` | Yes — it retries until Jenkins is up (expect one or two `Waiting 7 seconds before retry` lines in the journal, then `Connected`) |
| Mender server (`~/mender/integration-3.8.5` + storage/override) | Compose `restart: on-failure` (from `common.yml`) | **No** — `on-failure` only restarts a crashed container while the daemon keeps running, not after the daemon/host restarts. This stack needs a manual start every time. |
| Reverse proxy (`infra/compose/reverse-proxy`) | Compose `restart: unless-stopped` | Not applicable today — not deployed; no `BASE_DOMAIN`/`ACME_EMAIL` configured. |
| QEMU canary `sensornode-canary-01` | Started on demand by `run-ota-e2e.sh` | No, by design — it only runs during a demo or test |

In short: after a reboot, only the Mender server needs a manual start.

## Mender data persistence (read before stopping anything)

The Mender bundle does **not** keep its data in named volumes:

| Data | Where it lives | Survives `docker compose stop`/`start`/`up -d` | Survives `docker compose down` or `rm` |
|---|---|---|---|
| Mongo (users, devices, deployments) | Anonymous volumes on the `…mender-mongo-1` container (`/data/db`, `/data/configdb`) | Yes | **No** — a recreated container gets new, empty anonymous volumes |
| Uploaded artifacts | `/export` inside the bundled `…minio-1` container's writable layer (the anonymous `/data` volume is empty) | Yes | **No** — removed with the container |

Therefore:

- Start the stack with `up -d` (reuses the existing containers) and stop it with `stop`. Never use `down`, `down -v`, or `docker rm` on the Mender stack.
- The Mongo and MinIO containers carry a hash prefix (e.g. `5d350a8370aa_integration-385-mender-mongo-1`). That is left over from an earlier interrupted recreate; it is harmless, and these are the containers holding the live data. Do not rename or remove them.
- Take a backup before any Mender maintenance: `scripts/demo-services-up.sh --backup`.

## Preconditions

- SSH access: `ssh subeesh@192.168.0.109` (or `subeesh@docker.mender.io`)
- Repository checked out at `/home/subeesh/tuskerblueprint-embedded`
- Mender bundle and env files present at `/home/subeesh/mender/` (`integration-3.8.5/`, `mender.env`, `docker-compose.override.yml`, `automation.env`, `keys-generated/`) — these are host-local, not part of the git repository
- Demo inputs present at `/home/subeesh/tbtest/ota-inputs/{101,102,103}/` (see [Demo Guide](demo-guide.md))

## Manual procedure

Use this when the quick path reports a failure, or to understand what the script does.

### 1. Confirm what came back on its own

```bash
docker ps -a --format 'table {{.Names}}\t{{.Status}}'
systemctl is-active actions.runner.stonetusker-tuskerblueprint-embedded.subeesh-ubuntu24-laptop.service
systemctl is-active jenkins-agent.service
```

Expect `jenkins-jenkins-1` and `minio-minio-1` `Up (healthy)`, both units `active`, and every `integration-385-*` container `Exited`. `yocto-30-builder` (`Exited (137)`) is an old, unused builder container and can be ignored.

If the agent unit is missing on a rebuilt host, install it once:

```bash
chmod 600 /home/subeesh/jenkins/secret-file
sudo install -m 0644 infra/compose/jenkins/agent/jenkins-agent.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now jenkins-agent.service
```

If either compose service is missing, start it directly:

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

This starts all 15 Mender containers (`mongo`, `nats`, `useradm`, `device-auth`, `inventory`, `deployments`, `deviceconnect`, `deviceconfig`, `iot-manager`, `workflows-server`, `workflows-worker`, `create-artifact-worker`, the bundled `minio` object store, `gui`, and `mender-api-gateway`). Existing users, devices, artifacts, and deployment history are kept because the existing containers are reused — do not recreate the admin account. Startup takes 30–60 seconds.

`docker-compose.override.yml` must keep `DEPLOYMENTS_AWS_EXTERNAL_URI: https://s3.docker.mender.io` on `mender-deployments`. Without it, presigned download URLs point at the Docker-internal `http://minio:9000` and every device download fails with `Host not found`. Devices resolve `docker.mender.io` and `s3.docker.mender.io` to `10.0.2.2` (QEMU slirp gateway) from their own `/etc/hosts`; the host does not need an `s3.docker.mender.io` entry.

## Verification

```bash
scripts/demo-services-up.sh --check
```

Or by hand, from the host or a workstation whose `/etc/hosts` maps `192.168.0.109 docker.mender.io`:

```bash
curl -sk -o /dev/null -w 'Mender UI: HTTP %{http_code}\n' https://docker.mender.io/ui/
curl -sk -o /dev/null -w 'Jenkins:   HTTP %{http_code}\n' http://docker.mender.io:8088/login
curl -sk -o /dev/null -w 'MinIO:     HTTP %{http_code}\n' http://docker.mender.io:9001/
docker ps -a --format '{{.Names}} {{.Status}}' | grep -E 'integration-385|jenkins|minio' | grep -vi ' up '
```

Expect `200` for all three and no output from the last command. Anything listed as `Restarting` or `Exited` needs `docker logs <name>` before you continue.

## Rollback

If a fresh `up -d` leaves a Mender service unhealthy, restart only that service, or stop and start the Mender stack. Jenkins and MinIO are independent and need not be touched.

```bash
cd /home/subeesh/mender
MC="docker compose -f integration-3.8.5/docker-compose.yml -f integration-3.8.5/docker-compose.storage.minio.yml -f docker-compose.override.yml --env-file mender.env"
$MC restart mender-deployments     # one service
$MC stop && $MC up -d              # whole stack
```

Do not use `down` (see [Mender data persistence](#mender-data-persistence-read-before-stopping-anything)). If data was lost anyway, restore from the latest `~/mender/backups/` snapshot into the recreated containers with `docker cp` while the stack is stopped.

## Evidence

Record in the completion log: operator, timestamp, which services required a manual start, and the `scripts/demo-services-up.sh --check` output.

## Escalation

If containers stay unhealthy after two retries, capture `docker logs --tail 200 <container>` for the failing service and escalate per `docs/09-operations/incident-response.md` rather than repeating restarts indefinitely.
