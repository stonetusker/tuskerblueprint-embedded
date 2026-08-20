#!/usr/bin/env python3
from __future__ import annotations
import csv
import platform
import sys
from pathlib import Path

source, destination = map(Path, sys.argv[1:3])
rows = list(csv.DictReader(source.open(encoding='utf-8')))
values = {row['case']: int(row['elapsed_seconds']) for row in rows if row['result'] == 'pass'}
ratio = values.get('clean', 0) / values.get('cached', 1) if values.get('cached') else 0
text = f"""# Build Benchmark Summary

- Host: {platform.platform()}
- Architecture: {platform.machine()}
- Clean build: {values.get('clean', 'failed')} seconds
- Cached build: {values.get('cached', 'failed')} seconds
- Improvement ratio: {ratio:.2f}x

The result is valid only with the accompanying source revisions, runner allocation, cache state, and raw logs.
"""
destination.write_text(text, encoding='utf-8')
