---
id: GOV-001
title: Project Charter
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

# Project Charter

## Mission

Build a public, production-oriented embedded delivery reference implementation for a fictional ARM64 SensorNode. The project will demonstrate Yocto image construction, reusable build caching, self-hosted CI, headless QEMU testing, secure OTA delivery, rollback protection, and AI-assisted Jenkins diagnostics with human approval.

## Business Outcome

The repository and video series must give automotive, aerospace, robotics, medical-device, and industrial buyers direct evidence of Stonetusker Systems' embedded DevOps methodology without disclosing client work.

## Approved Sequence

Project C is built first and remains independently demonstrable before Project A and Project B.

## Success Conditions

- A clean and cached Yocto build are measured under controlled conditions.
- GitHub Actions is the authoritative CI pipeline.
- QEMU testing blocks unsafe promotion.
- Mender updates a QEMU fleet and supports rollback.
- Jenkins exposes diagnostic evidence through a constrained MCP path.
- Claude proposes remediation but cannot execute consequential actions without human approval.
- Requirements, architecture, tests, decisions, runbooks, and evidence are maintained in Markdown.
