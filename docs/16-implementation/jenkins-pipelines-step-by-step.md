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

Replacing a pipeline job's definition drops the parameters that Declarative Pipeline registers on its first run. After `--update`, run the job once (it will fail fast or can be aborted) so **Build with Parameters** appears again.

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
- `SIGN_AND_PUBLISH`: leave ticked to continue to signing

The build stages run on `yocto-vps8`: input validation, `git merge-base --is-ancestor`, source-lock validation, the `kas/release.yml` build, the exact release disk booted in QEMU, the SBOM, and the unsigned candidate. The job then pauses at **Approve signing**. A member of `firmware-signing-approvers` approves it, and the signing stage runs on the isolated `firmware-release` agent. That stage signs the exact candidate and publishes it write-once to `minio://release-evidence/<version>/<commit>/`.

## 5. Promotion to Mender (`sensornode-promote-mender`)

**Build with Parameters** with `CANDIDATE_URI`, `EXPECTED_SHA256`, `ARTIFACT_NAME` and `CANARY_DEVICE_IDS`. A member of `firmware-production-approvers` approves **Approve canary deployment**. The `firmware-release` agent then downloads the exact object, verifies the SHA-256, uploads it to Mender and creates a canary-only deployment. Wider rollout is a separate, later decision.

## 6. Credentials and settings

| Item | Where | Used by |
|---|---|---|
| Git clone credential (SSH) | Jenkins credential, id in `JENKINS_GIT_CREDENTIALS_ID` | all jobs |
| `MINIO_CACHE_CREDENTIALS_ID` (optional global variable) | names a username/password credential for MinIO cache writes; when unset, the build agent's pre-configured `mc` alias `tusker` is used | ci (main), nightly, release-candidate |
| `mender-access-token` | Jenkins secret-text credential (id override: global variable `MENDER_CREDENTIALS_ID`) | promote-mender |
| `MENDER_SERVER_URL` (optional global variable) | defaults to `https://docker.mender.io` | promote-mender |
| Signing key | `/var/lib/tusker-release/mender-signing.pem` on the `firmware-release` agent only (mode 0600) | release-candidate |
| `RELEASE_MINIO_ALIAS` (optional global variable) | `mc` alias on the release agent with release-evidence access; default `tusker-release` | release-candidate, promote-mender |

## 7. Approval groups

`firmware-signing-approvers` and `firmware-production-approvers` must exist as groups in Jenkins' authorisation strategy (for example with the role-strategy plugin) before the release jobs are used outside the lab. Jenkins administrators can always approve an input step. Do not give the AI/MCP identity any permission on the release jobs.

## 8. Release agent

Provision the `firmware-release` agent with `infra/ansible/roles/jenkins_release_agent` (user `release-agent`, no Docker, signing key, verified `mender-artifact`, `mender-cli` and `mc`). Add it in **Manage Jenkins → Nodes** with label `firmware-release` and one executor. Until it exists, the release and promotion jobs wait in the queue when they reach that agent.

## 9. Policy checks

`make pipeline-check` (`tools/validate_jenkins_pipelines.py`) runs in every CI build and fails if:

- a Jenkinsfile has no job definition, or a job definition points at a missing file
- a pipeline other than release-candidate or promote-mender references signing, release publication or Mender deployment
- an approval gate or the `firmware-release` agent is missing from the release pipelines
- the trusted cache can be published from a branch other than `main`
- a GitHub Actions workflow reappears
