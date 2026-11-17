---
id: IMPL-DEMO-001
title: Demo Guide
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-11-07
updated: 2026-11-17
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

The demo shows the SensorNode lifecycle end to end: a Yocto-built embedded Linux image, CI/CD in Jenkins (GitHub only hosts the repository), a shared MinIO build cache, and a Mender over-the-air (OTA) update to a QEMU device that installs a healthy release and **automatically rolls back** a broken one.

## What is real, and what is not

Say this plainly; it keeps the demo credible.

| Shown live | Status |
|---|---|
| Mender OTA install, reboot, health gate, commit on a QEMU canary | Proven (EVID-003), re-run on 2026-11-07 |
| Automatic device rollback of an unhealthy release | Proven (EVID-004), re-run on 2026-11-07 |
| Jenkins pipeline and `FAILURE_DRILL` (broken image stopped in CI) | Rehearsed on the host on 2026-11-12 with the pipeline scripts (broken image built in 246 s; QEMU test `test_02_health_endpoint` failed as intended). Run it once from the Jenkins UI before showing it live |
| Jenkins branch CI (`sensornode-ci`) and nightly build (`sensornode-nightly`) | `sensornode-ci » main` build #1 green on 2026-11-16 (Yocto build 611 s, 14 QEMU tests passed, 2 skipped, cache published). First nightly green at 02:00 UTC on 2026-11-17 |
| Jenkins release candidate, signing and Mender promotion jobs | Run end to end since 2026-11-16: candidate built and tested, signed on the isolated `firmware-release` agent after approval, published write-once to `release-evidence`, promoted to a canary deployment after a second approval. Devices do not enforce `ArtifactVerifyKey` yet |
| Jenkins MCP / Claude diagnostics | Contract and guide only — present as roadmap, do not demo live |
| Device-side signature enforcement, three-device fleet, physical board | Not done — roadmap |

## Demo catalogue: what to show a prospect

Each module below is a feature of this project that you can show on the host. Each one is tied to a problem prospects pay to solve. Don't show all of them. Pick the three to five that match the prospect (see [Pick modules by prospect](#pick-modules-by-prospect)). Open each one with the prospect's pain, show the proof on screen, then ask the discovery question. The answers are your qualification notes.

Only show what the [What is real](#what-is-real-and-what-is-not) table marks as proven or running. Present the roadmap items as design, never as a live feature. If a live claim turns out wrong, it costs you the deal. If you say "not done yet" plainly, you build trust.

### Demo modules

| # | Module | Prospect pain it answers | Show on screen | Time | Discovery question |
|---|---|---|---|---|---|
| 1 | **Fail-safe OTA with automatic rollback** | "One bad update means a truck roll or a recall." | Section 3.4: the broken release installs and boots, the health gate refuses the commit, and the device returns to the last good version without anyone touching it | 7–10 min | "What happens today when an update goes wrong in the field? What did the last one cost you?" |
| 2 | **Application-aware health gate** | "The device boots, but the product doesn't work." | `ArtifactCommit_Enter_50_sensornode-health`: service active, `/health` 200, no failed units. Explain that it is about 20 lines of shell, written for each product | 2 min | "What does 'healthy' mean for your device? Which checks would you want before an update is committed?" |
| 3 | **Bad builds stopped in CI (failure drill)** | "Broken firmware reached customers before anyone noticed." | `sensornode-diagnostic-build` with `FAILURE_DRILL`: the broken image fails `test_02_health_endpoint`, the build goes red, a redacted evidence bundle is archived, and the job has no path to Mender | 10 min (start early) | "Where do you catch a bad image today: in CI, on the bench, or in the field?" |
| 4 | **Testing without hardware: virtual devices in QEMU** | "Testing waits for boards; the bench is the bottleneck." | The release test boots the exact GPT disk that ships (UEFI → GRUB → A/B), not a debug copy. The CI image passes 14 runtime tests on every `main` build | 3 min | "How many boards does your team share? How long does a change wait for hardware testing?" |
| 5 | **Reproducible Yocto builds with pinned sources** | "It worked on my board", and nobody can rebuild last year's release | `kas/source-lock.yml` pins every layer to a commit; a release build refuses to start if the lock is incomplete; the same `stonetusker/yocto-builder` container runs on laptops and in Jenkins | 3 min | "Could you rebuild, bit for bit, the image on a device you shipped 18 months ago?" |
| 6 | **Shared build cache: hours to minutes** | "Yocto builds take hours; engineers wait." | MinIO buckets `yocto-sstate` and `yocto-downloads`; a warm-cache image build takes 106 s on the host and about 4 min in Jenkins, against hours from cold. Pull requests can read the cache but cannot write to it | 3 min | "How long is a clean build for you? How many engineer-hours a week go to waiting for it?" |
| 7 | **One CI/CD engine, secrets off the code host** | "Our pipelines are scattered; secrets sit in GitHub; nobody owns the runners." | Jenkins runs branch CI, `main`, the nightly clean rebuild (green on 17 Nov), the release and the promotion. GitHub only stores the code, with no Actions and no secrets (ADR-011) | 3 min | "What does your firmware pipeline run on today, and who maintains it?" |
| 8 | **Signed releases with separation of duties** | "A single compromised CI account could push firmware to the fleet." | `sensornode-release-candidate` → approval by `firmware-signing-approvers` → signing on the isolated `firmware-release` agent, the only holder of the key (no Docker, no sudo) → `sensornode-promote-mender` → approval by a second group → canary-only deployment | 5 min | "Who can sign and ship firmware today? Could one person or one CI token do it alone?" |
| 9 | **Write-once release evidence and SBOM** | "Auditors, customers and regulators ask what's in the firmware and who approved it." | `minio://release-evidence/<version>/<commit>/`: the signed `.mender`, SHA-256, SPDX SBOM and QEMU test evidence. The bucket is versioned and the release agent cannot delete. Every OTA run also writes `artifacts/ota/<run>/` with `SHA256SUMS` | 3 min | "Do you have to produce an SBOM or update evidence for a customer, an auditor, or the EU Cyber Resilience Act?" |
| 10 | **Traceability from requirement to evidence** | "Our documentation is written after the fact and never matches the code." | 220 controlled documents in `docs/`, linked requirement → test → evidence (`docs/13-traceability`, `docs/15-evidence`). `make docs-check` fails CI on a broken reference | 2 min | "How much effort does your last certification or customer audit take to prepare?" |
| 11 | **Every device traceable to a commit** | "We don't know exactly what's running on device X." | `/version` reports `0.3.0-102-ff2bd03` (version, build number, git commit). Mender inventory shows the artifact per device, and the device identity comes from its serial | 1 min | "If a customer reports a bug, how quickly can you tell which source built their firmware?" |
| 12 | **Self-hosted, on your premises** | "We can't send device data or firmware to a third-party cloud." | Mender, Jenkins and MinIO all run on one Ubuntu 24.04 host provisioned by Ansible (`infra/ansible`); no SaaS dependency | 2 min | "Do your devices or customers need on-premises or air-gapped update infrastructure?" |
| 13 | **Operable by your team, not only by us** | "Consultants build it, then leave, and nobody can run it." | `scripts/demo-services-up.sh` recovers the stack after a reboot; runbooks in `docs/09-operations/` (including [device access and manual OTA](../09-operations/emulated-device-access-and-ota.md)); a diagnostic bundle on every failed build | 2 min | "Who would run this day to day in your team?" |
| 14 | **AI-assisted build diagnostics, human-approved** (roadmap: design only) | "Build failures take senior engineers hours to triage." | `docs/10-ai-governance` and the Jenkins diagnostic job's approval gate: a read-only AI identity that cites evidence and proposes a fix, while a person approves any rebuild. Don't demo it live | 1 min | "How much senior time goes to triaging failed builds each week?" |

### Pick modules by prospect

| Prospect profile | Lead with | Then | Message to land |
|---|---|---|---|
| Connected-device / industrial IoT fleet | 1, 2 | 11, 12, 4 | "A bad update can't take your fleet offline, and you control the servers." |
| Medical, automotive or other regulated product | 9, 10 | 8, 5, 1 | "The evidence auditors ask for is produced by every release, not written up at the end." |
| Products sold into the EU (Cyber Resilience Act) | 9, 8 | 1, 11 | "SBOMs, signed releases and secure, recoverable updates are already part of the pipeline." |
| Hardware start-up or a small firmware team | 6, 4 | 1, 7 | "Release-quality engineering without a platform team: minutes per build, no waiting for boards." |
| Team with slow or fragile CI (Yocto build pain) | 6, 5 | 3, 7 | "Builds you can reproduce and trust, in minutes instead of hours." |
| Security-led buyer (CISO, product security) | 8, 9 | 3, 12 | "No single person or token can ship firmware, and every release is signed and accounted for." |

Keep regulatory claims precise. This project *produces evidence that supports* CRA, IEC 62443 or FDA cybersecurity submissions; it doesn't make a product compliant. Device-side signature enforcement (`ArtifactVerifyKey`) is still open. Say so if security comes up.

### Turning the demo into a lead

1. **Before the call:** find out the prospect's board or SoC, OS (Yocto, Buildroot, Debian), update method, and any regulatory driver. Choose modules from the table above and rehearse modules 1 and 3, which have the longest run times.
2. **Open with the story** (deck slide 2), then ask: "Which of these has happened to you?" Let the answer decide the order of the modules.
3. **During the demo:** after each module, ask its discovery question and note the answer. Concrete numbers, such as build time, number of devices, cost of a field failure or audit effort, are what qualify the lead.
4. **Close with a specific next step**, not "let us know":
   - a **fit assessment** (about 1 hour): we review their build, CI and update path against this blueprint and send a written gap list;
   - a **pilot**: bring this blueprint up on *their* board, with A/B OTA, a health gate written for their application, and CI with QEMU or hardware-in-the-loop tests. Physical-board validation isn't done in this repository yet, so present the pilot as the step that proves it on their hardware.
5. **Follow up within 48 hours** with the deck, the two diagrams (`docs/diagrams/`), the evidence summaries (`docs/15-evidence/ota-deployment-summary.md`, `rollback-summary.md`), and their answers to the discovery questions, restated as the problems the pilot will solve.

## Endpoints and credentials

Your laptop needs `192.168.0.109 docker.mender.io` in `/etc/hosts`.

| What | URL | Login |
|---|---|---|
| Mender UI | <https://docker.mender.io/ui/> (self-signed certificate; accept it once) | Mender admin account already in use (also in `~/mender/automation.env` on the host) |
| Jenkins | <http://docker.mender.io:8088/> | Jenkins admin account |
| MinIO cache console | <http://docker.mender.io:9001/> | MinIO root user from `infra/compose/minio` |
| GitHub (repository only) | `stonetusker/tuskerblueprint-embedded` | GitHub account |
| Device app | <http://127.0.0.1:18091/version> through the SSH tunnel below — **only while the QEMU device is running** (see [The device app port](#the-device-app-port-18091)) | — |

## 1. After a restart: bring everything up (5 minutes)

```bash
ssh subeesh@192.168.0.109
cd /home/subeesh/tuskerblueprint-embedded
scripts/demo-services-up.sh
```

All lines must be `PASS`, ending with `all services up`. Run it after every boot, even if the Mender UI already opens: services that depend on `nats` can be crash-looping in Docker's restart backoff, and the script waits for the stack to settle and restarts anything still stuck. If anything fails, follow [Host Service Restart After Reboot](host-service-restart.md).

Never run `docker compose down` on the Mender stack: its data is not in named volumes and would be lost (details in the restart guide).

## 2. Pre-demo checklist (T-30 minutes)

- [ ] `scripts/demo-services-up.sh --check` is all `PASS`.
- [ ] Mender UI opens and you are logged in; **Devices** shows `sensornode-canary-01` accepted; **Releases** lists `sensornode-0.3.0-102-ff2bd03` and `sensornode-0.3.0-103-ff2bd03-broken`.
- [ ] Jenkins opens, jobs `sensornode-ci`, `sensornode-nightly` and `sensornode-diagnostic-build` are visible, node `ubuntu24` is online (Manage Jenkins → Nodes).
- [ ] No QEMU device is already running: `pgrep -fa qemu-system` prints nothing.
- [ ] Mender UI → **Deployments** shows nothing *In progress* or *Pending*. Abort any leftover deployment (for example a Jenkins promotion still *Queued to start*); otherwise the canary picks it up as soon as it boots, before the scripted run.
- [ ] Nothing else is building on the host (`pgrep -fa bitbake` prints nothing); a build slows QEMU noticeably.
- [ ] Laptop: four windows ready — Mender UI (Deployments tab), Jenkins, and two terminals (layout below).

Terminal layout on the laptop:

| Terminal | Command | Purpose |
|---|---|---|
| A — driver | `ssh subeesh@192.168.0.109` | Runs the OTA scenario |
| B — device console | `ssh subeesh@192.168.0.109` then `tail -F ~/tuskerblueprint-embedded/qemu-fleet/state/sensornode-canary-01/serial.log` | Shows boot, GRUB slot switch, and the health gate. `-F` keeps following when the script starts a new device and the log is recreated |
| C — device version (optional) | `ssh -N -L 18091:127.0.0.1:18091 subeesh@192.168.0.109` (leave it open), then in a third local terminal `while sleep 2; do curl -s -m 2 127.0.0.1:18091/version; echo; done`, or open <http://127.0.0.1:18091/version> in a browser and refresh | Shows the running image version change (`image_version`). macOS has no `watch`, hence the loop |

### The device app port (18091)

`18091` is not a service on the host. It is QEMU's port forward to the SensorNode app (port 8080) inside the canary device, and it exists **only while the QEMU device runs**:

- `mender/demo-scenarios/run-ota-e2e.sh` starts the device; the app answers about 20–30 s later, once the factory image has booted.
- By default the script stops the device when it finishes (or fails). With `KEEP_DEVICE=1`, as in section 3.4, the device stays up on the last good version so you can keep showing it.
- During each OTA reboot the app is briefly unavailable (empty replies or errors for 20–60 s). That is expected.

To show the device without running the OTA scenario (for example before the demo, or after a run without `KEEP_DEVICE=1`), boot it from its saved disk, which keeps the last installed version. On the host:

```bash
cd ~/tuskerblueprint-embedded
DISK_IMAGE=$HOME/tbtest/ota-inputs/101/sensornode-image-release-qemuarm64.uefiimg RESET_DISK=0 \
DEVICE_NAME=sensornode-canary-01 APP_PORT=18091 SSH_PORT=12291 \
  setsid qemu-fleet/launch/qemu-device.sh >/tmp/canary.log 2>&1 </dev/null &
```

`DISK_IMAGE` is only copied when no saved disk exists yet. Stop it with `pkill -f 'qemu-system-aarch64 -name sensornode-canary-01'` before running section 3.4, which needs the port.

So "connection refused" in the browser, or `channel 2: open failed: connect failed: Connection refused` in terminal C, means no device is running; the tunnel itself is fine. Start the tunnel once and leave it open: it reconnects to each new device automatically. Only one tunnel can hold the port: if `ssh` prints `bind [::1]:18091: Address already in use`, a tunnel is already open (`lsof -nP -iTCP:18091 -sTCP:LISTEN` shows it).

## 3. Demo flow (about 25 minutes)

### 3.1 Story and architecture (3 min)

Open `README.md` and `docs/04-architecture/`. The message: one specification-driven repository produces the image (Yocto/kas, `meta-sensornode`), builds it reproducibly with pinned sources (`kas/source-lock.yml`) and a shared cache, tests it in QEMU before it can be released, and ships it through Mender with A/B partitions and a health gate so a bad release cannot brick a device.

### 3.2 Build and CI (5 min)

1. **Jenkins CI** — show `sensornode-ci` with one job per branch, discovered by polling GitHub (GitHub hosts the code, Jenkins runs everything), the green `main` build, and a recent `sensornode-nightly` run (02:00 UTC).
2. **MinIO cache** — open the console and show the `yocto-sstate` and `yocto-downloads` buckets (also `release-artifacts`, `release-evidence`); point out that a warm-cache image build takes minutes instead of hours (`artifacts/build-duration-seconds`: 106 s on the host, 240 s in Jenkins build 14).
3. **Jenkins diagnostics** — open `sensornode-diagnostic-build` and its last builds. Stages: Checkout → Validate → Build and QEMU Test → Diagnostic Evidence → Human Approval for Rebuild → Approved Rebuild (the last two run only after a failure with `DIAGNOSTIC_REBUILD`). Open the last green build → **Tests**: the QEMU runtime tests (oeqa: ping, ssh, systemd, and the four `SensorNodeRuntimeTest` checks) appear as individual test cases, published from `artifacts/test-reports/oeqa-junit.xml`.

Optional, live (only if rehearsed): **Build with Parameters** → `FAILURE_DRILL` = true → Build. Jenkins builds `sensornode-image-broken`, the QEMU health test fails (**Tests** shows `test_02_health_endpoint` failed: `/health` returns 503), the build goes red, the diagnostic bundle is archived, and nothing is promoted to Mender. With a warm cache it takes about 10 minutes (build about 4 minutes, QEMU test about 2–4 minutes). Start it at the beginning of section 3.2 so it finishes while you talk. This is the "pipeline prevention" control (`mender/demo-scenarios/pipeline-prevention.md`).

### 3.3 Fleet view in Mender (2 min)

Mender UI → **Devices** (`sensornode-canary-01`, its inventory), **Software** (the healthy `-102` and the deliberately broken `-103-broken` releases), **Deployments → Finished** (history of earlier proven runs). How Mender OTA works, slide-free, is in [Mender OTA Explained](mender-ota-explained.md) Part 1.

### 3.4 Live OTA update and automatic rollback (about 7 min of runtime; allow 10)

Two ways to run this section; both were rehearsed on the host:

- **Mender web UI (preferred when the audience is non-technical):** boot the device from the terminal, then accept it, deploy the healthy release and the broken one entirely in the Mender UI. Follow [Mender OTA Explained](mender-ota-explained.md) Part 2 instead of the script below. Rehearsed 2026-11-16: healthy update about 80 s, rollback about 4.5 min.
- **Scripted (below):** one command does enrolment and both deployments through the API while you narrate in the UI.


In terminal A:

```bash
cd ~/tuskerblueprint-embedded
. ~/mender/automation.env
MENDER_USER=$MENDER_AUTOMATION_USER MENDER_PASSWORD=$MENDER_AUTOMATION_PASSWORD \
MENDER_CA_CERT=$HOME/mender/integration-3.8.5/cert/cert.crt \
FACTORY_DISK=$HOME/tbtest/ota-inputs/101/sensornode-image-release-qemuarm64.uefiimg \
GOOD_ARTIFACT=$HOME/tbtest/ota-inputs/102/sensornode-image-release-qemuarm64.mender \
BROKEN_ARTIFACT=$HOME/tbtest/ota-inputs/103/sensornode-image-release-broken-qemuarm64.mender \
KEEP_DEVICE=1 \
  mender/demo-scenarios/run-ota-e2e.sh
```

`KEEP_DEVICE=1` leaves the canary running on `0.3.0-102` after the script ends, so terminal C and the browser keep working for questions. Stop it after the demo (section 5). Without it, the device and port 18091 go away when the script exits.

Narrate while it runs. The script prints each milestone with a timestamp:

| Phase | Terminal A prints | Show the audience | Typical time |
|---|---|---|---|
| Factory boot | `canary sensornode-canary-01 is healthy on factory image 0.3.0-101-ff2bd03` | Terminal B: UEFI → GRUB → systemd boot; terminal C: `0.3.0-101` | ~25 s |
| Enrolment | `accepted auth set …` | Mender **Devices**: a factory-fresh disk has a new key; the script accepts it (in production this is done by preauthorisation) | ~10–40 s |
| Healthy update | `canary deployment … created` then `canary committed … reports 0.3.0-102-ff2bd03` | Mender **Deployments → In progress**: downloading → installing → rebooting → success. Terminal B: reboot into the other root partition, health script passes. Terminal C: `0.3.0-102` | ~2 min |
| Broken update | `rollback deployment … created` | The `-broken` release installs and reboots like any other | — |
| Health gate refuses commit | `unhealthy … was rejected and the device rolled back to 0.3.0-102-ff2bd03` | Terminal B: `ArtifactCommit_Enter_50_sensornode-health` fails (`/health` returns 503), Mender reboots into the previous slot. Mender shows the deployment as **failure**. Terminal C: back on `0.3.0-102` | ~4–5 min |
| Done | `KEEP_DEVICE=1: sensornode-canary-01 stays up …` then `OTA end-to-end passed; evidence in …/artifacts/ota/<run>` | Terminal C still shows `0.3.0-102` | — |

Key talking point: the broken image booted fine — only the application-level health gate caught it, and the device healed itself without anyone touching it.

### 3.5 Evidence (2 min)

```bash
ls ~/tuskerblueprint-embedded/artifacts/ota/$(ls -t ~/tuskerblueprint-embedded/artifacts/ota | head -1)
cat ~/tuskerblueprint-embedded/artifacts/ota/$(ls -t ~/tuskerblueprint-embedded/artifacts/ota | head -1)/summary.json
```

Every run leaves API responses, device deployment logs, the serial console, and `SHA256SUMS`. Tie this back to `docs/15-evidence/` and `docs/13-traceability/`: requirements → tests → evidence.

### 3.6 Roadmap (1 min)

Devices that enforce signatures (`ArtifactVerifyKey`), a production signing key in an HSM, a three-device canary → pilot → fleet rollout, Jenkins MCP with a read-only Claude identity and human approval, and physical-board validation.

## 4. If something goes wrong mid-demo

| Symptom | Action |
|---|---|
| `device … was not enrolled` | Mender UI → Devices → Pending → accept `sensornode-canary-01`, then re-run the command. |
| `device already running: sensornode-canary-01` or `something already answers on 127.0.0.1:18091` | A device from an earlier run (for example `KEEP_DEVICE=1`) is still up: `pkill -f 'qemu-system-aarch64 -name sensornode-canary-01'`, then re-run. |
| Browser shows connection refused on `127.0.0.1:18091` | No device is running (before the factory boot, or after the script ended without `KEEP_DEVICE=1`). See [The device app port](#the-device-app-port-18091). |
| `bind [::1]:18091: Address already in use` when opening the tunnel | A tunnel is already open; use it, or close it (`lsof -nP -iTCP:18091 -sTCP:LISTEN`, then `kill <pid>`). |
| Deployment stuck in downloading | `docker logs --tail 50 integration-385-mender-deployments-1`; confirm the override still sets `DEPLOYMENTS_AWS_EXTERNAL_URI`. |
| Mender UI login fails or shows no devices | Stop. Do not recreate the stack. Run `scripts/demo-services-up.sh --check` and see the restart guide. |
| Live run fails and time is short | Show the recorded run instead: `artifacts/ota/20261023T130809Z/` and `docs/15-evidence/ota-deployment-summary.md`, `rollback-summary.md`. |

## 5. After the demo

If you used `KEEP_DEVICE=1`, stop the device: `pkill -f 'qemu-system-aarch64 -name sensornode-canary-01'`; otherwise the script already stopped it. Close the tunnel in terminal C with Ctrl-C. Each run adds two finished deployments to Mender's history and one evidence directory under `artifacts/ota/`; both are harmless. To shut the host down:

```bash
sudo poweroff
```

Do not stop the Mender containers first. Docker stops them cleanly during shutdown and, because they are `unless-stopped`, starts them again at boot; a container stopped by hand (`docker compose stop`) stays down after the reboot. Never use `down`. After the next power-on, start again at section 1.

## Rehearsal record

| Date | Operator | Result | Evidence |
|---|---|---|---|
| 2026-10-23 | Subeesh | OTA install + rollback passed (3 runs) | `artifacts/ota/20261023T130809Z/` |
| 2026-11-07 | Claude Code, after host reboot | Services restored with `scripts/demo-services-up.sh`; OTA install + rollback passed in 7 min 6 s (healthy update 106 s, rollback 4 min 46 s) | `artifacts/ota/20261107T013714Z/` |
| 2026-11-12 | Claude Code, full guide walk-through | Section 1 all `PASS`; checklist verified; OTA install + rollback passed in 6 min 50 s with `KEEP_DEVICE=1` (factory boot 23 s, enrolment 40 s, healthy update 106 s, rollback 4 min 1 s); laptop tunnel showed `0.3.0-101` → `0.3.0-102` and the device stayed up after the script ended | `artifacts/ota/20261112T154412Z/` |
