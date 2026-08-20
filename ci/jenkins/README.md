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
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---

# Ci Jenkins

Jenkins is a dedicated diagnostic demonstration and cannot promote OTA releases.

## Diagnostic Job

Create one multibranch or pipeline job named `sensornode-diagnostic-build` using `ci/jenkins/Jenkinsfile`. Do not grant this job Mender upload credentials or release-signing keys.

## Agent Boundary

The Jenkins controller may run in a container, but Yocto builds run on a dedicated host agent labeled `yocto-vps8`. The controller must not mount the Docker socket or receive signing/Mender credentials. The host agent has the same checked-out repository scripts and cache paths used by GitHub Actions.
