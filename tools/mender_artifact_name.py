#!/usr/bin/env python3
"""Print the artifact name stored in a Mender artifact (format version 3) header."""
from __future__ import annotations

import argparse
import gzip
import io
import json
import lzma
import tarfile
from pathlib import Path


def decompress(name: str, payload: bytes) -> bytes:
    if name.endswith('.gz'):
        return gzip.decompress(payload)
    if name.endswith('.xz'):
        return lzma.decompress(payload)
    if name.endswith('.zst'):
        import zstandard  # optional; only needed for zstd-compressed artifacts
        return zstandard.ZstdDecompressor().decompressobj().decompress(payload)
    return payload


def artifact_name(path: Path) -> str:
    with tarfile.open(path, mode='r:') as outer:
        for member in outer:
            if member.name.startswith('header.tar'):
                header = decompress(member.name, outer.extractfile(member).read())
                break
        else:
            raise SystemExit(f'{path}: no header in Mender artifact')
    with tarfile.open(fileobj=io.BytesIO(header), mode='r:') as inner:
        info = json.load(inner.extractfile('header-info'))
    return info['artifact_provides']['artifact_name']


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('artifact', type=Path)
    args = parser.parse_args()
    print(artifact_name(args.artifact))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
