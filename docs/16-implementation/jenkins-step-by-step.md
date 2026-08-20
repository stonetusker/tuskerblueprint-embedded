---
id: IMPL-JENKINS-001
title: Jenkins Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - PRD-REQ-008
  - PRD-REQ-009
verified_by:
  []
---

# Jenkins Step by Step

Jenkins is a parallel diagnostic path. It is not the release authority.

## 1. Start controller

```bash
cd infra/compose/jenkins
cp .env.example .env
# Set JENKINS_IMAGE_TAG to a verified LTS tag or digest.
docker compose build
docker compose up -d
```

The custom controller image in `containers/jenkins/` installs Pipeline, Git, credentials, SSH agent, role-strategy, and configuration-as-code plugins.

## 2. Complete initial Jenkins setup

### UI steps

Open Jenkins → **Manage Jenkins** → **Security**. Disable anonymous read. Create named users/groups for administrators, build users, AI read-only access, and `embedded-release-approvers`.

### UI steps

Jenkins → **Manage Jenkins** → **Nodes** → **New Node**. Add the Ubuntu 24 host agent and label it:

```text
yocto-vps8
```

The host agent needs Docker and the repository build dependencies but must not have Mender signing or production deployment credentials.

## 3. Create pipeline job

For a public repository, run:

```bash
export JENKINS_URL=http://127.0.0.1:8088
export JENKINS_USER='<admin-or-job-config-user>'
export JENKINS_API_TOKEN='<token>'
export JENKINS_REPOSITORY_URL='<git-url>'
scripts/configure-jenkins-job.sh
```

The job uses `ci/jenkins/Jenkinsfile` and repository scripts.

## 4. Validate human approval

Trigger a controlled broken build with `DIAGNOSTIC_REBUILD=true`. Jenkins must pause at **Human Approval for Rebuild**. Only `embedded-release-approvers` may continue.

## 5. Verify separation

The Jenkins job must not contain Mender upload tokens, release-signing keys, Git write credentials, or Jenkins administrator credentials.
