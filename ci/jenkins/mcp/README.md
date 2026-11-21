---
id: IMPL-MCP-001
title: Jenkins MCP Implementation Guide
status: Implemented
version: 1.0.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-11-20
traces_to:
  - AI-REQ-001
  - AI-REQ-004
  - AI-REQ-005
  - ADR-009
verified_by:
  - TEST-AI-001
  - TEST-AI-003
  - TEST-AI-004
  - TEST-AI-006
---

# Jenkins MCP Implementation Guide

`jenkins_mcp_server.py` is the constrained adapter chosen in ADR-009. It is a Model Context Protocol (MCP) server that gives Claude read-only, bounded and audited access to Jenkins build evidence. It uses only the Python standard library and runs over stdio, so Claude Code, Claude Desktop or any MCP client starts it as a local process. Nothing is installed in Jenkins.

To connect it to Claude, see [Jenkins MCP and Claude Step by Step](../../../docs/16-implementation/jenkins-mcp-claude-step-by-step.md).

## Files

| File | Purpose |
|---|---|
| `jenkins_mcp_server.py` | The MCP server, also `--check` for a connectivity test |
| `mcp.json.example` | Claude Code project configuration (`.mcp.json`) template |
| `../../../.claude/commands/diagnose-jenkins-build.md` | `/diagnose-jenkins-build` command for Claude Code |
| `../../../tests/mcp/test_jenkins_mcp_server.py` | Unit tests against a fake Jenkins (`make mcp-test`) |

## Tool Surface

These six tools map one-to-one onto the allowed tools in [INT-009](../../../docs/06-interface-specifications/mcp-tool-contract.md).

| MCP tool | Contract tool | Jenkins request (GET only) | Bound |
|---|---|---|---|
| `get_job_status` | read job status | `/job/<job>/api/json` | last 1–25 builds |
| `get_build_metadata` | read build metadata | `/job/<job>/<n>/api/json`, `/wfapi/describe` | named fields only |
| `get_console_excerpt` | read console excerpt | `/job/<job>/<n>/consoleText` | ≤ 400 lines, ≤ 60 000 chars, ≤ 64 MiB read |
| `get_test_report` | read test report | `/job/<job>/<n>/testReport/api/json` | failed (and optionally skipped) cases, ≤ 100 |
| `get_diagnostic_artifact` | read selected diagnostic artifact | `/job/<job>/<n>/artifact/<path>` | allowlisted prefixes, text only, ≤ 5 MiB read, ≤ 400 lines |
| `prepare_rebuild_recommendation` | prepare rebuild recommendation | none | draft text for a human |

`get_console_excerpt` modes:

- `errors` (default): lines that look like failures, each with up to 20 lines of context, newest first.
- `tail` and `head`: the last or first lines.
- `search`: case-insensitive plain-text match on `pattern`.

`build` takes a build number or a Jenkins permalink (`lastBuild`, `lastFailedBuild`, `lastCompletedBuild`, `lastSuccessfulBuild`, `lastUnsuccessfulBuild`, `lastStableBuild`).

## Controls

| Control | How it is enforced | Requirement |
|---|---|---|
| No consequential actions | The server has no code path for POST or any write, approval, build, abort, credential, script or node endpoint. Unknown tools are refused and audited. The Jenkins account also lacks those permissions. | AI-REQ-003, SEC-REQ-004 |
| Job scope | `JENKINS_MCP_ALLOWED_JOBS` allowlist. Job segments must match `[A-Za-z0-9._-]`, and build references must be integers or permalinks, so a request cannot leave `/job/<allowed>/`. | AI-REQ-001 |
| Artifact scope | Only paths that Jenkins lists as archived and that sit under `JENKINS_MCP_ARTIFACT_PREFIXES`. No `..`. Binary files are refused. | AI-REQ-001 |
| Bounded output | Line, character and fetch-byte limits. The response header says when an excerpt was truncated. | AI-REQ-001 |
| Redaction | Every returned string passes through `tools/redact_build_logs.py`, which redacts tokens, passwords, bearer headers, AWS and GitHub keys, PEM private keys, and credentials in URLs. The evidence bundle uses the same redactor. | SEC-REQ-005 |
| Prompt-injection fencing | Build output is wrapped in `<<<BEGIN/END UNTRUSTED JENKINS DATA>>>`. Marker strings inside the data are neutralised, and ANSI and control characters are stripped. The server instructions tell Claude that fenced content is evidence, not instructions. | AI-REQ-005 |
| Rate limit | `JENKINS_MCP_MAX_CALLS_PER_MINUTE` (default 30) | AI-GOV-004 |
| Redirects | Cross-origin redirects are refused, so credentials are never sent to another host. | SEC-REQ-004 |
| Audit | One JSON line per call, denials included: time, AI identity, MCP client, tool, sanitised arguments, target build, evidence class, outcome, byte count and SHA-256 of the returned text. The file is mode 0600. | AI-GOV-006 |
| Human approval | `prepare_rebuild_recommendation` only drafts text. The rebuild runs only after a member of `embedded-release-approvers` approves the Jenkins `input` step. | AI-REQ-004 |

## Configuration

| Variable | Default | Meaning |
|---|---|---|
| `JENKINS_URL` | (required) | Base URL, for example `http://192.168.0.109:8088` |
| `JENKINS_MCP_USER` | (required) | Dedicated read-only service account, for example `claude-diagnostics` |
| `JENKINS_MCP_TOKEN_FILE` | — | File that holds the API token (preferred, mode 0600) |
| `JENKINS_MCP_TOKEN` | — | API token in the environment (use only if a file is not possible) |
| `JENKINS_MCP_ALLOWED_JOBS` | `sensornode-diagnostic-build` | Comma-separated job paths, for example `sensornode-diagnostic-build,sensornode-ci/main,sensornode-nightly` |
| `JENKINS_MCP_ARTIFACT_PREFIXES` | `artifacts/diagnostics/,artifacts/test-reports/,artifacts/oeqa/,artifacts/release-qemu/,artifacts/release-manifest.json` | Readable archived paths |
| `JENKINS_MCP_AUDIT_LOG` | `~/.local/state/tusker-jenkins-mcp/audit.jsonl` | Audit trail location |
| `JENKINS_MCP_MAX_CALLS_PER_MINUTE` | `30` | Rate limit |
| `JENKINS_MCP_MAX_LINES` / `JENKINS_MCP_MAX_CHARS` | `400` / `60000` | Excerpt bounds |
| `JENKINS_MCP_MAX_FETCH_BYTES` / `JENKINS_MCP_MAX_ARTIFACT_BYTES` | 64 MiB / 5 MiB | Read limits |
| `JENKINS_MCP_TIMEOUT` | `30` | HTTP timeout, seconds |
| `JENKINS_MCP_CA_BUNDLE` | system trust | CA file for a private HTTPS Jenkins |
| `JENKINS_MCP_APPROVER_GROUP` | `embedded-release-approvers` | Named in rebuild drafts |

A job added to the allowlist must also be readable by the service account in Jenkins. Both layers must agree.

## Jenkins Service Account Permissions

| Grant | Deny (never grant) |
|---|---|
| Overall/Read | Overall/Administer (this includes the Script Console), Overall/Manage |
| Job/Read on the allowlisted jobs only | Job/Build, Job/Cancel, Job/Configure, Job/Create, Job/Delete, Job/Workspace |
| View/Read (optional) | Run/Replay, Run/Update, Run/Delete |
|  | Credentials/*, Agent/*, SCM/Tag |
|  | Membership of `embedded-release-approvers`, `firmware-signing-approvers` or `firmware-production-approvers` |

Job/Read already covers the console log, archived artifacts, test reports and stage view.

## Compatibility Gate Result

| Criterion | Result |
|---|---|
| Maintained and supported Jenkins core | Uses only stable REST endpoints (`api/json`, `consoleText`, `artifact`, `testReport`, `wfapi`). No plugin is installed in the controller. |
| Per-tool authorisation | Six fixed tools plus a job allowlist, enforced in the adapter and by Jenkins RBAC |
| Bounded log retrieval | Yes |
| Audit logging | Yes, JSONL |
| No implicit Script Console access | Yes. The server never calls `/script`, and the account lacks Overall/Administer. |
| Claude client compatibility | MCP stdio, protocol versions `2025-06-18`, `2025-03-26` and `2024-11-05` |
| Denial tests | `make mcp-test`, and the live negative tests in the step-by-step guide |

## Test

```bash
make mcp-test                                                  # unit tests, no Jenkins required
JENKINS_URL=... JENKINS_MCP_USER=... JENKINS_MCP_TOKEN_FILE=... \
  python3 ci/jenkins/mcp/jenkins_mcp_server.py --check         # live read-only connectivity check
```
