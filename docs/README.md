---
id: DOC-INDEX-001
title: Documentation Index
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-11-16
traces_to:
  []
verified_by:
  []
---

# Documentation Index

The numbered directories follow the specification-driven lifecycle from governance and business intent through requirements, architecture, components, interfaces, verification, security, operations, AI governance, content, decisions, traceability, risk, and evidence.

Use templates for new controlled documents. Add every new requirement and test to the traceability matrix.

## Implementation Documents

`docs/16-implementation/` explains how the controlled requirements map to the repository's native code, Yocto metadata, CI workflows, QEMU tests, Mender boundary, Jenkins pipelines and controls, and VPS8 automation.

## Ubuntu 24 Step-by-Step Implementation

Use these implementation guides in sequence:

1. [Ubuntu 24.04 Quick Start](16-implementation/00-ubuntu24-quickstart.md)
2. [Complete Project Implementation Plan](16-implementation/complete-project-implementation-plan.md)
3. [Ubuntu 24 Host Preparation](16-implementation/ubuntu24-host-preparation.md)
4. [External Version and Checksum Pinning](16-implementation/external-version-pinning.md)
5. [Yocto and Mender Source Locking](16-implementation/source-locking.md)
6. [Yocto Build Step by Step](16-implementation/yocto-build-step-by-step.md)
7. [MinIO Cache Step by Step](16-implementation/minio-cache-step-by-step.md)
8. [QEMU Validation Step by Step](16-implementation/qemu-validation-step-by-step.md)
9. [Jenkins Pipelines Step by Step](16-implementation/jenkins-pipelines-step-by-step.md)
10. [Jenkins Step by Step](16-implementation/jenkins-step-by-step.md)
11. [Jenkins MCP and Claude Step by Step](16-implementation/jenkins-mcp-claude-step-by-step.md)
12. [Mender Server Step by Step](16-implementation/mender-server-step-by-step.md)
13. [Mender OTA Step by Step](16-implementation/mender-ota-step-by-step.md)
14. [Mender OTA Explained, with a Web UI Demo](16-implementation/mender-ota-explained.md)
15. [Rollback Demonstration Step by Step](16-implementation/rollback-demo-step-by-step.md)
16. [Release Security Step by Step](16-implementation/release-security-step-by-step.md)
17. [Single Ubuntu 24 Host Infrastructure](16-implementation/infrastructure-ubuntu24-single-host.md)
18. [End-to-End Acceptance Procedure](16-implementation/end-to-end-acceptance.md)
19. [Ubuntu 24 Troubleshooting](16-implementation/ubuntu24-troubleshooting.md)
20. [Implementation Checklist](16-implementation/implementation-checklist.md)
21. [Host Service Restart After Reboot](16-implementation/host-service-restart.md)
22. [Demo Guide](16-implementation/demo-guide.md)
