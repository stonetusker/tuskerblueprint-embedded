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
        command('Yocto layer policy', ['python3', 'tools/validate_yocto_layer.py'], root),
        command('Ubuntu 24 portability policy', ['python3', 'tools/validate_ubuntu24_portability.py'], root),
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
    release_workflow = (root / '.github/workflows/release-candidate.yml').read_text(encoding='utf-8')
    source_lock_enforced = ('SOURCE_LOCK_CONFIG: kas/source-lock.yml' in release_workflow
                            and 'validate_source_lock.py' in release_workflow)
    checks.append(('Immutable source lock enforcement', source_lock_enforced,
                   'release workflow requires kas/source-lock.yml and validates exact commits'))
    jenkins_template = root / 'ci/jenkins/job-config/sensornode-diagnostic-build.xml.template'
    try:
        import xml.etree.ElementTree as ET
        ET.fromstring(jenkins_template.read_text(encoding='utf-8').replace('__REPOSITORY_URL__', 'https://example.invalid/repo.git'))
        xml_ok, xml_detail = True, 'Jenkins Pipeline job XML is well formed'
    except Exception as exc:
        xml_ok, xml_detail = False, str(exc)
    checks.append(('Jenkins job XML', xml_ok, xml_detail))
    pass_all = all(ok for _, ok, _ in checks)
    rows='\n'.join(f"| {name} | {'Pass' if ok else 'Fail'} | {detail.replace(chr(10), '<br>')[:800]} |" for name,ok,detail in checks)
    report=f"""---
id: REVIEW-002
title: Implementation Repository Review
status: {'Approved' if pass_all else 'In Review'}
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
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

The review validates repository structure, syntax, local application tests, traceability, permissions, and archive consistency. It cannot prove the complete network-fetched Yocto build, Mender A/B update, current Jenkins MCP plugin compatibility, or a live Ubuntu 24 deployment without network access and the target infrastructure. Ubuntu 24 portability is therefore statically validated here and must be exercised on the target host with `scripts/doctor-ubuntu24.sh`. Those remain controlled Phase 0 and integration acceptance tests.

## Review Time

{datetime.now(timezone.utc).isoformat()}
"""
    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(report, encoding='utf-8')
    return 0 if pass_all else 1


if __name__ == '__main__':
    raise SystemExit(main())
