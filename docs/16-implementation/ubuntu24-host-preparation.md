---
id: IMPL-U24-001
title: Ubuntu 24 Host Preparation
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

# Ubuntu 24 Host Preparation

## Supported hosts

- Ubuntu 24.x `x86_64`
- Ubuntu 24.x `aarch64`
- Bare metal, VM, or cloud VM with adequate RAM and disk

QEMU uses TCG on x86_64. On aarch64 it can use KVM when `/dev/kvm` is accessible.

## Automated installation

```bash
scripts/bootstrap-ubuntu24.sh
newgrp docker
scripts/doctor-ubuntu24.sh
```

The bootstrap installs Docker, Compose v2, QEMU ARM, Go, Python, Ansible Core, Git, shellcheck, and supporting tools. It creates `.venv`, `cache/`, `build/`, and `artifacts/`, and builds `containers/yocto-builder/Dockerfile` unless `--skip-builder` is used.

## Manual verification

```bash
cat /etc/os-release
uname -m
docker info
docker compose version
qemu-system-aarch64 --version
go version
python3 --version
df -h .
free -h
```

## Resource tuning

Copy `config/project.env.example` to `config/project.env` and lower these values on a smaller host:

```text
BB_NUMBER_THREADS=4
PARALLEL_MAKE=-j 4
```

`config/project.env` is ignored by Git. CI variables override it.
