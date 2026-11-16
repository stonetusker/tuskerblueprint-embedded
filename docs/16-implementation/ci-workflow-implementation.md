---
id: IMPL-004
title: CI Pipeline Implementation
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-11-16
traces_to:
  - ARCH-001
verified_by:
  []
---


# CI Pipeline Implementation

All CI/CD runs in Jenkins ([ADR-011](../12-decisions/ADR-011-jenkins-single-orchestrator.md)); GitHub only hosts the repository. Job setup is in [Jenkins Pipelines Step by Step](jenkins-pipelines-step-by-step.md).

## Branches and Pull Requests

The multibranch job `sensornode-ci` polls Git and builds every branch: document, YAML, Python, shell, pipeline-policy and Go checks. A branch can request the expensive Yocto and QEMU stage (`YOCTO_BUILD`); it then uses an isolated per-branch cache and never receives cache-write, signing or deployment credentials.

## Main

The same job on `main` builds the CI image with the shared cache, executes `testimage`, publishes JUnit results and build outputs, and writes the trusted MinIO cache only after success. `sensornode-nightly` repeats this from a clean `build/tmp` at 02:00 UTC.

## Release Candidate

`sensornode-release-candidate` builds the release image from a commit already on `main`, verifies the exact release disk in QEMU, collects SPDX output and, after `firmware-signing-approvers` approve, signs on the isolated `firmware-release` agent and publishes an immutable candidate to MinIO.

## Promotion

`sensornode-promote-mender` waits for `firmware-production-approvers`, then downloads the exact candidate on the `firmware-release` agent, verifies its checksum, uploads it to Mender, and deploys only to canary devices.
