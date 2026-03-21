# SQL Quality Gate

This repository uses `scripts/sql_quality_gate.py` in CI to prevent SQL regressions.
It also uses `scripts/ci_guard.py` to prevent fail-open CI patterns.

## What it checks

1. SQL drift:
- Fails when function definitions are added outside migration folders:
  - `supabase/migrations/`
  - `database/migrations/`

2. `SECURITY DEFINER` without explicit `SET search_path`:
- Fails when migration SQL defines `SECURITY DEFINER` functions without `SET search_path`.

3. Overly permissive RLS in sensitive tables:
- Fails for risky patterns like `USING (true)` / `WITH CHECK (true)` on write policies.

## Baseline mode

Current historical debt is tracked in:
- `scripts/sql_quality_gate_baseline.txt`

CI fails only on **new findings** not present in baseline.

## CI Guard

`scripts/ci_guard.py` fails when workflow files contain bypass patterns (for example `|| true`) that can silently hide failures.

## How to reduce baseline safely

1. Fix one historical finding in migration/source.
2. Remove its corresponding line from `scripts/sql_quality_gate_baseline.txt`.
3. Run locally:

```bash
python scripts/sql_quality_gate.py
```

4. Commit both the fix and baseline update together.

See also: docs/PRODUCTION_OPS_RUNBOOK.md
