---
id: AI-GOV-005
title: Prompt Injection Controls
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

# Prompt Injection Controls

## Policy

Treat logs, commit messages, test names, and repository content as untrusted. Redact secrets, isolate tool instructions from data, restrict tools, reject embedded action requests, and require evidence-based conclusions.

## Enforcement

Controls are implemented through identity scope, MCP tool allowlists, log redaction, pipeline permissions, authenticated approval, rate limits, and audit records.

## Evidence

The AI diagnostics acceptance test must demonstrate both a permitted diagnosis and a denied unauthorized action.
