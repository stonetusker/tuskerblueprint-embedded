#!/usr/bin/env python3
"""Convert Yocto oeqa testresults.json files into a JUnit XML report.

Jenkins (and most CI dashboards) understand JUnit XML, while bitbake's
testimage writes its results as JSON. This keeps the CI test view in sync with
what oeqa actually ran.
"""
from __future__ import annotations

import argparse
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

FAILED = {"FAILED", "ERROR", "UNEXPECTEDSUCCESS"}
SKIPPED = {"SKIPPED", "EXPECTEDFAILURE"}


def convert(results_files: list[Path]) -> tuple[ET.Element, dict[str, int]]:
    suites = ET.Element("testsuites")
    totals = {"tests": 0, "failures": 0, "skipped": 0}
    for path in results_files:
        data = json.loads(path.read_text(encoding="utf-8"))
        for run_name, run in sorted(data.items()):
            cases = run.get("result", {})
            suite = ET.SubElement(suites, "testsuite", name=run_name)
            counts = {"tests": 0, "failures": 0, "skipped": 0}
            for test_id, info in sorted(cases.items()):
                status = str(info.get("status", "")).upper()
                module, _, name = test_id.rpartition(".")
                case = ET.SubElement(suite, "testcase", classname=f"oeqa.{module or run_name}", name=name or test_id)
                duration = info.get("duration")
                if isinstance(duration, (int, float)):
                    case.set("time", f"{duration:.3f}")
                log = str(info.get("log") or "")
                if status in FAILED:
                    counts["failures"] += 1
                    ET.SubElement(case, "failure", message=status).text = log
                elif status in SKIPPED:
                    counts["skipped"] += 1
                    ET.SubElement(case, "skipped", message=log.strip()[:500])
                counts["tests"] += 1
            for key, value in counts.items():
                suite.set(key, str(value))
                totals[key] += value
    return suites, totals


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--search-root", type=Path, required=True, help="directory searched for testresults.json")
    parser.add_argument("--output", type=Path, required=True, help="JUnit XML file to write")
    args = parser.parse_args()

    files = sorted(args.search_root.rglob("testresults.json")) if args.search_root.is_dir() else []
    if not files:
        print(f"no testresults.json found under {args.search_root}", file=sys.stderr)
        return 1
    root, totals = convert(files)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root)
    ET.ElementTree(root).write(args.output, encoding="utf-8", xml_declaration=True)
    print(f"wrote {args.output}: {totals['tests']} tests, {totals['failures']} failed, {totals['skipped']} skipped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
