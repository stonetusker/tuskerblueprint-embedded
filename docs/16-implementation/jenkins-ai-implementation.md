---
id: IMPL-007
title: Jenkins and AI Diagnostics Implementation
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


# Jenkins and AI Diagnostics Implementation

The Jenkinsfile runs repository validation, the common Yocto build, and QEMU test scripts. Failure evidence is copied, bounded, redacted, fingerprinted, and exposed to a least-privilege AI identity.

A rebuild is possible only when the job parameter enables the approval stage and an authenticated member of `embedded-release-approvers` approves the Jenkins `input` step.

Claude reads that evidence through the constrained MCP adapter in `ci/jenkins/mcp/` (ADR-009), which must pass the allowlist and denial tests (`make mcp-test`, plus the live negative tests) before use. Setup: [Jenkins MCP and Claude Step by Step](jenkins-mcp-claude-step-by-step.md).
