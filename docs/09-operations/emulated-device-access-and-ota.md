---
id: RUN-DEVICE-001
title: Emulated Device Access, Version Check and Manual OTA
status: Draft
version: 0.1.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-11-17
updated: 2026-11-17
traces_to:
  - OPS-REQ-DOC
verified_by:
  []
---

# Emulated Device Access, Version Check and Manual OTA

How to start a QEMU SensorNode device on the demo host, get a shell on it, check
which image it runs, and push an OTA update by hand. It ends with what to do when
a Mender deployment stays **Queued to start**.

Related: [QEMU Fleet Runbook](qemu-fleet-runbook.md), [Mender Runbook](mender-runbook.md),
[Demo Guide](../16-implementation/demo-guide.md), [Mender OTA Step by Step](../16-implementation/mender-ota-step-by-step.md).

## 1. Facts to keep in mind

| Fact | Consequence |
|---|---|
| A QEMU device exists **only while its `qemu-system-aarch64` process runs**. | No running process means no Mender polling, no `/version`, no shell. |
| `scripts/run-release-qemu-tests.sh` (Jenkins `sensornode-release-candidate`) boots `sensornode-release-test` and **kills it when the tests end**. | Jenkins leaves no device running. Do not target that device in a deployment. |
| `mender/demo-scenarios/run-ota-e2e.sh` stops `sensornode-canary-01` on exit unless `KEEP_DEVICE=1`. | After a normal demo run the canary is offline. |
| The release image (`sensornode-image-release`) has **no SSH server and a locked root account**. | You cannot SSH into a release image. Use the Mender remote terminal, the HTTP API, or the serial log (section 3). |
| The dev and CI images (`sensornode-image-dev`, `sensornode-image-ci`) have `debug-tweaks` and OpenSSH. | Root login over SSH with an empty password works on those images only. |
| The device ID is the SMBIOS serial, which is `DEVICE_NAME`. | Mender shows the device under identity `device_id=<DEVICE_NAME>`. |
| The client reaches the server as `docker.mender.io` → `10.0.2.2` (the QEMU gateway, that is the host). | The Mender stack must be up on the same host as the QEMU device. |

Standard canary on the demo host:

| Item | Value |
|---|---|
| Host | `ssh subeesh@192.168.0.109`, repository in `~/tuskerblueprint-embedded` |
| Device name | `sensornode-canary-01` |
| App port (host → device 8080) | `127.0.0.1:18091` |
| SSH port (host → device 22) | `127.0.0.1:12291` |
| State directory | `qemu-fleet/state/sensornode-canary-01/` (`disk.img`, `serial.log`, `qemu.pid`) |

## 2. Start (and stop) the canary device

On the host:

```bash
cd ~/tuskerblueprint-embedded
scripts/demo-services-up.sh --check          # Mender stack must be all PASS

pgrep -fa 'qemu-system-aarch64 -name sensornode-canary-01'   # already running?

DISK_IMAGE=$HOME/tbtest/ota-inputs/101/sensornode-image-release-qemuarm64.uefiimg \
RESET_DISK=0 \
DEVICE_NAME=sensornode-canary-01 APP_PORT=18091 SSH_PORT=12291 \
  setsid qemu-fleet/launch/qemu-device.sh >/tmp/canary.log 2>&1 </dev/null &

DEVICE_HOST=127.0.0.1 APP_PORT=18091 TIMEOUT_SECONDS=600 qemu-fleet/launch/wait-for-device.sh && echo ready
```

- `DISK_IMAGE` is any Mender `.uefiimg`. To use a Jenkins build, take
  `sensornode-image-release-qemuarm64.uefiimg` from the build's
  `build/tmp/deploy/images/qemuarm64/` on the `yocto-vps8` agent.
- `RESET_DISK=0` keeps the saved disk, so the device keeps the last installed version.
  `RESET_DISK=1` re-copies the factory image. That creates a **new device key**, so the
  device shows up again as *pending* in Mender and must be accepted (section 5).
- `setsid … &` detaches QEMU so it survives logging out of SSH. For a device that must
  stay up permanently, use the systemd template `qemu-fleet/systemd/sensornode-qemu@.service`
  with an env file in `/etc/sensornode-fleet/<name>.env`.

Stop it:

```bash
pkill -f 'qemu-system-aarch64 -name sensornode-canary-01'
```

## 3. Access the device

### 3.1 Serial console log (all images, read-only)

The launcher writes the serial console to a file; it is not interactive.

```bash
tail -F ~/tuskerblueprint-embedded/qemu-fleet/state/sensornode-canary-01/serial.log
```

It shows the GRUB slot selection, kernel boot, systemd units and the Mender health
gate output during an update.

### 3.2 Mender remote terminal (release image)

`mender-full` installs the Mender add-ons. If `mender-connect` is running on the device
and the server's `deviceconnect` service is up:

1. Mender UI → **Devices** → `sensornode-canary-01` → **Troubleshoot** tab.
2. **Remote terminal** → **Connect**.

This gives a root shell without SSH and works with the locked root account. If the
Troubleshoot tab is missing or the terminal does not connect, check the serial log for
`mender-connect` errors. If the image doesn't contain `mender-connect`, you have to use
3.3 or a dev image (3.4).

### 3.3 Without a shell: HTTP API and Mender inventory (release image)

You can get the version without a shell:

```bash
curl -s http://127.0.0.1:18091/version; echo
curl -s http://127.0.0.1:18091/health;  echo
```

From the laptop, open a tunnel first: `ssh -N -L 18091:127.0.0.1:18091 subeesh@192.168.0.109`.

The Mender UI shows the installed artifact in **Devices** → device → **Software**
(`rootfs-image.version` / `artifact_name`).

### 3.4 SSH (dev and CI images only)

Boot a `sensornode-image-dev` or `sensornode-image-ci` `.uefiimg` as in section 2, then:

```bash
ssh -p 12291 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@127.0.0.1
```

The root password is empty (`debug-tweaks`). The host key changes on every factory reset,
which is why host key checking is disabled for this local port. On a release image
the same command fails with `Connection refused`; that is expected.

## 4. Check the running version

| Where | Command | Shows |
|---|---|---|
| Device HTTP API | `curl -s 127.0.0.1:18091/version` | `image_version`, `application_version`, `device_id` |
| Device shell | `cat /etc/sensornode-release` | `IMAGE_VERSION`, `GIT_COMMIT`, `BUILD_NUMBER` |
| Device shell | `cat /etc/sensornode/image-version` | Image version only |
| Device shell | `mender-update show-artifact` | Installed Mender artifact name (`sensornode-<version>`) |
| Device shell | `findmnt -no SOURCE /` (`/dev/vda2` = slot A, `/dev/vda3` = slot B) | Active A/B root filesystem |
| Mender UI / API | Devices → Software, or `GET /api/management/v1/inventory/devices/<id>` | `artifact_name` reported by the client |

`image_version` has the form `<SENSORNODE_VERSION>-<BUILD_NUMBER>-<7-char commit>`, for
example `0.3.0-102-ff2bd03`. The Mender artifact name is the same value with a
`sensornode-` prefix.

On Mender client 3.x images the command is `mender show-artifact` instead of `mender-update`.

## 5. Make sure Mender can see the device

Do this before creating any deployment.

1. The device is running (section 2) and `/health` answers.
2. Mender UI → **Devices** → **Pending**: accept `sensornode-canary-01` if it is there.
   After `RESET_DISK=1` there is a new pending auth set even if the device was accepted
   before; until you accept it, the device cannot poll for deployments.
3. **Devices** → **Accepted** → `sensornode-canary-01`: **Last check-in** must be recent
   (seconds, because meta-mender-demo sets short poll intervals).
4. Note the **Mender device ID** (UUID) on the device page. Deployments target that ID,
   not the name.
5. **Software** → `device_type` must be one of the artifact's compatible device types
   (shown under **Releases** → artifact). Check with
   `mender-artifact read <file>.mender | grep -A2 -i compatible`.

## 6. Trigger an OTA update manually

Pick one option. Options A–C go through the server; option D bypasses it.

### A. Mender UI

1. **Releases** → **Upload** the `.mender` file (skip if it is already listed).
2. **Deployments** → **Create a deployment** → select the release → select the
   device (`sensornode-canary-01`), or a group or filter that includes it → **Create**.
3. Keep the start time at *now* and no phases. A scheduled start or a phased rollout also
   shows as "queued".

### B. Jenkins `sensornode-promote-mender`

The approved path for a signed candidate. **Build with Parameters**, using the
values from the release-candidate build's `promotion-parameters.env`, plus
`CANARY_DEVICE_IDS=<Mender device ID from section 5>`. After approval it
uploads the artifact and creates a canary-only deployment.

### C. Script / API from the host

```bash
cd ~/tuskerblueprint-embedded
export MENDER_SERVER_URL=https://docker.mender.io
export MENDER_CA_CERT=~/mender/integration-3.8.5/cert/cert.crt
export MENDER_ACCESS_TOKEN=<personal access token>     # Mender UI → Settings → Personal access tokens

ARTIFACT=/path/to/candidate.mender scripts/upload-mender-artifact.sh
ARTIFACT_NAME=sensornode-0.3.0-102-ff2bd03 DEVICE_IDS=<device-uuid> \
  scripts/create-mender-deployment.sh
```

For the full install → health gate → commit → rollback proof, run
`mender/demo-scenarios/run-ota-e2e.sh` (see [Demo Guide §3.4](../16-implementation/demo-guide.md)).

### D. Standalone install on the device (needs a shell, no server)

Use this for debugging only. It does not appear in Mender's deployment history.

```bash
# on the host: serve the artifact to the device (10.0.2.2 is the host from inside QEMU)
cd /path/to/dir-with-artifact && python3 -m http.server 8000

# on the device shell (3.2 or 3.4)
mender-update install http://10.0.2.2:8000/candidate.mender
reboot
# after the reboot, check the new version, then:
mender-update commit        # or: mender-update rollback
```

If the device is not committed, rebooting it again returns it to the previous slot.

### Make the device check now

With the demo poll intervals the device checks within seconds. To force a check from a
device shell: `mender-update check-update` (client 3.x: `mender check-update`). A
reboot of the QEMU device (section 2, stop and start with `RESET_DISK=0`) does the same.

### Watch the deployment

- Mender UI → **Deployments** → **In progress** → the deployment → device row
  (`downloading` → `installing` → `rebooting` → `success` / `failure`). Open
  **View log** for the client log.
- `tail -F qemu-fleet/state/sensornode-canary-01/serial.log` on the host.
- `curl -s 127.0.0.1:18091/version` changes after the commit. During the reboot the
  app is unavailable for 20–60 s; that is expected.

## 7. Deployment stuck at "Queued to start"

"Queued to start" (API status `pending`) means **no targeted device has asked the server
for an update yet**. The server never pushes updates to devices; the client polls. The
fault is almost always on the device side.

Check these in order:

| # | Check | How | Fix |
|---|---|---|---|
| 1 | Is the targeted device actually running? | `pgrep -fa qemu-system-aarch64` on the host. | Start it (section 2). Jenkins release-candidate and `run-ota-e2e.sh` without `KEEP_DEVICE=1` **leave no device running**. This is the most likely cause. |
| 2 | Is it the right device? | Deployment → device list vs. Devices → Accepted. | Do not target `sensornode-release-test` (Jenkins test VM, killed after tests) or a stale UUID. Re-create the deployment for `sensornode-canary-01`. |
| 3 | Is its current auth set accepted? | Devices → Pending; device page → Authentication. | Accept the pending set. A factory reset (`RESET_DISK=1`) creates a new key, and the device stays unauthorised until you accept it. |
| 4 | Is it checking in? | Device page → **Last check-in**; `grep -iE 'mender|auth' serial.log`. | If it is not recent: `scripts/demo-services-up.sh --check`; confirm the Mender stack and `docker.mender.io` → `10.0.2.2` resolve from the device. Errors such as `x509`, `connection refused` or `no such host` in the serial log point to TLS or network problems. |
| 5 | Scheduled start or phases? | Deployment details. | Create the deployment again with start time *now* and no phases. |
| 6 | Another deployment already active for that device? | Deployments → In progress. | A device handles one deployment at a time. Abort the older deployment or let it finish. |

Once the device checks in, the deployment leaves "Queued". If the device is not
compatible or already runs that artifact, it then finishes quickly with `noartifact`
or `already-installed` instead of installing. That means a wrong device type or a
duplicate artifact name; fix it by using a unique `BUILD_NUMBER` per build.

To check the state over the API:

```bash
curl -s --cacert "$MENDER_CA_CERT" -H "Authorization: Bearer $MENDER_ACCESS_TOKEN" \
  "$MENDER_SERVER_URL/api/management/v1/deployments/deployments/<deployment-id>/devices" | python3 -m json.tool
```

## 8. Clean up

- Stop the device: `pkill -f 'qemu-system-aarch64 -name sensornode-canary-01'`.
- Abort deployments you no longer need (Deployments → In progress → **Abort**) so they
  do not start the next time the device comes online.
- Record operator, time, device, artifact, result and follow-up, as in the
  [Mender Runbook](mender-runbook.md) completion record.
