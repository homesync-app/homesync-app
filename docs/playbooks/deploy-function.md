# Playbook: Deploy Edge Function

## Archivos clave

- `supabase/functions/` — Edge Functions (Deno/TypeScript)
- `docs/PRODUCTION_OPS_RUNBOOK.md` — runbook de producción
- `docs/SQL_QUALITY_GATE.md` — quality gate para SQL en migraciones

## Pasos

1. **Desarrollar**: editar en `supabase/functions/<name>/index.ts`
2. **Auth**: verificar Firebase JWT con `jose` + `createRemoteJWKSet`, NO con `supabase.auth.getUser()`
3. **Deploy**:
   ```bash
   cd supabase && supabase functions deploy <name> --project-ref tfavamqszdkoeabpyxms
   ```
4. **Si incluye migraciones SQL**: aplicar via Supabase dashboard o `supabase db push`
5. **Si incluye cambios en tabla users**: usar RPC `update_own_profile`, NO RLS directo

## Reglas

- NO hardcodear IDs en data migrations
- Verificar que la función maneja errores y retorna status codes correctos
- Revisar `docs/archive/TECH_DEBT_FIREBASE_THIRD_PARTY_AUTH.md` para el patrón correcto de auth en Edge Functions
