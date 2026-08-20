---
id: DIR-INFRA-README-MD
title: Infra Documentation
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

# Infra

Infrastructure is provisioned through modular Ansible for standalone VPS8 operation.

## Deployment Policy

The Ansible inventory must replace every `required` value with a reviewed immutable version or checksum. Secrets belong in Ansible Vault or an approved secret store, never group variables committed to Git.

The included roles establish a controlled baseline. Mender activation remains blocked until the Phase 0 compatibility evidence approves the exact upstream bundle.
