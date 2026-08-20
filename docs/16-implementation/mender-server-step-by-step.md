---
id: IMPL-MENDER-SRV-002
title: Mender Server Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - ADR-008
verified_by:
  []
---

# Mender Server Step by Step

The Mender server is third-party infrastructure. This repository supplies a controlled installation adapter rather than an invented server topology.

## 1. Select and pin the upstream self-hosted bundle

Record:

- exact release/version
- archive URL
- SHA-256
- relative path to the bundle's Compose file
- supported client/meta-mender version
- required environment variables

Store the values as inventory overrides. Keep secrets in Ansible Vault.

## 2. Validate bundle locally

```bash
export MENDER_BUNDLE_ARCHIVE=/path/to/mender-bundle.tar.gz
export MENDER_BUNDLE_SHA256='<sha256>'
export MENDER_INSTALL_ROOT="$PWD/.mender-bundle-test"
export MENDER_COMPOSE_RELATIVE='<path-inside-bundle>/docker-compose.yml'
export MENDER_ENV_FILE=/path/to/mender.env
infra/compose/mender/install-bundle.sh
```

The installer verifies the archive checksum, extracts it, validates `docker compose config`, and starts the exact upstream stack.

## 3. Provision with Ansible

Set the Mender variables and encrypted `vault_mender_env_text`, then run:

```bash
cd infra/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory/<your-inventory>/hosts.yml playbooks/site.yml --ask-become-pass --ask-vault-pass
```

The role in `infra/ansible/roles/mender/tasks/main.yml` fails closed when the bundle contract does not match.

## 4. TLS and exposure

Expose only the Mender device/API endpoint required by clients. Keep database, object storage, and administration services private. Use a publicly trusted certificate when devices access the server over the internet.

## 5. Acceptance

Do not continue to fleet work until one QEMU device can authenticate, report inventory, download one artifact, reboot, commit, and roll back.
