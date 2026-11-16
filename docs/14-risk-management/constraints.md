---
id: RISK-CON-001
title: Constraints
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-11-16
traces_to:
  []
verified_by:
  []
---

# Constraints

- Project C is delivered before Project A and Project B.
- Documentation remains Markdown in Git.
- Jenkins is the only CI/CD pipeline; GitHub hosts the repository only.
- Only the Jenkins release-candidate and promotion jobs may sign or deploy, after named approval.
- No custom Yocto MCP server is built.
- AI cannot operate consequential infrastructure unsupervised.
- Public claims must be evidence-backed.
