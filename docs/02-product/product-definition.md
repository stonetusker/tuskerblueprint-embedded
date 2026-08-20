---
id: PRD-001
title: SensorNode Product Definition
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - BUS-001
verified_by:
  []
---

# SensorNode Product Definition

SensorNode is a fictional ARM64 embedded Linux IoT device used to demonstrate the software-delivery lifecycle.

## Product Capabilities

- Boot a minimal Yocto image in QEMU
- Run a managed SensorNode application
- Expose health, version, and simulated sensor endpoints
- Report device and artifact identity
- Receive signed Mender updates
- Validate health after reboot
- Commit healthy updates and roll back unhealthy updates
- Emit structured diagnostics

## Initial API

- `GET /health`
- `GET /version`
- `GET /sensor`

## Product Boundary

SensorNode simulates device behavior. It does not claim board-specific timing, peripheral, power, thermal, or safety validation.
