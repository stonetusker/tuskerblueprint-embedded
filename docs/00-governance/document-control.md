---
id: GOV-010
title: Document Control
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

# Document Control

## Naming

Use lowercase kebab-case filenames. Stable document identifiers remain in front matter.

## Versioning

Document versions follow semantic intent: major for incompatible governance or architectural change, minor for additive change, and patch for clarification.

## Review Frequency

Security, operations, and architecture documents are reviewed for every public release. Runbooks are exercised at least once before publication.

## Retention

Git retains controlled documents and evidence summaries. Large generated artifacts are retained in CI, MinIO, release storage, or Mender according to policy.
