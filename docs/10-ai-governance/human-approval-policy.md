---
id: AI-GOV-003
title: Human Approval Policy
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

# Human Approval Policy

## Policy

Approval is enforced by Jenkins or the pipeline through an authenticated input or protected approval stage. Prompt text alone is not a control.

## Enforcement

Controls are implemented through identity scope, MCP tool allowlists, log redaction, pipeline permissions, authenticated approval, rate limits, and audit records.

## Evidence

The AI diagnostics acceptance test must demonstrate both a permitted diagnosis and a denied unauthorized action.
