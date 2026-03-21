#!/usr/bin/env python3
"""
Run post-deploy SQL smoke checks against a target Postgres database.

Usage:
  python scripts/prod_ops/run_post_deploy_smoke.py --db-url "$DATABASE_URL"
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SMOKE_SQL = ROOT / "scripts" / "prod_ops" / "post_deploy_smoke.sql"


def run_cmd(cmd: list[str]) -> None:
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        print(proc.stdout)
        print(proc.stderr)
        raise SystemExit(proc.returncode)
    print(proc.stdout)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--db-url", required=True, help="Postgres connection URL")
    args = parser.parse_args()

    cmd = [
        "psql",
        args.db_url,
        "-v",
        "ON_ERROR_STOP=1",
        "-f",
        str(SMOKE_SQL),
    ]

    run_cmd(cmd)
    print("Post-deploy smoke checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
