#!/usr/bin/env python3
"""
CI guardrails to avoid fail-open quality checks.

Fails when a workflow contains a pattern that lets a failing step pass:
shell bypasses like `|| true`, `|| echo ...` or `|| exit 0`, and
`continue-on-error: true`. The pre-deploy smoke used two of them
(`continue-on-error`, plus `|| echo` split across a line continuation), so a
broken production database never blocked a release.

Shell lines continued with a trailing backslash are joined before checking.
A line that really needs one of these must say so explicitly with a
`# ci-guard: allow <reason>` comment on that line.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Iterator

ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS_DIR = ROOT / ".github" / "workflows"

ALLOW_MARKER = "ci-guard: allow"

FORBIDDEN_PATTERNS = [
    (re.compile(r"\|\|\s*true\b"), "'|| true' hides a failing command"),
    (re.compile(r"\|\|\s*echo\b"), "'|| echo' turns a failure into a log line"),
    (re.compile(r"\|\|\s*exit\s+0\b"), "'|| exit 0' turns a failure into success"),
    (
        re.compile(r"^\s*continue-on-error:\s*true\b"),
        "'continue-on-error: true' lets a failing step pass the job",
    ),
]


def logical_lines(text: str) -> Iterator[tuple[int, str]]:
    """Yields (first line number, line) with backslash continuations joined."""
    lines = text.splitlines()
    index = 0
    while index < len(lines):
        start = index
        current = lines[index]
        while current.rstrip().endswith("\\") and index + 1 < len(lines):
            index += 1
            current = current.rstrip()[:-1] + " " + lines[index].strip()
        yield start + 1, current
        index += 1


def main() -> int:
    findings: list[str] = []

    if WORKFLOWS_DIR.exists():
        paths = sorted(WORKFLOWS_DIR.glob("*.yml")) + sorted(WORKFLOWS_DIR.glob("*.yaml"))
        for path in paths:
            text = path.read_text(encoding="utf-8", errors="ignore")
            for line_number, line in logical_lines(text):
                low = line.lower()
                if ALLOW_MARKER in low:
                    continue
                for pattern, reason in FORBIDDEN_PATTERNS:
                    if pattern.search(low):
                        rel = path.relative_to(ROOT)
                        findings.append(f"{rel}:{line_number}: forbidden fail-open pattern: {reason}")

    if findings:
        print("CI guard failed:\n")
        for f in findings:
            print(f"- {f}")
        print(
            "\nRemove the bypass so the check stays strict, or add "
            f"'# {ALLOW_MARKER} <reason>' on that line if it is really intended."
        )
        return 1

    print("CI guard passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
