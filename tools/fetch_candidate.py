#!/usr/bin/env python3
from __future__ import annotations
import argparse
import hashlib
import os
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--uri', required=True)
parser.add_argument('--output', required=True)
parser.add_argument('--sha256', required=True)
args = parser.parse_args()
if not args.uri.startswith('minio://'):
    raise SystemExit('only minio:// candidate URIs are permitted')
alias = os.environ.get('MINIO_ALIAS')
if not alias:
    raise SystemExit('MINIO_ALIAS is required')
source = f"{alias}/{args.uri.removeprefix('minio://')}"
output = Path(args.output); output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run(['mc', 'cp', source, str(output)], check=True)
actual = hashlib.sha256(output.read_bytes()).hexdigest()
if actual != args.sha256.lower():
    output.unlink(missing_ok=True)
    raise SystemExit(f'checksum mismatch: expected {args.sha256}, got {actual}')
