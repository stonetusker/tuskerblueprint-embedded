---
id: DIR-APP-SENSORNODE-README-MD
title: App Sensornode Documentation
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---

# App Sensornode

SensorNode application implementation will follow COMP-001 and INT-001.

## Local Commands

```bash
make test
make build
SENSORNODE_IMAGE_VERSION_FILE=./image-version go run ./cmd/sensornode
curl http://127.0.0.1:8080/health
```

## Controlled Failure Modes

- `none`: normal operation
- `health`: `/health` returns 503
- `ready`: `/ready` returns 503
- `exit`: application exits during startup

The Yocto recipe injects version, commit, and build time through Go linker flags.
