---
id: INT-009
title: MCP Tool Contract
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---

# MCP Tool Contract

Allowed tools:

- read job status
- read build metadata
- read console excerpt
- read test report
- read selected diagnostic artifact
- prepare rebuild recommendation

Denied tools:

- Jenkins administration
- credential access
- script console
- arbitrary shell
- node reconfiguration
- Git write
- OTA promotion or deployment
- approval action
