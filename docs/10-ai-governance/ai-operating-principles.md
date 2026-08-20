---
id: AI-GOV-001
title: AI Operating Principles
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

# AI Operating Principles

## Policy

AI may inspect, summarize, classify, explain, and recommend. Deterministic automation validates. Humans approve consequential action.

## Enforcement

Controls are implemented through identity scope, MCP tool allowlists, log redaction, pipeline permissions, authenticated approval, rate limits, and audit records.

## Evidence

The AI diagnostics acceptance test must demonstrate both a permitted diagnosis and a denied unauthorized action.
