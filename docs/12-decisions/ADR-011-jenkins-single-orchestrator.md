---
id: ADR-011
title: Use Jenkins as the Only CI/CD Orchestrator
status: Approved
version: 0.1.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
  - Security Reviewer
created: 2026-11-16
updated: 2026-11-16
traces_to:
  - CI-REQ-001
  - CI-REQ-002
  - CI-REQ-004
verified_by:
  - TEST-CI-001
---

# Use Jenkins as the Only CI/CD Orchestrator

## Status

Approved. Supersedes the earlier arrangement in which GitHub Actions was the authoritative continuous-build orchestrator and Jenkins was a diagnostic demonstration only.

## Context

The project ran two CI systems against the same scripts: GitHub Actions for pull requests, main-branch builds, nightly builds, release candidates and Mender promotion, and Jenkins for the diagnostic and failure-drill story. Both ran on the same Ubuntu 24 host. Keeping two orchestrators doubled the configuration, credentials and runbooks without adding a capability, and most target customers already standardise on Jenkins.

## Decision

- Jenkins is the only CI/CD orchestrator. GitHub hosts the Git repository and nothing else: no GitHub Actions workflows, runners, environments or secrets.
- Jenkins discovers branches by polling the repository (multibranch job `sensornode-ci`), because GitHub webhooks cannot reach the LAN host. No GitHub API token is required and no status is posted back to GitHub.
- The jobs are defined in the repository (`ci/jenkins/`) and stay thin: they call the same repository scripts as before.

| Job | Jenkinsfile | Replaces |
|---|---|---|
| `sensornode-ci` (multibranch) | `ci/jenkins/pipelines/ci.Jenkinsfile` | `pull-request.yml`, `docs.yml`, `ci.yml` |
| `sensornode-nightly` | `ci/jenkins/pipelines/nightly.Jenkinsfile` | `nightly.yml`, `build-image.yml` |
| `sensornode-release-candidate` | `ci/jenkins/pipelines/release-candidate.Jenkinsfile` | `release-candidate.yml` |
| `sensornode-promote-mender` | `ci/jenkins/pipelines/promote-mender.Jenkinsfile` | `promote-mender.yml` |
| `sensornode-diagnostic-build` | `ci/jenkins/Jenkinsfile` | unchanged |

- The release boundaries move to Jenkins unchanged in intent:
  - GitHub protected environments become named Jenkins approval groups: `firmware-signing-approvers` before signing, `firmware-production-approvers` before a canary deployment.
  - The isolated GitHub release runner becomes the Jenkins agent labelled `firmware-release`. It owns the signing key and release tools, has no Docker access and no Yocto cache.
  - Only the release-candidate and promotion jobs may sign, publish release evidence or deploy. The CI, nightly and diagnostic jobs cannot, and `tools/validate_jenkins_pipelines.py` enforces this on every build.
  - Branches other than `main` never write the trusted cache; an on-request branch Yocto build uses an isolated per-branch cache.

## Consequences

- One orchestrator, one set of credentials and one runbook.
- Branch builds give feedback in Jenkins, not on the GitHub pull request page. Reviewers check the `sensornode-ci` job for the branch before merging.
- The approval groups must exist in Jenkins' authorisation strategy (for example role-strategy groups) before release jobs are used in production. Jenkins administrators can always approve an input step.
- The release and promotion jobs need the `firmware-release` agent to be provisioned (`infra/ansible/roles/jenkins_release_agent`). Until then they wait in the queue at the signing or promotion stage.
- AI diagnostics keep their read-only boundary: the MCP identity may read the diagnostic and CI jobs but must have no permission on the release jobs.

## Alternatives Considered

- Keep GitHub Actions authoritative and Jenkins diagnostic only: rejected as duplicate tooling.
- GitHub Branch Source with pull-request status checks: rejected for now because it makes GitHub more than a repository (API token, status reporting). It can be adopted later without changing the Jenkinsfiles.
