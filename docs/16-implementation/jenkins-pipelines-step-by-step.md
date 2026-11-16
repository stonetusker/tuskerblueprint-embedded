---
id: IMPL-JENKINS-002
title: Jenkins Pipelines Step by Step
status: Approved
version: 0.4.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-11-16
traces_to:
  - CI-REQ-001
  - CI-REQ-002
  - CI-REQ-004
verified_by:
  []
---

# Jenkins Pipelines Step by Step

Jenkins is the only CI/CD orchestrator. GitHub hosts the Git repository and runs nothing ([ADR-011](../12-decisions/ADR-011-jenkins-single-orchestrator.md)). Controller and build-agent setup is in [Jenkins Step by Step](jenkins-step-by-step.md); this page covers the pipeline jobs.

## The jobs

| Job | Type | Jenkinsfile | Trigger | Agent |
|---|---|---|---|---|
| `sensornode-ci` | Multibranch | `ci/jenkins/pipelines/ci.Jenkinsfile` | Branch indexing polls Git every 5 minutes | `yocto-vps8` |
| `sensornode-nightly` | Pipeline | `ci/jenkins/pipelines/nightly.Jenkinsfile` | 02:00 UTC, or Build with Parameters | `yocto-vps8` |
| `sensornode-release-candidate` | Pipeline | `ci/jenkins/pipelines/release-candidate.Jenkinsfile` | Manual | `yocto-vps8`, then `firmware-release` |
| `sensornode-promote-mender` | Pipeline | `ci/jenkins/pipelines/promote-mender.Jenkinsfile` | Manual | `firmware-release` |
| `sensornode-diagnostic-build` | Pipeline | `ci/jenkins/Jenkinsfile` | Manual | `yocto-vps8` |

The job definitions live in `ci/jenkins/job-config/*.xml.template`. All Jenkinsfiles call the repository scripts (`scripts/build-image.sh`, `scripts/run-qemu-tests.sh`, `scripts/cache-sync.sh`, and so on); no build logic lives in a Jenkinsfile.

## 1. Create or refresh the jobs

```bash
export JENKINS_URL=http://127.0.0.1:8088
export JENKINS_USER='<admin-or-job-config-user>'
export JENKINS_API_TOKEN='<token>'
export JENKINS_REPOSITORY_URL='git@github.com:stonetusker/tuskerblueprint-embedded.git'
export JENKINS_GIT_CREDENTIALS_ID='<ssh-credential-id>'   # Jenkins credential that can clone the repo
scripts/configure-jenkins-job.sh                 # creates missing jobs, leaves existing ones alone
scripts/configure-jenkins-job.sh --update sensornode-ci   # replace one job's definition
```

The job definitions declare the same parameters as their Jenkinsfiles, so **Build with Parameters** is available from the first run; `make pipeline-check` fails if the two drift apart. A job created before 2026-11-17 without them only learns its parameters after one run; the first manual run then fails with `VERSION: unbound variable` (or similar) and the next one shows the form.

## 2. Branch and pull-request builds (`sensornode-ci`)

Jenkins cannot receive GitHub webhooks on the LAN host, so the multibranch job polls the repository. A new branch or a new commit is built within about five minutes. No GitHub API token is used, and no status is reported back to GitHub.

| Branch | What runs |
|---|---|
| any branch | `make app-test app-build`, then `make docs-check python-check yaml-check shell-check pipeline-check policy-check` |
| `main` | the above, plus the Yocto `sensornode-image-ci` build, QEMU runtime tests, and the trusted cache publish to MinIO |
| other branches with `YOCTO_BUILD` ticked | the Yocto build and QEMU tests with an isolated cache in `~/yocto-branch-cache/<branch>`; never published |

Before merging a pull request, the reviewer opens **sensornode-ci → <branch>** and checks the last build is green. To request a full image build on a branch: open the branch job → **Build with Parameters** → tick `YOCTO_BUILD`.

## 3. Nightly regression build (`sensornode-nightly`)

Runs on `main` at 02:00 UTC: removes `build/tmp`, rebuilds the CI image from the cache, runs the QEMU tests and refreshes the MinIO cache. **Build with Parameters** runs it on demand; untick `PUSH_CACHE` for a build that must not write the cache.

## 4. Release candidate (`sensornode-release-candidate`)

**Build with Parameters**:

- `VERSION`: semantic version, for example `0.4.0`
- `SOURCE_COMMIT`: the full 40-character commit, which must already be on `main`
- `SIGN_AND_PUBLISH`: ticked by default; untick it for a tested, unsigned candidate only (the job then stops after archiving the candidate and its SBOM)

The build stages run on `yocto-vps8`: input validation, `git merge-base --is-ancestor`, source-lock validation, the `kas/release.yml` build, the exact release disk booted in QEMU, the SBOM, and the unsigned candidate. The job then pauses at **Approve signing**. A member of `firmware-signing-approvers` approves it, and the signing stage runs on the isolated `firmware-release` agent. That stage signs the exact candidate, validates the signature with the public key, and publishes it write-once to `minio://release-evidence/<version>/<commit>/`. It ends by printing, and archiving as `promotion-parameters.env`, the `CANDIDATE_URI`, `EXPECTED_SHA256` and `ARTIFACT_NAME` for the promotion job.

The **Approve signing** prompt (*Sign candidate* or *Abort*) waits at most 4 hours and holds no executor; with no answer the build ends ABORTED and the candidate stays archived. The signing stage fails after 30 minutes if no `firmware-release` agent is online, rather than queueing forever.

## 5. Promotion to Mender (`sensornode-promote-mender`)

**Build with Parameters** with `CANDIDATE_URI`, `EXPECTED_SHA256` and `ARTIFACT_NAME` copied from the release build's `promotion-parameters.env`, and `CANARY_DEVICE_IDS` (the Mender device ID from **Devices** in the Mender UI). A member of `firmware-production-approvers` approves **Approve canary deployment**. The `firmware-release` agent then downloads the exact object, verifies the SHA-256, uploads it to Mender (`scripts/upload-mender-artifact.sh`) and creates a canary-only deployment (`scripts/create-mender-deployment.sh`); both use the Mender REST API with curl. Wider rollout is a separate, later decision.

## 6. Credentials and settings

| Item | Where | Used by |
|---|---|---|
| Git clone credential (SSH) | Jenkins credential, id in `JENKINS_GIT_CREDENTIALS_ID` | all jobs |
| `MINIO_CACHE_CREDENTIALS_ID` (optional global variable) | names a username/password credential for MinIO cache writes; when unset, the build agent's pre-configured `mc` alias `tusker` is used | ci (main), nightly, release-candidate |
| `mender-access-token` | Jenkins secret-text credential holding a Mender personal access token (lab: token `jenkins-firmware-release`, valid one year from 2026-11-16; id override: global variable `MENDER_CREDENTIALS_ID`) | promote-mender |
| `MENDER_CA_CERT` | node variable on `release-agent`: `/var/lib/tusker-release/mender-server.crt`, the lab server's self-signed certificate | promote-mender |
| `MENDER_SERVER_URL` (optional global variable) | defaults to `https://docker.mender.io` | promote-mender |
| Signing key | `/var/lib/tusker-release/mender-signing.pem` on the `firmware-release` agent only (mode 0600) | release-candidate |
| `RELEASE_MINIO_ALIAS` | node variable on `release-agent`: `tusker-release`, the `mc` alias of MinIO user `release-agent` (policy `release-agent-publish`: read and write `release-evidence`, no delete, no cache access) | release-candidate, promote-mender |

## 7. Approval groups

The input steps name the groups `firmware-signing-approvers` and `firmware-production-approvers`. Jenkins administrators can always approve an input step.

In the lab, Jenkins uses its own user database with *Logged-in users can do anything*, so every Jenkins user is an administrator and can approve. Jenkins' own user database has no groups. To restrict approval, connect Jenkins to LDAP or an OIDC provider that supplies these two groups, and switch to matrix or role-based authorisation so that ordinary users are not administrators. Do not give the AI/MCP identity any permission on the release jobs.

## 8. Release agent

The lab agent runs on the build host as Jenkins node `release-agent` (label `firmware-release`, one executor, used only by jobs that ask for that label):

| Item | Value |
|---|---|
| Unix user | `release-agent`: no Docker, no sudo |
| Service | `jenkins-release-agent.service`, an inbound WebSocket agent to `http://127.0.0.1:8088/` |
| Work directory | `/home/release-agent/jenkins` |
| Release files | `/var/lib/tusker-release/` (0700): `mender-signing.pem` (0600), `mender-verify.pem`, `mender-server.crt` |
| Tools | `mender-artifact` (Ubuntu package), `mc`, `curl`, `python3`, `git` |

`infra/ansible/roles/jenkins_release_agent` sets up the same agent on a new host. Create the node in **Manage Jenkins → Nodes** first and pass its secret as `vault_release_agent_secret`. If the agent is offline, a signing run fails after waiting 30 minutes. A promotion run waits in the queue until the pipeline's 2-hour timeout.

Check the agent with `systemctl status jenkins-release-agent` on the host, or under **Manage Jenkins → Nodes → release-agent**.

## 9. Policy checks

`make pipeline-check` (`tools/validate_jenkins_pipelines.py`) runs in every CI build and fails if:

- a Jenkinsfile has no job definition, or a job definition points at a missing file
- a pipeline other than release-candidate or promote-mender references signing, release publication or Mender deployment
- an approval gate or the `firmware-release` agent is missing from the release pipelines
- the trusted cache can be published from a branch other than `main`
- a GitHub Actions workflow reappears
