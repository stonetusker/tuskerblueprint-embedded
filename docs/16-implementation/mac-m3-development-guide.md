---
id: IMPL-010
title: Apple Silicon Development Guide
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


# Apple Silicon Development Guide

The Mac M3 Pro is well suited to application development and ARM64 QEMU demonstrations. Full Yocto builds should run inside a supported Linux ARM64 virtual machine or remote Linux runner because Yocto is a Linux-hosted build system.

Recommended split:

- Mac: Go development, Markdown, diagrams, Git, local ARM64 QEMU experiments
- Linux ARM64 VM or VPS8: authoritative Yocto build, testimage, artifacts, CI
- VPS8: shared cache, GitHub runner, Jenkins, Mender, persistent QEMU fleet

Do not compare build times between macOS and Linux hosts as though the environment were equivalent.
