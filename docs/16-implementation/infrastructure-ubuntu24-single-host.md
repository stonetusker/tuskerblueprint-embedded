---
id: IMPL-INFRA-U24-001
title: Single Ubuntu 24 Host Infrastructure
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  []
verified_by:
  []
---

# Single Ubuntu 24 Host Infrastructure

Project C can be demonstrated on one Ubuntu 24 host. For client production environments, split build execution, signing, and service workloads according to risk and capacity.

## Single-host layout

```text
Ubuntu 24 host
├── Docker Engine
├── GitHub Actions build runner (tusker user)
├── GitHub Actions release runner (release-runner user)
├── Jenkins controller container
├── Jenkins host agent
├── MinIO container
├── Mender upstream bundle containers
├── Caddy/reverse proxy
├── Yocto cache
└── QEMU processes
```

## Provisioning

For repeatable infrastructure use `infra/ansible/playbooks/site.yml`. The roles validate checksums and required secrets before service activation.

## Isolation rules

- Build runner: Docker and cache access, no signing key.
- Release runner: signing and release-evidence access, no Docker build authority.
- Jenkins controller: no Docker socket and no production credentials.
- Jenkins agent: build/cache only.
- Mender service: only required network/database/object-store credentials.

## Capacity

Serialize full Yocto builds initially. Keep cache and service data on persistent storage. Monitor disk usage aggressively; Yocto and sstate can consume hundreds of GiB over time.
