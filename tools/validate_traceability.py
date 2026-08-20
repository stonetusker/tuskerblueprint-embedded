#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ID = re.compile(r"\b(?:BUS-OBJ|PRD-REQ|SYS-REQ|SWE-REQ|BLD-REQ|CI-REQ|QEMU-REQ|OTA-REQ|SEC-REQ|OPS-REQ|AI-REQ|CONTENT-REQ|ARCH|COMP|INT|ADR|TEST|RUN|RISK|EVID)-[A-Z0-9-]*\d{3}\b")
TEST = re.compile(r"\bTEST-[A-Z]+-\d{3}\b")


def main() -> int:
    root = Path(".").resolve()
    texts = {p: p.read_text(encoding="utf-8") for p in root.rglob("*.md") if not any(part in {".git", ".venv", ".pytest_cache", "__pycache__"} for part in p.parts)}
    declared = set()
    for text in texts.values():
        match = re.search(r"^id:\s*(\S+)\s*$", text, re.M)
        if match:
            declared.add(match.group(1))
        for line in text.splitlines():
            if line.startswith("| "):
                cells = [cell.strip() for cell in line.strip("|").split("|")]
                if cells and re.match(r"^[A-Z]+(?:-[A-Z]+)*-\d{3}$", cells[0]):
                    declared.add(cells[0])
    catalog = root / "docs/07-verification/test-case-catalog.md"
    cataloged = set(TEST.findall(catalog.read_text(encoding="utf-8"))) if catalog.exists() else set()
    referenced_tests = set()
    for text in texts.values():
        referenced_tests.update(TEST.findall(text))
    missing = sorted(referenced_tests - cataloged - {"TEST-CATALOG-001"})
    if missing:
        print("undefined test identifiers: " + ", ".join(missing), file=sys.stderr)
        return 1
    matrix = root / "docs/13-traceability/requirement-traceability-matrix.md"
    if not matrix.exists() or "PRD-REQ-001" not in matrix.read_text(encoding="utf-8"):
        print("traceability matrix is missing or incomplete", file=sys.stderr)
        return 1
    print(f"validated {len(referenced_tests)} referenced test identifiers")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
