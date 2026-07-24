# Capturas para Play Store

Playbook para regenerar las capturas de la ficha de Play Store cuando la UI cambia.

## Cuenta demo (pareja, con datos cargados)

Cuentas creadas **exclusivamente** para capturas de tienda y material promocional.
Viven en **producción** (Firebase Auth → Supabase), no en los escenarios QA de staging.

> ⚠️ Las credenciales **no van en este archivo**: este repo es público. Están en
> `supabase/.env.claude` (gitignoreado), bajo las claves
> `DEMO_SCREENSHOT_OWNER_EMAIL` / `_PASSWORD` y `DEMO_SCREENSHOT_PARTNER_EMAIL` /
> `_PASSWORD`. Si no tenés ese archivo, pedilo — no lo reconstruyas a mano ni
> pegues las claves acá.

| Rol | Usuaria | Clave en `.env.claude` |
| --- | --- | --- |
| Owner | Sofi | `DEMO_SCREENSHOT_OWNER_*` |
| Pareja | Mati | `DEMO_SCREENSHOT_PARTNER_*` |

> Nota: por autenticarse vía Firebase, estas cuentas **no aparecen** en
> `auth.users` de Supabase — no las busques ahí.

## Flujo de captura

1. Emulador recomendado: `Medium_Phone_API_36.1` (1080×2400, 9:16 — cumple specs
   de Play Store: 16:9 o 9:16, 320–3840 px por lado).
2. Correr la app en modo producción normal (sin defines de QA) e iniciar sesión
   con la cuenta demo owner.
3. Capturar con adb (está en `%LOCALAPPDATA%\Android\Sdk\platform-tools` si no
   está en PATH):

   ```powershell
   adb exec-out screencap -p > captura.png
   ```

4. Idiomas: capturar en **español y en inglés**. El idioma se cambia con el
   locale del dispositivo:

   ```powershell
   adb shell "setprop persist.sys.locale en-US; setprop ctl.restart zygote"
   ```

   (o desde Settings del emulador). Volver a `es-AR` al terminar.

## Pantallas recomendadas (ver PLAYSTORE_UPLOAD_GUIDE)

1. Inicio con resumen de hogar
2. Tareas y completado
3. Movimientos y balances
4. Metas de ahorro
5. Recompensas / desafíos

## Salida

Guardar las capturas crudas en `flutter_client/playstore_assets/screenshots/<version>/`
separadas por idioma (`es/`, `en/`).

## Notas de datos demo (aprendidas jul 2026)

- **Estados de tareas:** los estados válidos de la app son
  `active / assigned / pending_approval / pending_verification / verified / objected`.
  `'completed'` NO existe: el parser hace fallback a `active` y el historial
  aparece como "vencidas". El historial debe estar en `verified` (con
  `verified_by` = la pareja y `verified_at`).
- **XP del duelo semanal:** sale de `ledger_entries` (`xp_earned` de la semana
  en curso), no de `tasks.completed_at`. Para que el duelo no muestre 0 XP un
  lunes, mover/insertar entradas de ledger con `created_at` de hoy.
- **Feed "Movimientos del hogar":** lee `household_activities` con filtro de
  recencia; si todo es viejo muestra vacío. Insertar 2-3 eventos frescos
  (`task_completed`) repartidos entre Sofi y Mati.
- **Localización de títulos:** `tasks.title_key` (catálogo
  `taskTemplate*`) y `expenses/planned_expenses.title_key` (`financeTitle*`)
  hacen que los títulos cambien de idioma solos. Las tareas demo ya los tienen.
  Los títulos de metas (`savings_goals.title`) son texto libre: para la tanda
  EN renombrarlos temporalmente por SQL y revertir después.
- **Emojis:** el emulador API 29 no renderiza emojis nuevos (p. ej. 🛟 de
  Unicode 14 → glifo roto). Usar emojis clásicos (💰 ✈️ 🛋️).
- **Barra de navegación:** ocultarla antes de capturar para aprovechar toda la
  pantalla: `adb shell settings put global policy_control immersive.navigation=*`
  (restaurar con `... policy_control null`). Ojo: corre las coordenadas de tap
  del tab bar ~110 px hacia abajo.
- **Status bar limpio:** modo demo de SystemUI antes de capturar:
  `adb shell settings put global sysui_demo_allowed 1` y broadcasts
  `com.android.systemui.demo` (clock 0930, battery 100, wifi 4, sin notifs).
- **Idioma:** cambiar desde la app (Settings → Idioma), no hace falta tocar el
  locale del dispositivo. Las capturas 2026-07 se hicieron con el escenario:
  6 tareas activas (3 Sofi / 3 Mati, sin vencidas) + 52 verificadas de historial.
