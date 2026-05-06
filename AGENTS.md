# HomeSync — Guía para agentes IA

## Stack

- **Frontend**: Flutter 3.41+ / Dart 3.11+ con Riverpod 2.x
- **Backend**: Supabase (Postgres + Edge Functions + Storage + Realtime)
- **Auth**: Firebase Auth (Google + email/password) → Supabase Third-Party Auth (JWT de Firebase como access token de Supabase)
- **OCR**: Edge Function `scan-receipt` → Gemini 2.5 Flash

## Estructura

```
flutter_client/lib/
  config/           # AppEnvironment, constantes
  core/
    providers/       # Riverpod providers compartidos
    services/        # Servicios (auth, RPC, storage, etc.)
    theme/           # AppTheme, colores, category_mapping
    utils/           # Helpers (receipt_matcher, validators)
  features/
    <feature>/
      data/          # Repositories (Supabase)
      domain/        # Models, repository interfaces
      presentation/
        providers/   # Feature-scoped providers
        screens/     # Pantallas
        widgets/     # Componentes reutilizables
supabase/
  migrations/        # 72+ migraciones SQL (orden cronológico)
  functions/         # Edge Functions (Deno/TypeScript)
```

## Comandos

```bash
flutter test                                          # Tests
cd flutter_client && flutter build apk --debug         # Build debug
.\scripts\run_device.bat                               # Run en dispositivo
cd supabase && supabase functions deploy <name> --project-ref tfavamqszdkoeabpyxms
```

## Distribución / OTA updates (Shorebird)

Shorebird está instalado y configurado (`flutter_client/shorebird.yaml`, app_id: `3da773b5-655d-47c6-8277-5d90b3417d86`).

- **Nueva release** (cuando haya cambios nativos o nueva versión en Play Store):
  ```bash
  cd flutter_client && shorebird release android
  ```
- **Patch OTA** (fix de código Dart sin pasar por Play Store — llega a usuarios automáticamente):
  ```bash
  cd flutter_client && shorebird patch android
  ```

**Regla**: si el cambio es solo Dart (lógica, UI, providers), preferir `shorebird patch` en vez de subir una release completa. Solo hacer release completa si hay cambios en código nativo, permisos, assets o dependencias con código nativo.

## Convenciones (OBLIGATORIO)

- **Código**: nombres en inglés (`expenses`, `household`, `settings`)
- **Strings UI**: en español (argentino)
- **State management**: Riverpod con `@riverpod` annotation
- **Auth**: Firebase Auth → JWT → Supabase `accessToken` callback. NUNCA `supabase.auth.signIn()`
- **Current user ID**: usar `currentUserIdProvider` (Firebase UID → Supabase UUID via `AppIdentityService`), NO `auth.uid()` en SQL
- **SQL**: usar `current_app_user_id()` (maneja Firebase JWTs)
- **Storage policies**: usar `current_app_user_id()` no `auth.uid()`
- **Edge Functions**: verificar Firebase JWT con `jose` + `createRemoteJWKSet`
- **Updates en tabla users**: SIEMPRE usar RPC security-definer (`update_own_profile`). RLS directo falla con Firebase JWTs

## Proyecto

- **Supabase ref**: `tfavamqszdkoeabpyxms`
- **Firebase**: `homesync-prod-r7-123`
- **Package**: `com.homesync.app`

## Reglas de contexto

- **NO LEER** `docs/archive/` salvo que se pida explícitamente
- **NO LEER** god files enteros. Usar grep/offset para encontrar la sección relevante. Archivos grandes:
  - `setup_screen.dart` (~2243 LOC) — wizard steps con estado compartido
  - `expenses_screen.dart` (~1834 LOC) — tab Movimientos + helpers
  - `home_family_view.dart` (~1051 LOC) — dashboard shell
  - `expense_form_sheet.dart` (~1523 LOC) — formulario de gastos
- Para tareas recurrentes, seguir el playbook correspondiente en `docs/playbooks/`
- Schema de la BD: `docs/schema.md`
- Provider map: `docs/provider-map.md`

## Gotchas

- Avatar puede ser: emoji (1-2 runes), URL http, `premium://id`, o null
- `_prefillIdentityFromAuth` solo pre-llena nombre para Google sign-in
- `ensure_user_profile` usa `coalesce` — no sobreescribe datos existentes con nulls
- Tipos de hogar: `couple` (max 2, código single-use), `family`/`friends` (sin límite, código multi-use)
- Admin testing solo cuando `APP_ENV != production` Y `ENABLE_ADMIN_TESTING=true`
