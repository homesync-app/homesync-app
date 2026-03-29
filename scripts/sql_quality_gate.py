#!/usr/bin/env python3
"""
SQL Quality Gate for HomeSync.

Fails CI when risky SQL patterns are detected, with focus on:
- SQL drift outside canonical migration folders
- SECURITY DEFINER functions without explicit SET search_path
- Overly permissive RLS policies on sensitive tables
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
BASELINE_PATH = ROOT / "scripts" / "sql_quality_gate_baseline.txt"
MIGRATION_DIRS = [
    ROOT / "supabase" / "migrations",
    ROOT / "database" / "migrations",
]
SENSITIVE_TABLES = {
    "expenses",
    "expense_splits",
    "households",
    "household_members",
    "application_logs",
    "notifications",
    "tasks",
    "planned_expenses",
    "expense_templates",
}

FUNC_CREATE_RE = re.compile(
    r"create\s+or\s+replace\s+function\s+public\.[a-zA-Z0-9_]+\s*\(",
    re.IGNORECASE,
)
SECURITY_DEFINER_WITHOUT_SEARCH_PATH_RE = re.compile(
    r"create\s+or\s+replace\s+function\s+public\.[a-zA-Z0-9_]+\s*\([^;]*?"
    r"security\s+definer"
    r"(?![^;]*?set\s+search_path)",
    re.IGNORECASE | re.DOTALL,
)
POLICY_BLOCK_RE = re.compile(
    r"create\s+policy\s+\"(?P<name>[^\"]+)\"\s+on\s+public\.(?P<table>[a-zA-Z0-9_]+)"
    r"(?P<body>.*?);",
    re.IGNORECASE | re.DOTALL,
)


@dataclass
class Finding:
    path: Path
    line: int
    message: str

    def render(self) -> str:
        rel = self.path.relative_to(ROOT)
        return f"{rel}:{self.line}: {self.message}"

    def key(self) -> str:
        rel = self.path.relative_to(ROOT).as_posix()
        return f"{rel}|{self.message}"


def iter_sql_files(base: Path) -> Iterable[Path]:
    if not base.exists():
        return []
    return sorted(p for p in base.rglob("*.sql") if p.is_file())


def is_in_migration_dirs(path: Path) -> bool:
    resolved = path.resolve()
    return any(str(resolved).startswith(str(m.resolve())) for m in MIGRATION_DIRS if m.exists())


def line_of_offset(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def check_sql_drift(files: Iterable[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        if is_in_migration_dirs(path):
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in FUNC_CREATE_RE.finditer(text):
            findings.append(
                Finding(
                    path=path,
                    line=line_of_offset(text, match.start()),
                    message=(
                        "Function definition outside migration folders. "
                        "Move SQL changes to supabase/migrations or database/migrations."
                    ),
                )
            )
    return findings


def check_security_definer_search_path(files: Iterable[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in SECURITY_DEFINER_WITHOUT_SEARCH_PATH_RE.finditer(text):
            findings.append(
                Finding(
                    path=path,
                    line=line_of_offset(text, match.start()),
                    message="SECURITY DEFINER function without SET search_path in function definition.",
                )
            )
    return findings


def check_permissive_rls(files: Iterable[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in POLICY_BLOCK_RE.finditer(text):
            table = match.group("table").lower()
            if table not in SENSITIVE_TABLES:
                continue

            body = match.group("body")
            low = body.lower()
            cmd_all = " for all" in low
            cmd_delete = " for delete" in low
            cmd_update = " for update" in low
            cmd_insert = " for insert" in low

            permissive_using = bool(re.search(r"using\s*\(\s*true\s*\)", low))
            permissive_check = bool(re.search(r"with\s+check\s*\(\s*true\s*\)", low))

            risky = (
                (cmd_all and (permissive_using or permissive_check))
                or ((cmd_delete or cmd_update) and permissive_using)
                or ((cmd_insert or cmd_update or cmd_all) and permissive_check)
            )

            if risky:
                findings.append(
                    Finding(
                        path=path,
                        line=line_of_offset(text, match.start()),
                        message=(
                            f"Potentially over-permissive RLS policy '{match.group('name')}' "
                            f"on sensitive table public.{table}."
                        ),
                    )
                )
    return findings


def main() -> int:
    all_sql_files = sorted(iter_sql_files(ROOT / "supabase")) + sorted(iter_sql_files(ROOT / "database"))
    migration_sql_files = [p for p in all_sql_files if is_in_migration_dirs(p)]

    findings: list[Finding] = []
    findings.extend(check_sql_drift(all_sql_files))
    findings.extend(check_security_definer_search_path(migration_sql_files))
    findings.extend(check_permissive_rls(migration_sql_files))

    baseline: set[str] = set()
    if BASELINE_PATH.exists():
        for line in BASELINE_PATH.read_text(encoding="utf-8", errors="ignore").splitlines():
            cleaned = line.strip()
            if cleaned and not cleaned.startswith("#"):
                baseline.add(cleaned)

    new_findings = [f for f in findings if f.key() not in baseline]

    if new_findings:
        print("SQL quality gate failed with findings:\n")
        for f in new_findings:
            print(f"- {f.render()}")
        print("\nFix the findings or explicitly refactor migrations before merging.")
        return 1

    if findings and baseline:
        print(
            f"SQL quality gate passed with baseline debt: {len(findings)} "
            f"total findings, {len(new_findings)} new."
        )
    else:
        print("SQL quality gate passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
