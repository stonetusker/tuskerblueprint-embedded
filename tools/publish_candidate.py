#!/usr/bin/env python3
from __future__ import annotations
import argparse
import os
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--artifact-root', required=True)
parser.add_argument('--destination', required=True)
args = parser.parse_args()
if not args.destination.startswith('minio://'):
    raise SystemExit('only minio:// destinations are permitted by this reference implementation')
alias = os.environ.get('MINIO_ALIAS')
if not alias:
    raise SystemExit('MINIO_ALIAS is required')
bucket_path = args.destination.removeprefix('minio://')
destination = f'{alias}/{bucket_path.rstrip('/')}'
probe = subprocess.run(['mc', 'stat', destination], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
if probe.returncode == 0:
    raise SystemExit(f'immutable destination already exists: {args.destination}')
subprocess.run(['mc', 'cp', '--recursive', f"{args.artifact_root.rstrip('/')}/", f'{destination}/'], check=True)
