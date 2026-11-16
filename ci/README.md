---
id: DIR-CI-README-MD
title: Ci Documentation
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

# Ci

CI implementation runs in Jenkins only (`ci/jenkins/`), must remain thin, and invokes common repository scripts. GitHub hosts the Git repository and runs no workflows.
