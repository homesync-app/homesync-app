# HomeSync — Guía para agentes IA

## Stack

- **Frontend**: Flutter 3.47.5 / Dart 3.13 con Riverpod 3.x. CI (`tests.yml`) y el deploy (`deploy-production.yml`, `shorebird release --flutter-version=3.47.5`) fijan la misma versión: para subir Flutter, cambiar los dos workflows juntos y confirmar que Shorebird la soporta.
- **Backend**: Supabase (Postgres + Edge Functions + Storage + Realtime)
- **Auth**: Firebase Auth (Google + email/password) → Supabase Third-Party Auth (JWT de Firebase como access token de Supabase)
- **OCR**: Edge Function `scan-receipt` → Gemini 3.1 Flash-Lite (migrado desde 2.5 Flash, deprecado 17-jun-2026). Usa structured output (`responseSchema`) y `thinkingLevel` (serie 3.x; NO `thinkingBudget`).

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

## Flujo Git

- **`main`**: version estable / produccion.
- **`develop`**: integracion y pruebas. Es la base normal para cambios de trabajo.
- **`origin/main`**: respaldo remoto de `main` en GitHub.
- **`origin/develop`**: respaldo remoto de `develop` en GitHub.
- Para cambios medianos o grandes, crear ramas temporales desde `develop` con prefijo `codex/` y luego integrarlas a `develop`.
- No trabajar directo sobre `main` salvo cambios muy puntuales y confirmados por el usuario.
- Antes de tocar archivos, verificar y reportar `pwd`, `git branch --show-current` y `git status -sb`.
- No borrar worktrees o ramas de agentes (`.codex`, `.claude`, `C:\hs_worktrees`) si tienen cambios sin guardar o si el usuario esta trabajando con otro agente.

## Diseño

- Antes de tocar UI, leer `DESIGN.md` y `docs/design-system.md`.
- `DESIGN.md` sigue el formato de `google-labs-code/design.md`: tokens YAML validables + criterio visual en Markdown.
- Validar cambios de tokens con `npx @google/design.md lint DESIGN.md` o, en Windows si `npx` se cuelga, con el bin `design.md` instalado localmente.

## Distribución / OTA updates (Shorebird)

Shorebird está instalado y configurado (`flutter_client/shorebird.yaml`, app_id: `3da773b5-655d-47c6-8277-5d90b3417d86`).

> **⚠️ Regla de oro (de acá en adelante):** los releases hay que hacerlos **siempre** con `shorebird release android` (NO `flutter build appbundle`). Ese es el único que queda "parcheable" — un `.aab` hecho con `flutter build appbundle` NO lleva el updater de Shorebird adentro y nunca podrá recibir patches OTA. De ahí en más, cambios de Dart/assets (íconos, copy, lógica, UI) van por `shorebird patch android` = OTA, sin tocar la Play Store.

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
- **Strings UI**: bilingüe **es / en-US** vía ARB (`flutter_localizations`). Ver sección [i18n / Localización](#i18n--localización). El idioma fuente es **español argentino** (`app_es.arb`); `en-US` se mantiene a partir de él.
- **State management**: Riverpod con `@riverpod` annotation
- **Auth**: Firebase Auth → JWT → Supabase `accessToken` callback. NUNCA `supabase.auth.signIn()`
- **Current user ID**: usar `currentUserIdProvider` (Firebase UID → Supabase UUID via `AppIdentityService`), NO `auth.uid()` en SQL
- **SQL**: usar `current_app_user_id()` (maneja Firebase JWTs)
- **Storage policies**: usar `current_app_user_id()` no `auth.uid()`
- **Edge Functions**: verificar Firebase JWT con `jose` + `createRemoteJWKSet`
- **Updates en tabla users**: SIEMPRE usar RPC security-definer (`update_own_profile`). RLS directo falla con Firebase JWTs

## Supabase / Seguridad

Antes de aplicar migraciones que cambien RLS, policies, grants, `SECURITY DEFINER`,
`search_path`, permisos de storage o ejecucion de funciones, correr smoke tests de
RPC criticos y dejar evidencia en el resumen del cambio. Checklist minimo:

- Completar una tarea normal.
- Completar una tarea recurrente.
- Aprobar/verificar una tarea pendiente.
- Enviar feedback desde la app.
- Crear/usar una solicitud del catalogo de shopping.
- Cargar el feed de finanzas.

Si una migracion crea o reemplaza un RPC usado por otros RPCs, verificar que todas
sus dependencias existan en la base remota antes de tocar grants globales. Un error
`function ... does not exist` indica drift de migraciones o una dependencia faltante;
un error `permission denied for function` indica grants/permisos.

## Credenciales Supabase para agentes

- El token de acceso vive en `supabase/.env.claude` (gitignored). Antes de usar la CLI de Supabase
  o la Management API, leer ese archivo y exportar `SUPABASE_ACCESS_TOKEN` (y `SUPABASE_DB_URL` si
  hay que correr SQL directo). No pedir al usuario que genere tokens nuevos: el token es fijo.
- Ejemplo (bash): `export $(grep -v '^#' supabase/.env.claude | xargs)`
- La contraseña de la base se rotó el 2026-09-26: la vigente está solo en `SUPABASE_DB_URL` de
  `supabase/.env.claude` y en el secret `PROD_DATABASE_URL` de GitHub. Si se vuelve a rotar,
  actualizar los dos.
- Credenciales QA (cuenta admin base, cuentas `qa.*@homesync.local`, gate del panel admin): solo
  en `flutter_client/.env.local` (gitignored). `.env.example` lista las claves sin valores. Nunca
  commitearlas en scripts, docs ni defaults de código.
- Los sign-ups nativos de Supabase están desactivados (`disable_signup=true`): el alta real pasa
  por Firebase. Las cuentas QA solo inician sesión.
- `.github/workflows/supabase-keepalive.yml` consulta PostgREST cada 3 días para que el plan Free
  no pause el proyecto. GitHub apaga los workflows programados tras 60 días sin commits: si pasa,
  reactivarlo desde Actions.

## Proyecto

- **Supabase ref**: `tfavamqszdkoeabpyxms`
- **Firebase**: `homesync-prod-r7-123`
- **Package**: `com.blas.homesync` (applicationId real en `android/app/build.gradle.kts`)

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

## i18n / Localización

Setup oficial **`flutter_localizations` + ARB** (recomendación 2026 para apps medianas/grandes), con **`arb_translate`** como dev_dependency para regenerar el `app_en.arb` a partir del fuente `app_es.arb`.

### Layout

```
flutter_client/
  l10n.yaml                          # config de gen-l10n
  lib/l10n/
    app_es.arb                       # FUENTE — único editado a mano
    app_en.arb                       # traducción en-US (revisada feature-by-feature)
    generated/
      app_localizations.dart         # autogenerado — NO commitear edits manuales
      app_localizations_es.dart
      app_localizations_en.dart
```

### Cómo agregar un string

1. Agregar la clave en `app_es.arb` con su `@key.description` (esa descripción es contexto para la IA y para traductores futuros).
2. Agregar la traducción equivalente en `app_en.arb` **a mano la primera vez** (la primera pasada de cada feature debe ser revisada por humano para preservar tono y jerga del dominio: "modo padre" → "Parent Mode", "hogar" → "Household", etc.).
3. Correr `flutter gen-l10n` (también lo dispara `flutter pub get` y `flutter run`).
4. Usar en widgets: `AppLocalizations.of(context).miClave`. Convención local: aliasarlo como `final t = AppLocalizations.of(context);` y usar `t.miClave`.

### Mantenimiento masivo con `arb_translate` (Gemini / OpenAI)

Para keys nuevas que aún no están en `app_en.arb`, o cuando se incorpora un tercer idioma:

```bash
cd flutter_client
export ARB_TRANSLATE_API_KEY=...                # Gemini por default
# o: arb-translate-model-provider: open-ai en l10n.yaml + key de OpenAI
dart run arb_translate
```

`arb_translate` lee el ARB fuente (`app_es.arb`), detecta keys faltantes en los demás `app_<locale>.arb`, traduce respetando ICU (plurales, placeholders) y escribe el resultado. **Siempre revisar el diff en PR** — la IA acierta mucho pero la jerga del dominio (parent mode, household, family finance) merece chequeo humano.

### Selector de idioma

- Provider: `localeProvider` en `lib/core/providers/locale_provider.dart` (`Notifier<Locale?>`, `null` = seguir el sistema).
- UI: `SettingsLanguageCard` en la pantalla de Settings — opciones System / Español / Inglés.
- Persistencia: `SharedPreferences` key `app_locale` (`'es'`, `'en'`, o ausente).
- En primer arranque sin preferencia, `MaterialApp` resuelve el mejor locale soportado a partir del SO.

### Reglas

- **No hardcodear strings UI nuevos** — siempre vía ARB. Excepción: nombres propios (HomeSync) y datos del backend.
- **No editar `lib/l10n/generated/`** a mano. Se regenera con `flutter gen-l10n`.
- **Argentino voseo en el fuente `es`** (elegí, contá, querés), **en-US neutro** en `en`.
- Para plurales/género usar ICU MessageFormat dentro del ARB (`{count, plural, =0{...} one{...} other{...}}`).

## Gotchas

- Avatar puede ser: emoji (1-2 runes), URL http, `premium://id`, o null
- `_prefillIdentityFromAuth` solo pre-llena nombre para Google sign-in
- `ensure_user_profile` usa `coalesce` — no sobreescribe datos existentes con nulls
- Tipos de hogar: `couple` (max 2, código single-use), `family`/`friends` (sin límite, código multi-use)
- Admin testing solo cuando `APP_ENV != production` Y `ENABLE_ADMIN_TESTING=true`
- Plata: siempre `currencyProvider` (`AppCurrency.format` / `formatCompact`), nunca un `$` armado a
  mano. `intl` no trae datos de es_AR/es_CL/es_UY y caería en `12.500 $`; esas monedas usan
  `symbolFirst` para mostrar `$ 12.500`.
- Categorías guardadas como clave (`cocina`, `supermarket`…): mostrarlas con
  `localizedCategoryName` (`task_localization.dart`), no con `CategoryMapping.displayName`, que
  devuelve español fijo.
- La tab Progreso (`MainTab.stats` / `StatsScreen`) está oculta del bottom nav desde 115cf9e2
  (2026-04-04). Los providers de stats siguen en uso (ranking, resumen semanal, dashboards): no
  borrar la feature sin revisar esas dependencias.
- Install Referrer (`InstallReferrerService`): el código de invitación del link de Play precarga
  "Tengo un código" en el setup, una sola vez por instalación. Solo Android.
- Pedido de reseña (`ReviewPromptService`): tras dejar el balance en cero o a la décima tarea,
  con al menos 7 días de uso y 120 días entre pedidos. Play aplica su propia cuota encima.
