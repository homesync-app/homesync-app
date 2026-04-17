# HomeSync — Guia para agentes IA

## Stack

- **Frontend**: Flutter 3.41+ / Dart 3.11+ con Riverpod 2.x
- **Backend**: Supabase (Postgres + Edge Functions + Storage + Realtime)
- **Auth**: Firebase Auth (Google + email/password) → Supabase Third-Party Auth (JWT de Firebase como access token de Supabase)
- **Analytics/Crashlytics**: Firebase Analytics + Crashlytics
- **Notifications**: Firebase Cloud Messaging
- **OCR**: Edge Function `scan-receipt` → Gemini 2.5 Flash
- **CI**: GitHub Actions (`.github/workflows/`)

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
  migrations/        # 62+ migraciones SQL (orden cronologico)
  functions/         # Edge Functions (Deno/TypeScript)
    scan-receipt/
    send-notification/
    cleanup-old-receipts/
```

## Comandos

```bash
# Run en dispositivo fisico
.\scripts\run_device.bat

# Build APK debug
cd flutter_client && flutter build apk --debug

# Build release (para Play Store)
cd flutter_client && flutter build appbundle --release \
  --dart-define=APP_ENV=production \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key>

# Deploy Edge Function
cd supabase && supabase functions deploy <name> --project-ref tfavamqszdkoeabpyxms

# Tests
cd flutter_client && flutter test
```

## Convenciones

- **Codigo**: nombres en ingles (`expenses`, `household`, `settings`)
- **Strings UI**: en espanol (argentino)
- **State management**: Riverpod con `@riverpod` annotation cuando sea posible
- **Auth flow**: Firebase Auth → JWT → Supabase `accessToken` callback. NUNCA usar `supabase.auth.signIn()` directamente
- **Current user ID**: usar `currentUserIdProvider` (resuelve Firebase UID → Supabase UUID via `AppIdentityService`), NO `auth.uid()` en SQL
- **SQL**: usar `current_app_user_id()` en funciones/migraciones (maneja Firebase JWTs)
- **Storage**: policies deben usar `current_app_user_id()` no `auth.uid()` (esta ultima crashea con Firebase UIDs)
- **Edge Functions**: verificar Firebase JWT con `jose` + `createRemoteJWKSet`, NO con `supabase.auth.getUser()`

## Proyecto Supabase

- **Project ref**: `tfavamqszdkoeabpyxms`
- **Firebase project**: `homesync-prod-r7-123`
- **Package name**: `com.homesync.app`
- Un solo proyecto Supabase para staging + produccion (diferenciar por `APP_ENV`)

## Archivos grandes (god files)

Evitar editar estos archivos enteros — usar offset/limit al leer:
- `setup_screen.dart` (~4650 LOC)
- `expenses_screen.dart` (~2600 LOC)
- `home_family_view.dart` (~2250 LOC)
- `expense_form_sheet.dart` (~1500 LOC)

## Admin Testing

Solo activo cuando `APP_ENV != production` Y `ENABLE_ADMIN_TESTING=true`. En produccion, `enableAdminTesting` siempre retorna `false`.
