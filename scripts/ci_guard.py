#!/usr/bin/env python3
"""
CI guardrails to avoid fail-open quality checks.

Fails when workflow scripts contain shell bypass patterns like `|| true`.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS_DIR = ROOT / ".github" / "workflows"

FORBIDDEN_PATTERNS = [
    "|| true",
]


def main() -> int:
    findings: list[str] = []

    if WORKFLOWS_DIR.exists():
      for path in sorted(WORKFLOWS_DIR.glob("*.yml")):
          text = path.read_text(encoding="utf-8", errors="ignore")
          for idx, line in enumerate(text.splitlines(), start=1):
              low = line.lower()
              for pattern in FORBIDDEN_PATTERNS:
                  if pattern in low:
                      rel = path.relative_to(ROOT)
                      findings.append(f"{rel}:{idx}: forbidden workflow bypass pattern '{pattern}'")

    if findings:
        print("CI guard failed:\n")
        for f in findings:
            print(f"- {f}")
        print("\nRemove bypass patterns to keep checks strict.")
        return 1

    print("CI guard passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
