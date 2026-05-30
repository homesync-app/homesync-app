# HomeSync — Guía de Testing

> Esta guía reemplaza una versión anterior que describía una API REST con
> `/auth/login`, `/auth/refresh`, idempotency-keys HTTP y un rate limiter de
> 60 req/min. **Esa arquitectura ya no existe.** HomeSync usa Firebase Auth →
> JWT → Supabase (ver `AGENTS.md`). Lo de abajo refleja la suite real.

## Arquitectura de tests

| Capa | Carpeta | Backend real | Corre en CI |
|------|---------|--------------|-------------|
| Unit / lógica de dominio | `test/*.dart` | No (fakes / `ProviderContainer`) | Sí |
| Widget | `test/*_test.dart` (login, navegación) | No | Sí |
| Guards de calidad | `test/text_encoding_guard_test.dart`, `test/l10n_parity_test.dart` | No | Sí |
| Edge Functions (Deno) | `supabase/functions/**/*.test.ts` | No (lógica pura) | Sí (`edge_functions.yml`) |
| Integration / E2E | `integration_test/*.dart` | Sí | No (manual / on-demand) |
| Smoke SQL post-deploy | `scripts/prod_ops/post_deploy_smoke.sql` | Sí (Postgres) | Manual (`workflow_dispatch`) |

## Comandos

```bash
# Toda la suite unit + widget + guards (lo que corre el CI)
cd flutter_client
flutter test

# Un archivo puntual
flutter test test/domain_models_test.dart

# Con cobertura (como el CI)
flutter test --coverage

# Análisis estático (el CI usa --no-fatal-infos --no-fatal-warnings)
flutter analyze
```

### Edge Functions (Deno)

```bash
cd supabase/functions
deno test --no-check=remote scan-receipt/parser.test.ts
deno lint scan-receipt/parser.ts
```

### Integration tests (backend real)

Estos tests pegan contra un backend real, así que necesitan una **cuenta de
prueba descartable**. Las credenciales se inyectan por `--dart-define` y nunca
viven en el repo. Si no se pasan, el test se **salta** (no pasa en falso).

```bash
cd flutter_client
flutter test integration_test/auth_smoke_test.dart \
  --dart-define=E2E_EMAIL=tu-cuenta-de-prueba@example.com \
  --dart-define=E2E_PASSWORD=••••••
```

Lo mismo para `app_e2e_test.dart` y `staging_e2e_test.dart`.

> Nota: el grupo "Offline queue" de `staging_e2e_test.dart` es lógica local
> (sqflite) y corre **sin** credenciales.

## Smoke SQL post-deploy

Tras una migración que toque RLS, policies, grants, `SECURITY DEFINER`,
`search_path` o permisos de storage, correr el smoke (checklist de `AGENTS.md`):

```bash
python scripts/prod_ops/run_post_deploy_smoke.py --db-url "$DATABASE_URL"
```

Verifica (fail-fast) que existan los RPCs críticos (`complete_task_v1`,
`approve_task_v1`, `get_combined_feed`, `save_expense_v4`,
`upsert_catalog_request`, `join_household_by_code`), que `anon` **no** pueda
ejecutar los RPCs de mutación, y que RLS siga habilitado en todas las tablas
sensibles.

## Gates automáticos en CI (`.github/workflows/tests.yml`)

1. `scripts/sql_quality_gate.py` — detecta drift de SQL, `SECURITY DEFINER` sin
   `search_path`, RLS deshabilitada de forma colgante y policies permisivas.
2. `scripts/ci_guard.py` — prohíbe patrones de bypass (`|| true`) en workflows.
3. `flutter test --coverage`
4. `flutter analyze`
5. Build APK debug (validación)

## Convenciones de testing

- **No tests tautológicos.** Un test debe importar y ejercitar código de `lib/`,
  nunca reimplementar la lógica dentro del propio test (ese fue el problema del
  viejo `backend_integration_test.dart`, hoy reemplazado por
  `domain_models_test.dart`).
- **Sin escape hatches que pasen en falso.** Evitar `if (finder.isNotEmpty)`
  envolviendo aserciones: si lo esperado no está, el test debe **fallar** (o
  saltarse explícitamente con `markTestSkipped`).
- **Strings UI** se prueban sin hardcodear: ver `l10n_parity_test.dart`.
- **Credenciales** siempre por `--dart-define`, nunca en el código.
