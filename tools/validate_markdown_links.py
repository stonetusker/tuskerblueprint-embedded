#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

LINK = re.compile(r'\[[^\]]+\]\(([^)]+)\)')
SKIP_PARTS = {'.git', '.venv', '.pytest_cache', '__pycache__', 'build'}


def main() -> int:
    root = Path('.').resolve()
    broken = []
    count = 0
    for path in sorted(root.rglob('*.md')):
        if any(part in SKIP_PARTS for part in path.parts):
            continue
        count += 1
        text = path.read_text(encoding='utf-8')
        for href in LINK.findall(text):
            if href.startswith(('http://', 'https://', 'mailto:', '#')):
                continue
            target_part = href.split('#', 1)[0]
            if not target_part:
                continue
            target = (path.parent / target_part).resolve()
            if not target.exists():
                broken.append(f'{path.relative_to(root)} -> {href}')
    if broken:
        print('\n'.join(broken), file=sys.stderr)
        return 1
    print(f'validated relative links in {count} Markdown files')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
