# 🔐 HomeSync — Auditoría de Seguridad Pre-Lanzamiento

> **Fecha:** 2026-06-03 · **Versión app:** 1.2.0+77 · **Ventana:** 14 días a producción
> **Alcance:** Supabase (prod `tfavamqszdkoeabpyxms`) + cliente Flutter (`flutter_client/`) + admin (`homesync_admin/`) + release/CI + cumplimiento Play 2026
> **Estado general:** 🟢 Listo para release. Fundamentos sólidos (RLS 100%, sin secretos privados filtrados). Una migración de hardening (`20260603120000`) lista; el resto son toggles P1 no bloqueantes.
>
> **Nota metodológica:** este documento fue reconciliado entre 3 análisis (linter de Supabase + 2 IAs) y **verificado contra la DB viva** el 2026-06-03 (privilegios reales, cuerpos de funciones, definición de vista, policies, historial de migraciones). Donde hubo desacuerdo, manda lo que dice la DB.

---

## 0. Resumen ejecutivo

| Área | Estado | Bloquea launch |
|------|--------|----------------|
| RLS en tablas | ✅ 47/47 habilitado | No |
| Funciones RPC ejecutables por `anon` | 🟢 4, pero **no explotables** (guard interno) | No |
| Vista `v_shopping_items_usage` legible por `anon` | 🟢 Agregado anónimo (sin PII) | No |
| Secretos hardcodeados | ✅ Solo keys públicas (anon/MP public/Firebase) | No |
| Firma / keystores | ✅ No trackeados en git | No |
| Obfuscación release | 🟡 No activada | Recomendado |
| Build de producción | ✅ Shorebird → `--release` | No |
| `minify` / `shrinkResources` Android | ✅ Activados | No |
| Storage de tokens en cliente | ✅ Maneja Firebase SDK, no SharedPreferences | No |
| Leaked password protection | 🟡 Desactivado | Recomendado |
| Firebase API key sin restringir | 🟡 Restringir en GCP | Recomendado |
| Backup de keystore | 🟡 Hacer fuera de máquina | Recomendado |
| Cumplimiento Data Safety 2026 | 🟡 Revisar declaraciones | Sí (para aprobación) |

**Conclusión:** ningún hallazgo es bloqueante de seguridad. La migración `20260603120000` es hygiene/defense-in-depth, no un fix crítico. El único "P0" real para el día del release es operativo: aplicar la migración con el `repair` previo (§4).

---

## 1. Backend / Supabase — hallazgos verificados en DB viva

### 1.1 ✅ RLS
- **47/47 tablas** del schema `public` con RLS habilitado. Ninguna expuesta.
- Postgres 17.6.1 (`ga`), `ACTIVE_HEALTHY`, us-east-1.

### 1.2 🟢 Funciones `SECURITY DEFINER` ejecutables por `anon` — NO explotables
El linter (lint 0028) marcó 4 funciones como ejecutables por `anon`. **Verificación en DB viva: es cierto** que `anon` puede ejecutarlas (`has_function_privilege('anon', …, 'EXECUTE') = true`), porque `GRANT EXECUTE TO authenticated` es *aditivo* y no quita el grant default a `PUBLIC`. **Pero no son explotables**: cada una tiene guard interno.

| Función | `anon` puede llamar | Protección verificada |
|---------|:---:|---|
| `pay_planned_expense(uuid,numeric,timestamptz,text)` | sí | `v_uid := current_app_user_id(); IF v_uid IS NULL THEN RETURN 'Not authenticated'` + check de membresía de hogar |
| `award_weekly_winner_for_week(uuid,date)` | sí | mismo patrón de guard |
| `get_weekly_ranking_for_week(uuid,date)` | sí | mismo patrón |
| `is_week_processed_for_week(uuid,date)` | sí | mismo patrón |

**Acción (P2, defense-in-depth):** revocar de `anon`/`PUBLIC` para no depender del cuerpo. Incluido en migración `20260603120000`.

> Las otras 112 funciones que el linter marca como ejecutables por `authenticated` son **ruido normal** — cualquier logueado puede llamar RPCs; la seguridad vive en la validación de hogar interna.

### 1.3 🟢 Vista `v_shopping_items_usage` legible por `anon` — bajo riesgo
**Verificado:** `anon_can_select = true`, `security_invoker = null`. El linter lo marcó como `security_definer_view`.

**Pero la vista expone solo agregado anónimo** (definición verificada):
`normalized_name`, `primary_name_key`, `primary_emoji`, `times_added` (count), `households_using` (count distinct), `last_added`, `variations`. **Cero `household_id`, cero `user_id`, cero PII.** Peor caso: alguien con la anon key ve qué productos son populares en general. No es fuga entre hogares.

**Consumidor único:** `homesync_admin/src/pages/ShoppingIcons.tsx` (verificado: ni el cliente Flutter ni edge functions ni otros objetos de DB la usan). El admin **hace login** (`signInWithPassword`) → consulta como `authenticated`, no `anon`.

**Acción (P1):** revocar de `anon` + `security_invoker = true`. Seguro porque:
- El admin es `authenticated`, no se ve afectado por el revoke de `anon`.
- Con `security_invoker`, el RLS de `shopping_items` aplica. Los 2 usuarios admin (`is_admin = true`, verificado) pasan `is_current_app_admin()` → policy permisiva `"admins can read shopping_items"` les da lectura total → el agregado cross-hogar se mantiene.

Incluido en migración `20260603120000`.

### 1.4 🟡 P1 — Leaked Password Protection desactivado
HaveIBeenPwned no activo. **Tarea:** Dashboard → Authentication → Policies → activar (1 click).

### 1.5 🟢 P2 — Otros (no bloqueantes)
- Extensión `pg_net` en `public` (mover a `extensions`).
- Performance: 30 FKs sin índice · 33 índices sin uso · 1 duplicado · 25 tablas con policies permisivas múltiples.
- `application_logs` con ~98.5k filas → definir retención (>30d) y verificar que no loguea PII.

---

## 2. La migración de hardening — `20260603120000_harden_pre_launch_security.sql`

📄 [`supabase/migrations/20260603120000_harden_pre_launch_security.sql`](../supabase/migrations/20260603120000_harden_pre_launch_security.sql)

Contenido (idempotente):
```sql
-- P1: vista (anon revoke + security_invoker)
REVOKE SELECT ON public.v_shopping_items_usage FROM anon;
ALTER VIEW public.v_shopping_items_usage SET (security_invoker = true);

-- P2: defense-in-depth de RPCs SECURITY DEFINER
REVOKE EXECUTE ON FUNCTION public.pay_planned_expense(uuid,numeric,timestamptz,text) FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.award_weekly_winner_for_week(uuid,date)            FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.get_weekly_ranking_for_week(uuid,date)             FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_week_processed_for_week(uuid,date)              FROM anon, PUBLIC;
```

### ⚠️ 2.1 GOTCHA al aplicar: `db push` arrastra una migración divergente
**Verificado en `supabase_migrations.schema_migrations`:**
- `20260601123504_revenuecat_private_table_deny_policies` (archivo local) → **NO aplicada** en prod.
- Su contenido **ya está vivo** bajo `20260601123531` (mismo nombre, distinto timestamp).
- El archivo local usa `CREATE POLICY` **pelado** (sin `DROP … IF EXISTS`).

Consecuencia: `supabase db push` aplica en orden de versión, así que tocaría `…123504` **antes** que `…120000` (3-jun) y **fallaría** con `ERROR: policy already exists`, **abortando el push sin aplicar el hardening**.

### 2.2 Secuencia de aplicación correcta (confirmada)
```powershell
cd "C:\Users\Blas_\Documents\Aplicacion de Pareja"

# 1. Marcar la divergente como aplicada SIN re-ejecutarla (su SQL ya vive en prod como 123531)
supabase migration repair --status applied 20260601123504

# 2. Confirmar que solo queda pendiente el hardening
supabase db push --dry-run     # → debe listar SOLO 20260603120000

# 3. Aplicar
supabase db push

# 4. Smoke test admin (ver §2.3)

# 5. Si pasa → commit en develop + merge a main
```

### 2.3 Smoke test que importa
El único consumidor que cambia es el admin (corre como `authenticated`). Test mínimo:
1. Login en admin con un user `is_admin = true`.
2. Abrir **ShoppingIcons**.
3. Verificar que la tabla renderiza con conteos **> los de tu propio hogar** (prueba que `security_invoker` + `is_current_app_admin()` funcionan juntos).

Si muestra solo tu hogar → falló la cadena, **no avances con el release**, revisar.

> **Proceso CI:** `deploy-production.yml` **no** aplica migraciones (solo buildea el AAB y lo sube a Play). Las migraciones se aplican **a mano** con `supabase db push`. Por eso el flujo manual de arriba es el correcto y no saltea ningún pipeline.

---

## 3. Cliente Flutter & secretos

### 3.1 ✅ Storage de tokens
SharedPreferences solo guarda `notifications_enabled` y `setup_completed`. Los tokens los maneja el SDK de Firebase (auth de terceros → Supabase usa el JWT de Firebase vía `accessToken` mode en `lib/main.dart`). No hay tokens en texto plano.

### 3.2 Keys en el binario — todas client-safe
| Ubicación | Key | Veredicto | Acción |
|-----------|-----|-----------|--------|
| `lib/config/app_environment.dart:12` | Supabase `anon` JWT | ✅ Pública por diseño | Ninguna (RLS la respalda) |
| `lib/core/services/mercadopago_service.dart:15` | MercadoPago `publicKey` (`APP_USR-<uuid>`) | ✅ Public key (verificado: el access token vive en la Edge Function) | Ninguna |
| `lib/config/app_environment.dart:209` | Firebase API key (`AIzaSy…`) | 🟡 Identificador público | **P1: restringir en GCP** por SHA-256 + APIs |

- ✅ `service_role` de Supabase **no** aparece en `lib/` (solo server-side).
- ✅ `pubspec.lock` versionado (`flutter_client/pubspec.lock`) — protege contra deps maliciosas (lección axios, mar-2026).

### 3.3 🟡 P1 — Obfuscación no activada
El build de prod (`shorebird release android`, `deploy-production.yml:177`) envuelve `--release` pero **no pasa `--obfuscate`**. El AAB es decompilable.

**Tarea:** comando final de release:
```powershell
cd "C:\Users\Blas_\Documents\Aplicacion de Pareja\flutter_client"
shorebird release android --dart-define=APP_ENV=production --dart-define=AUTH_MODE=firebase_third_party `
  -- --obfuscate --split-debug-info=build/symbols
```
⚠️ Guardar `build/symbols/` como artefacto seguro — sin eso, los crashes de Crashlytics son ilegibles. Con Shorebird, los patches deben usar la misma versión de Flutter que el release.

### 3.4 ✅ Firma
- `*.keystore`/`*.jks`/`key.properties` en `.gitignore`, **no trackeados** (verificado con `git ls-files`).
- `isMinifyEnabled = true` + `isShrinkResources = true` en `build.gradle.kts` ✅.
- **Tareas P1:**
  - [ ] Backup del keystore de release **fuera de la máquina** (irrecuperable si se pierde).
  - [ ] Limpiar `homesync-release.keystore.old` y duplicados de la raíz.

---

## 4. Cumplimiento Google Play 2026
- ✅ Target SDK: `targetSdk = flutter.targetSdkVersion` → con Flutter 3.44.1 = **API 35** (cumple requisito ago-2025).
- [ ] **Data Safety form:** declarar `ANDROID_ID` si analytics lo lee; "compartir" incluye uso por PostHog/RevenueCat para fines propios; el pre-review automático compara binario vs. form (cámara/OCR, avatares, FCM, pagos).
- [ ] **Política de privacidad** publicada (existe `flutter_client/PRIVACY_POLICY.md` + `docs/privacy-policy.html` → confirmar URL pública; debe cubrir finanzas, datos de hogar/pareja, OCR de recibos, avatares IA).
- [ ] Justificar permisos (cámara=OCR, notificaciones=FCM); quitar los no usados.

---

## 5. Plan priorizado (los 14 días)

### 🔴 Día del release (orden exacto)
- [ ] `supabase migration repair --status applied 20260601123504` — §2.2
- [ ] `supabase db push --dry-run` → confirmar solo `20260603120000` — §2.2
- [ ] `supabase db push` — §2.2
- [ ] Smoke test admin → ShoppingIcons — §2.3
- [ ] `shorebird release android … --obfuscate --split-debug-info=build/symbols` — §3.3
- [ ] Commit migración en `develop` + merge a `main`

### 🟡 Esta semana (no bloqueante)
- [x] ~~Activar leaked password protection~~ — **N/A**: el auth es Firebase
  third-party, no Supabase Auth. El toggle solo cubre signups de Supabase
  Auth, que no usamos. Sin acción.
- [ ] Restringir Firebase API key en GCP — §3.2
- [ ] Backup del keystore fuera de la máquina — §3.4
- [ ] Completar/validar Data Safety form vs. código — §4

### 🟢 Post-launch (hardening)
- [ ] Índices en FKs + drop de índices sin uso/duplicados — §1.5
- [ ] Retención de `application_logs` (>30d) — §1.5
- [ ] Consolidar policies permisivas múltiples — §1.5
- [ ] Mover `pg_net` fuera de `public` — §1.5
- [ ] Limpiar keystores duplicados/`.old` — §3.4
- [ ] (Opcional, perfil fintech) SSL pinning

---

## Apéndice — Verificaciones contra DB viva (2026-06-03)
- `has_function_privilege('anon', …)` = true en las 4 RPC → grant real, no falso positivo del linter.
- Cuerpo de `pay_planned_expense` → guard `v_uid IS NULL` confirmado → no explotable.
- `pg_get_viewdef(v_shopping_items_usage)` → solo agregados, sin PII.
- `pg_depend` → ningún objeto de DB depende de la vista.
- Policies de `shopping_items` → `is_current_app_admin()` da lectura total a admins.
- `is_current_app_admin()` → keyea por `users.is_admin`; **2 admins** existen.
- `schema_migrations` → `20260601123504` NO aplicada (divergente), `20260601123531` sí.
- `git ls-files` → keystores/.env no trackeados; `pubspec.lock` sí.

**Herramientas:** Supabase MCP (`list_tables`, `get_advisors`, `execute_sql`, `list_migrations`) + revisión de `lib/`, `homesync_admin/`, `android/`, `.github/workflows/`.

---

## Apéndice — Hardening aplicado (2026-06-11)

Migración `20260611231411_harden_qa_admin_and_avatar_storage.sql`:

- **`qa_admin_get_household_members`** tenía `EXECUTE` para `PUBLIC` (incluye
  `anon`) — la única de las ~30 funciones `qa_admin_*` que se coló sin el
  `REVOKE PUBLIC`. Tiene guardia interna (`qa_admin_require_access()`), pero
  igual no debe ser invocable sin login. Revocado; ahora solo `authenticated`.
- **Bucket `avatars`** tenía dos policies abiertas a `public`:
  `Public Access` (SELECT → enumeración del bucket) y `Allow Public Uploads`
  (INSERT con `with_check bucket_id='avatars'` → **cualquiera sin login podía
  subir archivos**). Ambas re-creadas para `authenticated`. Las descargas de
  avatares usan la URL pública (`/object/public/...`) que saltea RLS, así que
  mostrar avatares sigue funcionando; la subida la hace el usuario logueado
  (JWT Firebase ⇒ rol `authenticated`), mismo patrón que `receipts`.

Pendiente verificado como **no accionable**:

- Los 114 warnings `*_security_definer_function_executable` son las RPC del
  app (SECURITY DEFINER invocadas por `authenticated`, con sus checks
  internos). Esperado por diseño, no hay fix en masa.
- `pg_net` en `public`: mover una extensión de schema es riesgoso (rompe
  referencias) y de bajo valor — queda en post-launch §1.5, no antes.
