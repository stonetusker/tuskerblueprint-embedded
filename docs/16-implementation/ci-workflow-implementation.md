---
id: IMPL-004
title: CI Workflow Implementation
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---


# CI Workflow Implementation

## Pull Request

Runs document, YAML, Python, shell, and Go checks. A labeled pull request can request the expensive self-hosted Yocto and QEMU job without exposing deployment credentials.

## Main

Pulls shared cache, builds the CI image, executes `testimage`, publishes evidence, and writes trusted cache only after success.

## Release Candidate

Builds a release image, verifies QEMU, generates SPDX output, and publishes an immutable candidate to MinIO.

## Promotion

A protected GitHub environment downloads the exact candidate, verifies its checksum, uploads it to Mender, and deploys only to canary devices.
