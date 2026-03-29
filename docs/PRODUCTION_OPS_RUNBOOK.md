# Production Ops Runbook

This runbook is designed for AI-driven execution and fail-fast automation.

## 1) Pre-deploy backup

PowerShell:

```powershell
pwsh ./scripts/prod_ops/backup_prod.ps1 -DbUrl $env:PROD_DATABASE_URL
```

Output:
- `backups/homesync_prod_YYYYMMDD_HHMMSS.dump`

## 2) Deploy migrations/app

Use your normal deployment path. The production deploy workflow now includes a mandatory pre-deploy-smoke gate (DB smoke + quality guards) before publishing.

## 3) Post-deploy smoke checks

Local:

```bash
python scripts/prod_ops/run_post_deploy_smoke.py --db-url "$PROD_DATABASE_URL"
```

CI (manual):
- Run workflow: `.github/workflows/prod_post_deploy_smoke.yml`
- Requires GitHub secret: `PROD_DATABASE_URL`

## 4) Rollback (if smoke fails)

```powershell
pwsh ./scripts/prod_ops/rollback_from_backup.ps1 -DbUrl $env:PROD_DATABASE_URL -BackupFile "backups/<file>.dump"
```

Then rerun smoke checks.

## Notes

- `pg_net` extension warning cannot be auto-fixed with SQL because `pg_net` does not support `ALTER EXTENSION ... SET SCHEMA`.
- Leaked password protection must be enabled in Supabase Auth settings (Dashboard), not via SQL migrations.
