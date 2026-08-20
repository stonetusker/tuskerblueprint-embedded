---
id: IMPL-SRC-001
title: Yocto and Mender Source Locking
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

# Yocto and Mender Source Locking

`kas/base.yml` and `kas/mender.yml` use the Scarthgap branch as the human-readable compatibility baseline. Release builds must overlay `kas/source-lock.yml` containing exact commits.

## Generate the lock

```bash
make setup
make source-lock
make source-lock-check
```

`tools/lock_sources.py` resolves the remote refs using `git ls-remote` and writes the overlay.

## Build behavior

`scripts/build-image.sh` automatically uses `kas/source-lock.yml` when it exists. A caller can select a different reviewed lock with:

```bash
SOURCE_LOCK_CONFIG=kas/source-lock.yml scripts/build-image.sh
```

`.github/workflows/release-candidate.yml` requires the lock and validates `meta-mender` is included.

## Update process

Do not edit commit hashes casually. Regenerate the lock, review upstream changes, rerun the full QEMU and OTA acceptance suite, and merge the lock update as an explicit dependency change.
