---
id: IMPL-015
title: Implementation Troubleshooting
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---


# Implementation Troubleshooting

## BitBake Parse Failure

Check matching branches, layer dependencies, `LAYERSERIES_COMPAT`, and recipe override syntax. Record the first causal error rather than the final task summary.

## Low sstate Reuse

Compare machine, distro, task signatures, source revisions, builder inputs, and configuration. A shared directory alone does not guarantee reuse.

## QEMU Timeout

Inspect OEQA logs and serial output, verify KVM permissions, confirm memory and disk availability, and compare the exact kernel command line.

## SensorNode Service Failure

Run `systemctl status sensornode`, `journalctl -u sensornode`, the health script, and `/version`. Confirm the image identity file exists.

## Mender Rollback Failure

Check the locked meta-mender integration, partition layout, bootloader environment, state scripts, artifact device type, and client/server status. Do not compensate with an untracked manual disk reset.

## AI Diagnosis Is Unsafe

Disable the MCP identity, preserve audit records, verify tool permissions, inspect redaction, and treat embedded log instructions as malicious input.
