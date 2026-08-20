---
id: AI-GOV-007
title: TuskerSquad Alignment
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

# TuskerSquad Alignment

## Policy

Project C uses the same governance thread as TuskerSquad: an AI agent does not merge, rebuild, release, or deploy unsupervised. The control is architectural and auditable, not merely a stated preference.

## Enforcement

Controls are implemented through identity scope, MCP tool allowlists, log redaction, pipeline permissions, authenticated approval, rate limits, and audit records.

## Evidence

The AI diagnostics acceptance test must demonstrate both a permitted diagnosis and a denied unauthorized action.
