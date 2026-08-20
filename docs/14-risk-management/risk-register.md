---
id: RISK-REG-001
title: Risk Register
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

# Risk Register

| ID | Risk | Severity | Mitigation | Status |
|---|---|---|---|---|
| RISK-001 | Yocto and Mender incompatibility | High | Complete one-device compatibility spike before baseline freeze. | Open |
| RISK-002 | VPS8 CPU, RAM, disk, or I/O exhaustion | High | Limit concurrency, monitor resources, use lifecycle policies, and retain capacity margin. | Open |
| RISK-003 | QEMU claims imply physical-board validation | Medium | Use approved ARM64 QEMU wording and publish limitations. | Open |
| RISK-004 | Mender deployment consumes excessive effort | High | Use non-HA reference topology and prove minimal OTA early. | Open |
| RISK-005 | Jenkins MCP integration lacks safe controls | High | Evaluate against the MCP contract and use an equivalent constrained adapter if required. | Open |
| RISK-006 | Secrets leak through build logs | High | Redact before AI access, use synthetic fixtures, and scan artifacts. | Open |
| RISK-007 | Shared cache poisoning | High | Separate trust levels and write credentials; restrict untrusted pull requests. | Open |
| RISK-008 | Demo-only manual steps reduce credibility | Medium | Require repository scripts, repeatability, and tagged evidence. | Open |
| RISK-009 | Build comparison is misleading | Medium | Use identical environment and publish benchmark methodology. | Open |
| RISK-010 | Project C duplicates future Project A infrastructure | Medium | Use modular Ansible and document migration boundaries. | Open |
