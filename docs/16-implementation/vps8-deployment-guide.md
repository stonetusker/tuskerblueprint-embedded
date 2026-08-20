---
id: IMPL-011
title: VPS8 Deployment Guide
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---


# VPS8 Deployment Guide

1. Create a non-root deployment account with SSH keys.
2. Configure firewall and restricted administration access.
3. Populate a production Ansible inventory and encrypted variables.
4. Pin runner, MinIO, Jenkins, and Mender inputs by version and checksum.
5. Run `ansible-playbook infra/ansible/playbooks/site.yml`.
6. Register the runner with `yocto` and `release` labels separated by authority.
7. Create MinIO buckets and least-privilege policies.
8. Configure Jenkins roles, job, MCP account, and approval group.
9. Validate backups and disk-pressure alerts.
10. Execute the acceptance sequence before enabling public demos.
