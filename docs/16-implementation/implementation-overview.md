---
id: IMPL-001
title: Implementation Overview
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


# Implementation Overview

The repository now contains both controlled specifications and implementation assets. The initial executable baseline includes the SensorNode Go service, a genuine Yocto layer, `kas` manifests, a pinned builder definition, OEQA runtime tests, GitHub Actions workflows, a Jenkins diagnostic pipeline, Mender artifact and health tooling, QEMU launchers, Ansible roles, and review utilities.

## Authority Boundaries

- GitHub Actions builds and validates candidates.
- Mender promotion uses an existing immutable candidate.
- Jenkins runs the same scripts for diagnostics but has no OTA authority.
- Claude reads constrained Jenkins evidence and cannot approve execution.
