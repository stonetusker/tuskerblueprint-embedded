#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path
import yaml


def load(path: Path):
    return yaml.load(path.read_text(encoding='utf-8'), Loader=yaml.BaseLoader)


def main() -> int:
    failures = []
    workflows = sorted(Path('.github/workflows').glob('*.yml'))
    for path in workflows:
        data = load(path)
        if not isinstance(data, dict):
            failures.append(f'{path}: workflow is not a mapping')
            continue
        for key in ('name', 'on', 'jobs'):
            if key not in data:
                failures.append(f'{path}: missing top-level {key}')
        if 'pull_request_target' in (data.get('on') or {}):
            failures.append(f'{path}: pull_request_target is prohibited')
        if 'environment' in data:
            failures.append(f'{path}: environment must be job-scoped')
        jobs = data.get('jobs') or {}
        if not isinstance(jobs, dict) or not jobs:
            failures.append(f'{path}: no jobs defined')
            continue
        for job_name, job in jobs.items():
            if not isinstance(job, dict):
                failures.append(f'{path}:{job_name}: invalid job')
                continue
            if 'runs-on' not in job and 'uses' not in job:
                failures.append(f'{path}:{job_name}: missing runs-on or uses')
    required_environments = {
        Path('.github/workflows/release-candidate.yml'): ('sign-publish', 'firmware-signing'),
        Path('.github/workflows/promote-mender.yml'): ('promote', 'firmware-production'),
    }
    for path, (job, environment) in required_environments.items():
        data = load(path)
        actual = ((data.get('jobs') or {}).get(job) or {}).get('environment')
        if actual != environment:
            failures.append(f'{path}:{job}: expected protected environment {environment!r}, got {actual!r}')
    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    print(f'validated policy structure in {len(workflows)} GitHub workflows')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
