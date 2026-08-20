---
id: INT-001
title: SensorNode Application API
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  - ARCH-001
verified_by:
  []
---

# SensorNode Application API

## `GET /health`

Returns HTTP 200 with `status`, `application_version`, `image_version`, and `device_id` when healthy. Returns a non-2xx code during controlled failure.

## `GET /version`

Returns immutable build identity matching release metadata.

## `GET /sensor`

Returns a simulated reading with unit, timestamp, sequence, and device identifier.

## Compatibility

Additive fields are allowed in minor releases. Removing or changing field meaning requires a major interface revision.
