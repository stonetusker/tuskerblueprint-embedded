---
id: TEST-CATALOG-001
title: Test Case Catalog
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - PRD-003
verified_by:
  []
---

# Test Case Catalog

This catalog defines every stable test identifier referenced by the requirements and traceability documents. Detailed procedures live in the corresponding verification specifications and will be refined before implementation.

| Test ID | Purpose | Traced Requirements | Status |
|---|---|---|---|
| TEST-SPIKE-001 | Build the selected Yocto baseline and pass OEQA. | ADR-001 | Planned |
| TEST-SPIKE-002 | Validate builder host resources, container behavior, and cache reuse. | ADR-005, ADR-006 | Planned |
| TEST-SPIKE-003 | Prove Mender install, reboot, commit, and rollback on QEMU. | ADR-008 | Planned |
| TEST-SPIKE-004 | Verify Jenkins MCP allowlist, audit, Claude access, and denied actions. | ADR-009 | Planned |
| TEST-ACCEPT-001 | TEST-ACCEPT-001. | See traceability matrix | Planned |
| TEST-AI-001 | Allow Claude to inspect Jenkins evidence and propose remediation through a constrained MCP integration. | AI-REQ-001, PRD-REQ-008 | Planned |
| TEST-AI-002 | Require explicit human approval before an AI-proposed rebuild is executed. | AI-REQ-003, AI-REQ-004, PRD-REQ-009 | Planned |
| TEST-AI-003 | AI access shall exclude administrator, shell, credential, and deployment authority. | SEC-REQ-004 | Planned |
| TEST-AI-004 | Build logs shall be redacted before AI access. | SEC-REQ-005 | Planned |
| TEST-AI-005 | AI diagnoses shall cite relevant build evidence and state confidence. | AI-REQ-002 | Planned |
| TEST-AI-006 | Build logs and repository content shall be treated as untrusted prompt input. | AI-REQ-005 | Planned |
| TEST-APP-001 | The SensorNode application shall expose `/health`, `/version`, and `/sensor`. | SWE-REQ-001 | Planned |
| TEST-APP-002 | The version response shall include application version, image version, and device identifier. | SWE-REQ-003 | Planned |
| TEST-APP-003 | The application shall emit structured startup and health events. | SWE-REQ-004 | Planned |
| TEST-APP-004 | A controlled failure mode shall support negative and rollback tests. | SWE-REQ-005 | Planned |
| TEST-BUILD-001 | Build a minimal ARM64 SensorNode image with Yocto. | PRD-REQ-001, SYS-REQ-001 | Planned |
| TEST-BUILD-002 | The build shall run as an unprivileged user in a pinned builder environment. | BLD-REQ-001 | Planned |
| TEST-BUILD-003 | The build shall support clean, cached, CI, release, and broken-demo configurations. | BLD-REQ-002 | Planned |
| TEST-CACHE-001 | Measure clean and shared-cache build performance under equivalent conditions. | BLD-REQ-003, PRD-REQ-003 | Planned |
| TEST-CI-001 | GitHub Actions shall be the authoritative continuous-build orchestrator. | CI-REQ-001 | Planned |
| TEST-CI-002 | GitHub Actions and Jenkins shall invoke common repository scripts. | CI-REQ-002 | Planned |
| TEST-CI-003 | Full Yocto build concurrency shall be limited until resource evidence supports expansion. | CI-REQ-003 | Planned |
| TEST-CI-004 | A main-branch failure shall retain actionable logs and test reports. | CI-REQ-005 | Planned |
| TEST-CONTENT-001 | Each episode shall map to a reproducible repository tag. | CONTENT-REQ-001 | Planned |
| TEST-CONTENT-002 | Performance claims shall cite measured environment and elapsed time. | CONTENT-REQ-002 | Planned |
| TEST-CONTENT-003 | The QEMU target shall not be presented as physical-board certification. | CONTENT-REQ-003 | Planned |
| TEST-CONTENT-004 | The AI episode shall show diagnosis, proposal, human approval, and rebuild. | CONTENT-REQ-004 | Planned |
| TEST-CONTENT-005 | No credentials, private infrastructure data, or client information shall be exposed. | CONTENT-REQ-005 | Planned |
| TEST-DOC-001 | Maintain requirements, architecture, tests, decisions, runbooks, and evidence summaries as Markdown in Git. | PRD-REQ-010 | Planned |
| TEST-EVID-001 | TEST-EVID-001. | See traceability matrix | Planned |
| TEST-OPS-001 | The VPS8 foundation shall be provisioned through Ansible. | OPS-REQ-001 | Planned |
| TEST-OPS-002 | Persistent service data shall have documented backup and restore procedures. | OPS-REQ-002 | Planned |
| TEST-OPS-003 | Disk use, service health, and runner availability shall be monitored. | OPS-REQ-003 | Planned |
| TEST-OPS-004 | Cache cleanup shall follow a documented retention policy. | OPS-REQ-004 | Planned |
| TEST-OPS-005 | The runner shall clean ephemeral workspaces after jobs. | OPS-REQ-005 | Planned |
| TEST-OTA-001 | Deliver a validated image to a QEMU device through Mender OTA. | OTA-REQ-001, PRD-REQ-005, SYS-REQ-005 | Planned |
| TEST-OTA-002 | Deployment shall begin with a canary device. | OTA-REQ-003 | Planned |
| TEST-OTA-003 | Post-boot health shall control update commit. | OTA-REQ-004 | Planned |
| TEST-PLAN-001 | TEST-PLAN-001. | See traceability matrix | Planned |
| TEST-QEMU-001 | Validate every release candidate in headless QEMU before promotion. | PRD-REQ-004, QEMU-REQ-001, SYS-REQ-003 | Planned |
| TEST-QEMU-002 | The harness shall enforce startup and shutdown timeouts. | QEMU-REQ-002 | Planned |
| TEST-QEMU-003 | Run the SensorNode application as a managed systemd service. | PRD-REQ-002, QEMU-REQ-003, SWE-REQ-002 | Planned |
| TEST-QEMU-004 | The system shall prevent promotion when mandatory QEMU validation fails. | QEMU-REQ-004, SYS-REQ-004 | Planned |
| TEST-QEMU-005 | QEMU evidence shall include command line, serial log, test result, and image checksum. | QEMU-REQ-005 | Planned |
| TEST-REL-001 | The system shall produce release metadata that identifies commit, layers, machine, image, builder, and checksums. | SYS-REQ-002 | Planned |
| TEST-ROLLBACK-001 | Prevent a failed build or smoke test from creating an OTA deployment. | PRD-REQ-006, SYS-REQ-006 | Planned |
| TEST-ROLLBACK-002 | Roll back an installed but unhealthy update to the last known good version. | OTA-REQ-005, PRD-REQ-007, SYS-REQ-007 | Planned |
| TEST-SEC-001 | The build shall fail on unpinned or checksum-invalid source inputs. | BLD-REQ-004 | Planned |
| TEST-SEC-002 | The build shall emit an SPDX-compatible SBOM for release candidates. | BLD-REQ-005, SEC-REQ-003 | Planned |
| TEST-SEC-003 | Untrusted pull requests shall not receive unrestricted cache-write or deployment credentials. | CI-REQ-004 | Planned |
| TEST-SEC-004 | Mender artifacts shall be signed and checksummed. | OTA-REQ-002 | Planned |
| TEST-SEC-005 | No production secret shall be stored in Git. | SEC-REQ-001 | Planned |
| TEST-SEC-006 | Service identities shall use least privilege. | SEC-REQ-002 | Planned |
| TEST-SEC-007 | Main branch and release promotion shall require protected review controls. | SEC-REQ-006 | Planned |
| TEST-STRAT-001 | TEST-STRAT-001. | See traceability matrix | Planned |

## Status Rules

- **Planned:** Defined but not implemented.
- **Implemented:** Automated or manual procedure exists.
- **Verified:** Passing evidence has been reviewed.
- **Blocked:** Execution cannot proceed because a dependency is unavailable.
