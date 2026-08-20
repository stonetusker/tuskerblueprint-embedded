---
id: GOV-002
title: Project Scope
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

# Project Scope

## Included

The initial release includes SensorNode, `qemuarm64`, a Stonetusker Yocto layer, build benchmarking, MinIO-backed downloads and sstate reuse, GitHub Actions, QEMU smoke tests, Mender OTA, canary rollout, pipeline prevention, device rollback, Jenkins diagnostics, Claude analysis, approval controls, SBOMs, signing, and operational runbooks.

## Excluded

The release excludes a custom Yocto MCP server, a separate AI-plus-GitHub demonstration, autonomous AI operation, production hardware labs, board-specific BSP delivery, high availability, multi-cloud operation, and regulatory certification.

## Scope Control

Any proposed expansion requires a change request with cost, risk, timeline, and architecture impact. Demo convenience alone is not sufficient justification.
