#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path
import yaml
from repo_files import repo_files


def main() -> int:
    failures = []
    count = 0
    for path in repo_files('.', ('.yml', '.yaml')):
        count += 1
        try:
            list(yaml.safe_load_all(path.read_text(encoding='utf-8')))
        except Exception as exc:
            failures.append(f'{path.relative_to(Path.cwd().resolve())}: {exc}')
    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    print(f'validated YAML syntax in {count} files')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
