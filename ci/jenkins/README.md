---
id: DIR-CI-JENKINS-README-MD
title: Ci Jenkins Documentation
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-11-16
traces_to:
  []
verified_by:
  []
---

# Ci Jenkins

Jenkins is the only CI/CD orchestrator; GitHub hosts the Git repository only ([ADR-011](../../docs/12-decisions/ADR-011-jenkins-single-orchestrator.md)).

## Layout

| Path | Job | Purpose |
|---|---|---|
| `pipelines/ci.Jenkinsfile` | `sensornode-ci` (multibranch) | Checks on every branch; Yocto build, QEMU test and trusted cache publish on `main` |
| `pipelines/nightly.Jenkinsfile` | `sensornode-nightly` | 02:00 UTC regression build and cache refresh |
| `pipelines/release-candidate.Jenkinsfile` | `sensornode-release-candidate` | Build, test, SBOM, approved signing and write-once publication |
| `pipelines/promote-mender.Jenkinsfile` | `sensornode-promote-mender` | Approved canary deployment of a signed candidate |
| `Jenkinsfile` | `sensornode-diagnostic-build` | Diagnostic build, failure drill, evidence bundle, human-approved rebuild |
| `job-config/*.xml.template` | all | Job definitions applied by `scripts/configure-jenkins-job.sh` |
| `create-diagnostic-bundle.sh` | diagnostic | Redacted evidence bundle |

Step-by-step setup: [Jenkins Pipelines Step by Step](../../docs/16-implementation/jenkins-pipelines-step-by-step.md).

## Agent Boundary

The Jenkins controller runs in a container and executes no builds. Yocto builds run on the host agent labelled `yocto-vps8`. Signing and Mender promotion run only on the isolated agent labelled `firmware-release`, which holds the signing key and has no Docker or Yocto cache access. The controller must not mount the Docker socket.

## Release Authority

Only `sensornode-release-candidate` and `sensornode-promote-mender` may sign, publish release evidence, or deploy, and only after approval by `firmware-signing-approvers` or `firmware-production-approvers`. The CI, nightly and diagnostic jobs hold no signing key or Mender credentials. `make pipeline-check` enforces this.
