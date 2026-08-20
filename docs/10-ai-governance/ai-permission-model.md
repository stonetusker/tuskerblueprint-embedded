---
id: AI-GOV-002
title: AI Permission Model
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - AI-REQ-DOC
verified_by:
  []
---

# AI Permission Model

## Policy

The AI identity can read selected Jenkins status, logs, reports, and artifacts. It cannot administer Jenkins, read credentials, execute arbitrary shell, write Git, approve, sign, promote, deploy, or roll back.

## Enforcement

Controls are implemented through identity scope, MCP tool allowlists, log redaction, pipeline permissions, authenticated approval, rate limits, and audit records.

## Evidence

The AI diagnostics acceptance test must demonstrate both a permitted diagnosis and a denied unauthorized action.
