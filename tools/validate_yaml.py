#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path
import yaml


def main() -> int:
    failures = []
    count = 0
    for path in sorted(Path('.').rglob('*')):
        if path.suffix not in {'.yml', '.yaml'} or any(part in {'.git', '.venv', 'build'} for part in path.parts):
            continue
        count += 1
        try:
            list(yaml.safe_load_all(path.read_text(encoding='utf-8')))
        except Exception as exc:
            failures.append(f'{path}: {exc}')
    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    print(f'validated YAML syntax in {count} files')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
