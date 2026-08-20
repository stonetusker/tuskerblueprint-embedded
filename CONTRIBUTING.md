---
id: GOV-CONTRIB-001
title: Contributing Guide
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

# Contributing

## Contribution Workflow

1. Create or reference an approved requirement.
2. Update the relevant architecture or component specification.
3. Add or update a test specification before implementation.
4. Implement the change in a feature branch.
5. Update traceability and evidence summaries.
6. Open a pull request with requirement, decision, and test identifiers.
7. Obtain the required technical and governance reviews.

## Pull Request Requirements

Every pull request must state:

- Change objective
- Requirement identifiers
- ADR identifiers when applicable
- Security impact
- Test evidence
- Documentation impact
- Rollback approach

## Commit Guidance

Use focused commits. Recommended prefixes are `spec:`, `arch:`, `feat:`, `test:`, `sec:`, `ops:`, `fix:`, and `docs:`.

## Review Expectations

Embedded changes require embedded engineering review. CI, infrastructure, and runner changes require platform engineering review. AI permissions, OTA promotion, signing, and secret changes require security review.
