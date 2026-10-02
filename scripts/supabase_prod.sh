#!/bin/bash
# Corre la CLI de Supabase contra producción con las credenciales de
# supabase/.env.claude (gitignoreado), sin tener que exportarlas a mano.
#   bash scripts/supabase_prod.sh db push --dry-run
#   bash scripts/supabase_prod.sh db push
#   bash scripts/supabase_prod.sh functions deploy growth-mcp --no-verify-jwt
#   bash scripts/supabase_prod.sh secrets set NOMBRE=valor
set -euo pipefail
cd "$(dirname "$0")/../supabase"
set -a
. <(grep -v '^#' .env.claude | tr -d '\r')
set +a
case "${1:-}" in
  db) exec supabase "$@" --db-url "$SUPABASE_DB_URL" ;;
  *) exec supabase "$@" --project-ref tfavamqszdkoeabpyxms ;;
esac
