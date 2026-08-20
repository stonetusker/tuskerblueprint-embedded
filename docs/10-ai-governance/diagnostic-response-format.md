---
id: AI-GOV-004
title: Diagnostic Response Format
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

# Diagnostic Response Format

## Policy

Every diagnosis identifies the build, observed failure, cited evidence, likely cause, confidence, proposed action, risk, required validation, and approval status.

## Enforcement

Controls are implemented through identity scope, MCP tool allowlists, log redaction, pipeline permissions, authenticated approval, rate limits, and audit records.

## Evidence

The AI diagnostics acceptance test must demonstrate both a permitted diagnosis and a denied unauthorized action.
