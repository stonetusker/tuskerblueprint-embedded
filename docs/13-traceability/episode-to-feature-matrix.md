---
id: TRACE-004
title: Episode-to-Feature Matrix
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

# Episode-to-Feature Matrix

| Episode | Feature | Primary Evidence |
|---|---|---|
| 1 | Clean and cached build | Benchmark summary and raw CI evidence |
| 2 | GitHub Actions build | Workflow run, build metadata, runner status |
| 3 | QEMU gate | Serial log, JUnit, failed-unit evidence |
| 4 | Mender OTA | Artifact checksum, deployment, device version |
| 5 | Prevention and rollback | Failed CI, paused rollout, recovered device |
| 6 | AI diagnostics | MCP audit, cited diagnosis, approval, rebuild |
