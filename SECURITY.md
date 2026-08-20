---
id: SEC-POL-001
title: Security Policy
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - SEC-REQ-001
verified_by:
  []
---

# Security Policy

## Reporting

Security issues must be reported privately to Stonetusker Systems. Public issues must not include credentials, exploit details, signing material, infrastructure addresses, or device identities.

## Supported Scope

The security policy covers:

- Yocto source and layer integrity
- CI runners and build containers
- MinIO caches and evidence storage
- Mender server, artifacts, and clients
- Jenkins and MCP integrations
- Claude diagnostic access
- QEMU fleet credentials
- Release signing and SBOMs

## Non-Negotiable Controls

- No secrets in Git
- No AI access to unrestricted shells
- No autonomous AI release or deployment action
- Signed OTA artifacts
- Protected main branch
- Immutable release candidates
- Least-privilege service identities
- Auditable human approvals
