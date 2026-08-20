#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def command(name, args, cwd):
    result = subprocess.run(args, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return name, result.returncode == 0, result.stdout.strip()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', default='.')
    parser.add_argument('--report', default='REVIEW_REPORT.md')
    args = parser.parse_args()
    root = Path(args.root).resolve()
    checks = [
        command('Specification metadata', ['python3', 'tools/validate_specs.py'], root),
        command('Traceability', ['python3', 'tools/validate_traceability.py'], root),
        command('Markdown links', ['python3', 'tools/validate_markdown_links.py'], root),
        command('YAML syntax', ['python3', 'tools/validate_yaml.py'], root),
        command('GitHub workflow policy', ['python3', 'tools/validate_workflows.py'], root),
        command('Repository security policy', ['python3', 'tools/validate_repository_policy.py'], root),
        command('Python syntax', ['python3', '-m', 'compileall', '-q', 'tools', 'tests'], root),
        command('Shell syntax', ['bash', 'scripts/check-shell-syntax.sh'], root),
        command('Go tests', ['go', 'test', './...'], root / 'app/sensornode'),
        command('SensorNode endpoint integration', ['bash', 'scripts/test-sensornode-integration.sh'], root),
    ]
    executable = [p for p in root.rglob('*.sh') if not (p.stat().st_mode & 0o111)]
    checks.append(('Shell executable permissions', not executable, '\n'.join(map(str, executable)) or 'all shell scripts executable'))
    native = [p for p in root.rglob('*') if p.is_file() and p.suffix in {'.bb', '.bbappend', '.conf', '.inc'}]
    checks.append(('Yocto layer assets', len(native) >= 10, f'{len(native)} native Yocto metadata files'))
    pass_all = all(ok for _, ok, _ in checks)
    rows='\n'.join(f"| {name} | {'Pass' if ok else 'Fail'} | {detail.replace(chr(10), '<br>')[:800]} |" for name,ok,detail in checks)
    report=f"""---
id: REVIEW-002
title: Implementation Repository Review
status: {'Approved' if pass_all else 'In Review'}
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - GOV-007
verified_by:
  - TEST-DOC-001
---

# Implementation Repository Review

## Outcome

**{'PASS' if pass_all else 'REQUIRES CORRECTION'}**

| Check | Result | Detail |
|---|---|---|
{rows}

## Engineering Review Boundaries

The review validates repository structure, syntax, local application tests, traceability, permissions, and archive consistency. It cannot prove the complete Yocto build, Mender A/B update, Jenkins MCP plugin compatibility, or VPS8 deployment without network access and the target infrastructure. Those remain controlled Phase 0 and integration acceptance tests.

## Review Time

{datetime.now(timezone.utc).isoformat()}
"""
    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(report, encoding='utf-8')
    return 0 if pass_all else 1


if __name__ == '__main__':
    raise SystemExit(main())
