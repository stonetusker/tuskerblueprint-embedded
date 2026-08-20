#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path

PATTERNS = [
    (re.compile(r'(?i)(authorization:\s*bearer\s+)[A-Za-z0-9._~+/-]+=*'), r'\1[REDACTED]'),
    (re.compile(r'(?i)(token|password|secret|access[_-]?key)(\s*[=:]\s*)([^\s"\']+)'), r'\1\2[REDACTED]'),
    (re.compile(r'AKIA[0-9A-Z]{16}'), '[REDACTED_AWS_ACCESS_KEY]'),
    (re.compile(r'gh[pousr]_[A-Za-z0-9_]{20,}'), '[REDACTED_GITHUB_TOKEN]'),
]


def redact(text: str) -> str:
    for pattern, replacement in PATTERNS:
        text = pattern.sub(replacement, text)
    return text


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', required=True)
    args = parser.parse_args()
    root = Path(args.root)
    for path in root.rglob('*'):
        if path.is_file() and path.stat().st_size <= 20 * 1024 * 1024:
            try:
                text = path.read_text(encoding='utf-8')
            except UnicodeDecodeError:
                continue
            path.write_text(redact(text), encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
