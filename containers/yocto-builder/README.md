---
id: DIR-CONTAINERS-YOCTO-BUILDER-README-MD
title: Containers Yocto-Builder Documentation
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

# Containers Yocto-Builder

The builder container will follow COMP-005 and ADR-005.

## Build

```bash
docker build -t stonetusker/yocto-builder:0.2.0 containers/yocto-builder
```

## Use

```bash
docker run --rm -it \
  -v "$PWD:/work" \
  -v "$PWD/cache:/cache" \
  -v "$PWD/artifacts:/artifacts" \
  stonetusker/yocto-builder:0.2.0 kas build kas/ci.yml
```

The release pipeline must pin the resulting image by digest rather than mutable tag.
