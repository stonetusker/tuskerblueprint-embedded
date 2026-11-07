---
id: IMPL-DEMO-001
title: Demo Guide
status: Approved
version: 0.1.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-11-07
updated: 2026-11-07
traces_to:
  - PRD-REQ-006
  - PRD-REQ-007
  - RUN-MENDER-001
  - RUN-JENKINS-001
verified_by:
  []
---

# Demo Guide

How to give a live demonstration of TuskerBlueprint Embedded on the single Ubuntu 24 host (`192.168.0.109`, `docker.mender.io`), starting from a machine that has just been powered on or rebooted.

The demo shows the SensorNode lifecycle end to end: a Yocto-built embedded Linux image, CI on a self-hosted GitHub Actions runner and Jenkins, a shared MinIO build cache, and a Mender over-the-air (OTA) update to a QEMU device that installs a healthy release and **automatically rolls back** a broken one.

## What is real, and what is not

Say this plainly; it keeps the demo credible.

| Shown live | Status |
|---|---|
| Mender OTA install, reboot, health gate, commit on a QEMU canary | Proven (EVID-003), re-run on 2026-11-07 |
| Automatic device rollback of an unhealthy release | Proven (EVID-004), re-run on 2026-11-07 |
| Jenkins pipeline and `FAILURE_DRILL` (broken image stopped in CI) | Ready; rehearse once before showing it live |
| GitHub Actions self-hosted runner, nightly builds | Working |
| Jenkins MCP / Claude diagnostics | Contract and guide only — present as roadmap, do not demo live |
| Artifact signing, three-device fleet, physical board | Not done — roadmap |

## Endpoints and credentials

Your laptop needs `192.168.0.109 docker.mender.io` in `/etc/hosts`.

| What | URL | Login |
|---|---|---|
| Mender UI | <https://docker.mender.io/ui/> (self-signed certificate; accept it once) | Mender admin account already in use (also in `~/mender/automation.env` on the host) |
| Jenkins | <http://docker.mender.io:8088/> | Jenkins admin account |
| MinIO cache console | <http://docker.mender.io:9001/> | MinIO root user from `infra/compose/minio` |
| GitHub Actions | `stonetusker/tuskerblueprint-embedded` → Actions; Settings → Actions → Runners | GitHub account |
| Device app (during the demo only) | <http://127.0.0.1:18091/version> through the SSH tunnel below | — |

## 1. After a restart: bring everything up (5 minutes)

```bash
ssh subeesh@192.168.0.109
cd /home/subeesh/tuskerblueprint-embedded
scripts/demo-services-up.sh
```

All lines must be `PASS`, ending with `all services up`. Only the Mender server needs starting after a reboot; the script does that and verifies the rest. If anything fails, follow [Host Service Restart After Reboot](host-service-restart.md).

Never run `docker compose down` on the Mender stack: its data is not in named volumes and would be lost (details in the restart guide).

## 2. Pre-demo checklist (T-30 minutes)

- [ ] `scripts/demo-services-up.sh --check` is all `PASS`.
- [ ] Mender UI opens and you are logged in; **Devices** shows `sensornode-canary-01` accepted; **Releases** lists `sensornode-0.3.0-102-ff2bd03` and `sensornode-0.3.0-103-ff2bd03-broken`.
- [ ] Jenkins opens, job `sensornode-diagnostic-build` is visible, node `ubuntu24` is online (Manage Jenkins → Nodes).
- [ ] No QEMU device is already running: `pgrep -fa qemu-system` prints nothing.
- [ ] Nothing else is building on the host (`pgrep -fa bitbake` prints nothing); a build slows QEMU noticeably.
- [ ] Laptop: four windows ready — Mender UI (Deployments tab), Jenkins, and two terminals (layout below).

Terminal layout on the laptop:

| Terminal | Command | Purpose |
|---|---|---|
| A — driver | `ssh subeesh@192.168.0.109` | Runs the OTA scenario |
| B — device console | `ssh subeesh@192.168.0.109` then, once the device starts, `tail -f ~/tuskerblueprint-embedded/qemu-fleet/state/sensornode-canary-01/serial.log` | Shows boot, GRUB slot switch, and the health gate |
| C — device version (optional) | `ssh -N -L 18091:127.0.0.1:18091 subeesh@192.168.0.109` and in a browser open `http://127.0.0.1:18091/version` (refresh) or run `watch -n2 curl -s 127.0.0.1:18091/version` | Shows the running image version change |

## 3. Demo flow (about 25 minutes)

### 3.1 Story and architecture (3 min)

Open `README.md` and `docs/04-architecture/`. The message: one specification-driven repository produces the image (Yocto/kas, `meta-sensornode`), builds it reproducibly with pinned sources (`kas/source-lock.yml`) and a shared cache, tests it in QEMU before it can be released, and ships it through Mender with A/B partitions and a health gate so a bad release cannot brick a device.

### 3.2 Build and CI (5 min)

1. **GitHub Actions** — show the self-hosted runner online and a recent successful nightly run (`.github/workflows/nightly.yml`).
2. **MinIO cache** — open the console and show the `yocto-sstate` and `yocto-downloads` buckets; point out that the warm-cache CI build takes about 2 minutes (`artifacts/build-duration-seconds` = 106 s) instead of hours.
3. **Jenkins** — open `sensornode-diagnostic-build` and its last builds. Stages: Checkout → Validate → Build and QEMU Test → Diagnostic Evidence → Human Approval for Rebuild.

Optional, live (only if rehearsed): **Build with Parameters** → `FAILURE_DRILL` = true → Build. Jenkins builds `sensornode-image-broken`, the QEMU health test fails, the build goes red, the diagnostic bundle is archived, and nothing is promoted to Mender. Start it at the beginning of section 3.2 so it finishes while you talk. This is the "pipeline prevention" control (`mender/demo-scenarios/pipeline-prevention.md`).

### 3.3 Fleet view in Mender (2 min)

Mender UI → **Devices** (`sensornode-canary-01`, its inventory), **Releases** (the healthy `-102` and the deliberately broken `-103-broken`), **Deployments → Finished** (history of earlier proven runs).

### 3.4 Live OTA update and automatic rollback (about 7 min of runtime; allow 10)

In terminal A:

```bash
cd ~/tuskerblueprint-embedded
. ~/mender/automation.env
MENDER_USER=$MENDER_AUTOMATION_USER MENDER_PASSWORD=$MENDER_AUTOMATION_PASSWORD \
MENDER_CA_CERT=$HOME/mender/integration-3.8.5/cert/cert.crt \
FACTORY_DISK=$HOME/tbtest/ota-inputs/101/sensornode-image-release-qemuarm64.uefiimg \
GOOD_ARTIFACT=$HOME/tbtest/ota-inputs/102/sensornode-image-release-qemuarm64.mender \
BROKEN_ARTIFACT=$HOME/tbtest/ota-inputs/103/sensornode-image-release-broken-qemuarm64.mender \
  mender/demo-scenarios/run-ota-e2e.sh
```

Narrate while it runs. The script prints each milestone with a timestamp:

| Phase | Terminal A prints | Show the audience | Typical time |
|---|---|---|---|
| Factory boot | `canary sensornode-canary-01 is healthy on factory image 0.3.0-101-ff2bd03` | Terminal B: UEFI → GRUB → systemd boot; terminal C: `0.3.0-101` | ~25 s |
| Enrolment | `accepted auth set …` | Mender **Devices**: a factory-fresh disk has a new key; the script accepts it (in production this is done by preauthorisation) | ~10 s |
| Healthy update | `canary deployment … created` then `canary committed … reports 0.3.0-102-ff2bd03` | Mender **Deployments → In progress**: downloading → installing → rebooting → success. Terminal B: reboot into the other root partition, health script passes. Terminal C: `0.3.0-102` | ~2 min |
| Broken update | `rollback deployment … created` | The `-broken` release installs and reboots like any other | — |
| Health gate refuses commit | `unhealthy … was rejected and the device rolled back to 0.3.0-102-ff2bd03` | Terminal B: `ArtifactCommit_Enter_50_sensornode-health` fails (`/health` returns 503), Mender reboots into the previous slot. Mender shows the deployment as **failure**. Terminal C: back on `0.3.0-102` | ~5 min |
| Done | `OTA end-to-end passed; evidence in …/artifacts/ota/<run>` | — | — |

Key talking point: the broken image booted fine — only the application-level health gate caught it, and the device healed itself without anyone touching it.

### 3.5 Evidence (2 min)

```bash
ls ~/tuskerblueprint-embedded/artifacts/ota/$(ls -t ~/tuskerblueprint-embedded/artifacts/ota | head -1)
cat ~/tuskerblueprint-embedded/artifacts/ota/$(ls -t ~/tuskerblueprint-embedded/artifacts/ota | head -1)/summary.json
```

Every run leaves API responses, device deployment logs, the serial console, and `SHA256SUMS`. Tie this back to `docs/15-evidence/` and `docs/13-traceability/`: requirements → tests → evidence.

### 3.6 Roadmap (1 min)

Signed artifacts with `ArtifactVerifyKey`, a three-device canary → pilot → fleet rollout, Jenkins MCP with a read-only Claude identity and human approval, and physical-board validation.

## 4. If something goes wrong mid-demo

| Symptom | Action |
|---|---|
| `device … was not enrolled` | Mender UI → Devices → Pending → accept `sensornode-canary-01`, then re-run the command. |
| `device already running: sensornode-canary-01` | `pkill -f 'qemu-system-aarch64 -name sensornode-canary-01'`, then re-run. |
| Deployment stuck in downloading | `docker logs --tail 50 integration-385-mender-deployments-1`; confirm the override still sets `DEPLOYMENTS_AWS_EXTERNAL_URI`. |
| Mender UI login fails or shows no devices | Stop. Do not recreate the stack. Run `scripts/demo-services-up.sh --check` and see the restart guide. |
| Live run fails and time is short | Show the recorded run instead: `artifacts/ota/20261023T130809Z/` and `docs/15-evidence/ota-deployment-summary.md`, `rollback-summary.md`. |

## 5. After the demo

The script stops the QEMU device on exit, so nothing needs to be cleaned up. Each run adds two finished deployments to Mender's history and one evidence directory under `artifacts/ota/`; both are harmless. To shut the host down safely:

```bash
cd ~/mender && docker compose -f integration-3.8.5/docker-compose.yml \
  -f integration-3.8.5/docker-compose.storage.minio.yml -f docker-compose.override.yml \
  --env-file mender.env stop
sudo poweroff
```

Use `stop`, not `down`. After the next power-on, start again at section 1.

## Rehearsal record

| Date | Operator | Result | Evidence |
|---|---|---|---|
| 2026-10-23 | Subeesh | OTA install + rollback passed (3 runs) | `artifacts/ota/20261023T130809Z/` |
| 2026-11-07 | Claude Code, after host reboot | Services restored with `scripts/demo-services-up.sh`; OTA install + rollback passed in 7 min 6 s (healthy update 106 s, rollback 4 min 46 s) | `artifacts/ota/20261107T013714Z/` |
