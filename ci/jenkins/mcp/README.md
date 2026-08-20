---
id: IMPL-MCP-001
title: Jenkins MCP Implementation Guide
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - AI-REQ-001
verified_by:
  []
---


# Jenkins MCP Implementation Guide

## Required Tool Surface

The selected plugin or adapter must implement read-only operations for job status, build metadata, bounded console excerpts, test reports, and selected diagnostic artifacts.

## Required Denials

The AI service identity must be unable to use Jenkins administration, Script Console, credentials, node configuration, Git writes, artifact signing, OTA upload, deployment, approval, or unrestricted rebuild APIs.

## Authentication

Use a dedicated Jenkins service account with a role limited to `Overall/Read`, `Job/Read`, `View/Read`, and artifact/test read permissions for only `sensornode-diagnostic-build`.

## Human Approval

The Jenkinsfile uses an authenticated `input` step. Claude can recommend setting `DIAGNOSTIC_REBUILD=true`, but only a member of `embedded-release-approvers` can continue execution.

## Compatibility Gate

Before choosing a plugin, verify:

1. Maintained release and supported Jenkins core
2. Per-tool authorization
3. Bounded log retrieval
4. Audit logging
5. No implicit Script Console access
6. Claude client compatibility
7. Denial tests from `docs/07-verification/ai-diagnostics-tests.md`
