"""Regenerate the SQL quality gate baseline from current findings.

Run this ONLY after you have intentionally paid down SQL debt (e.g. added
`SET search_path` to a batch of SECURITY DEFINER functions), then review the
diff before committing. It imports the gate module so the emitted keys EXACTLY
match what the gate compares against (Finding.key()). Only currently-detected
findings are captured; brand-new findings introduced later will still fail CI.

Usage:
    python scripts/regen_sql_baseline.py
"""
import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "gate", ROOT / "scripts" / "sql_quality_gate.py"
)
gate = importlib.util.module_from_spec(spec)
# Register before exec so @dataclass can resolve the module (Python 3.12+).
sys.modules["gate"] = gate
spec.loader.exec_module(gate)

all_sql = sorted(gate.iter_sql_files(ROOT / "supabase")) + sorted(
    gate.iter_sql_files(ROOT / "database")
)
migration_sql = [p for p in all_sql if gate.is_in_migration_dirs(p)]

findings = []
findings.extend(gate.check_sql_drift(all_sql))
findings.extend(gate.check_security_definer_search_path(migration_sql))
findings.extend(gate.check_permissive_rls(migration_sql))
findings.extend(gate.check_disabled_rls(migration_sql))

keys = sorted({f.key() for f in findings})

header = [
    "# Baseline debt for SQL quality gate.",
    "# Each entry format: relative/path.sql|message",
    "#",
    "# These are PRE-EXISTING findings (mostly SECURITY DEFINER functions in",
    "# historical migrations that predate the `SET search_path` convention).",
    "# They are parked here so the gate blocks NEW regressions while we pay down",
    "# the legacy debt incrementally. DO NOT add new entries to silence fresh",
    "# findings — fix those in the migration instead.",
    "#",
    "# Regenerate (after intentionally paying down debt) with:",
    "#   python scripts/regen_sql_baseline.py   (then review the diff)",
]
out = "\n".join(header) + "\n" + "\n".join(keys) + "\n"
(ROOT / "scripts" / "sql_quality_gate_baseline.txt").write_text(out, encoding="utf-8")
print(f"Wrote {len(keys)} baseline entries.")
