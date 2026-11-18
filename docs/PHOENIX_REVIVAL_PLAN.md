# Plan Fénix — Relanzamiento y Consolidación de HomeSync

> Fecha: 2026-11-18 · Rama base: `codex/couple-home-refresh` (sobre `v1.5.3+92`, commit `617f0a62`)

---

## 1. Diagnóstico Ejecutivo

HomeSync cuenta con una base de ingeniería sólida y madura:
- **Cliente Flutter (~120.000 LOC):** arquitectura por features (`data` / `domain` / `presentation`), Riverpod 3, soporte bilingüe real (`es-AR` con voseo y `en-US` con +2.280 claves ARB), actualizaciones OTA con Shorebird (`flutter_client/shorebird.yaml`), escáner de tickets con Gemini 3.5 Flash-Lite + validación aritmética y caché por CUIT, compras reales verificadas con RevenueCat y analítica dual (Firebase + PostHog).
- **Backend Supabase:** +72 migraciones SQL, políticas RLS, RPCs transaccionales idempotentes (`complete_task_v1`, `settle_debt_v1`, `save_expense_v4`), Edge Functions en Deno/TypeScript y cron jobs.

### Por qué se percibía inconclusa y sin tracción
1. **Tres capas visuales superpuestas en modo Pareja:** convivían al mismo tiempo el estilo anterior (burbujas de actividad estilo chat e íconos Material planos), la ola intermedia de *Planes y Álbum* (`1.5.3+92`) y la ola nueva de acuarelas sin commitear en `codex/couple-home-refresh`.
2. **El último sprint (3–4 de octubre de 2026) quedó sin cerrar ni publicar:** quedaron sin integrar a `main` los 36 avatares dobles en acuarela, el atlas ilustrado del hogar, el rediseño limpio del Inicio y la nueva barra inferior.
3. **Fricción en la invitación del segundo miembro:** en una app de hogar, un hogar de una sola persona no retiene. Depender de copiar y tipear códigos manuales sin App Links verificados rompe el loop viral.

---

## 2. Alerta Operativa Inmediata

> [!WARNING]
> **Supabase Keep-Alive (`.github/workflows/supabase-keepalive.yml`):** GitHub Actions desactiva los workflows programados tras **60 días sin commits** en el repositorio. Con el último commit en `main`/`develop` del 2026-10-03, hay que integrar cambios a `develop`/`main` (o reactivar manualmente el workflow en GitHub Actions) antes de los 60 días para evitar que el proyecto Free de Supabase se pause.

---

## 3. Auditoría del "Estilo Nuevo sin publicar"

### Ola A — Commiteada en `main` (`1.5.2+91` y `1.5.3+92`)
- **Mascota e ícono oficial:** el gatito abrazando la casita (`output/branding/ICONO-PLAY-STORE-512.png`), configurado como adaptive icon y splash cálido (`#FFF7F0`).
- **Rediseño de Pareja (`CoupleWeekScreen` / `CouplePlansSection`):** planes para hacer juntos (*"Cine en casa"*, *"Lo hicimos"*, guardar planes), *"Nuestro álbum"* de sellos coleccionables, *"Un mimo para..."* (notitas) y el resumen *"En casa, en equipo"* sin ranking competitivo.

### Ola B — En `codex/couple-home-refresh`
- **Catálogo de 36 escenas dobles y 8 retratos circulares en acuarela (`PremiumAvatarArt`):** los dos avatares elegidos por la pareja aparecen juntos cuidando una planta (`flutter_client/assets/images/avatar_art/`).
- **Atlas de ilustraciones del hogar (`HouseholdArt` / `household_icons.webp`):** reemplaza íconos planos por ilustraciones en acuarela en Inicio, Tareas, Calendario y Compras.
- **Inicio y Movimientos limpios (`HomeCoupleView` / `CoupleActivityTile`):** reemplaza las burbujas tipo chat por tarjetas limpias de ancho completo.
- **Navegación con botón central `+` (`CustomBottomNav` / `showCoupleActionsSheet`):** elimina los FABs superpuestos en modo pareja y centraliza las acciones rápidas en un botón `+` en la barra inferior.

### Resolución del conflicto Ola A vs. Ola B
Al ocultar `MainTab.social` en `main_navigation.dart` para dejar 4 destinos + el botón central `+`, `CouplePlansSection` y el acceso a escribir notitas habían quedado sin punto de entrada visible.
**Solución unificada:**
- Mantener la barra inferior limpia de 4 pestañas (`Inicio`, `Tareas`, `Finanzas`, `Compras`) + botón central `+`.
- Incorporar **Dejar una notita** (`coupleHomeLeaveNote`) y **Un ratito para ustedes** (`couplePlansTitle` -> `showCouplePlansSheet`) dentro del sheet de acciones del botón `+` cuando la pareja ya tiene ambos integrantes.
- Hacer que tocar la tarjeta de bienvenida `CoupleHomeWelcome` (cuando la pareja está completa) también abra `showCouplePlansSheet` con los Planes, el Álbum de sellos y el acceso directo a enviar una notita.
- Extender `HouseholdArt` a las tarjetas de movimientos y saldos de **Finanzas** (`ExpensesScreen`) en modo pareja para que las cuatro secciones compartan exactamente el mismo lenguaje visual en acuarela.

---

## 4. Hoja de Ruta en 4 Fases (Checklist Ejecutable)

### Fase 1 — Cierre y Unificación Visual (Completada)
- [x] Documentar el Plan Fénix (`docs/PHOENIX_REVIVAL_PLAN.md`) y actualizar la spec de navegación (`docs/design/couple-home-navigation.md`).
- [x] Agregar acceso a **Notitas** y **Planes y Álbum** en `showCoupleActionsSheet` y al tocar `CoupleHomeWelcome`.
- [x] Extender ilustraciones `HouseholdArt` a las filas de gastos y liquidaciones de `ExpensesScreen` en modo pareja.
- [x] Actualizar los tests de navegación/acciones (`couple_tasks_refresh_test.dart`, `tasks_flow_test.dart`, `couple_home_design_test.dart`).
- [x] Ejecutar suite completa de tests en entorno con Flutter SDK (`flutter test --no-pub --exclude-tags=golden` + `dart analyze` con 0 errores).
- [x] Revisar capturas visuales actualizadas de `couple_home_design_test.dart` y `couple_tasks_refresh_test.dart` (`CAPTURE_HOME=true`) y alinear onboarding (`SetupTaskSelectionStep`, `SetupInviteStep`, `PartnerInviteCard`) con ilustraciones en acuarela (`HouseholdArt` / `CoupleArt`).

### Fase 2 — Consolidación de Ramas y Estabilidad Técnica (Completada)
- [x] Commitear y mergear `codex/couple-home-refresh` hacia `develop` y pushear a `origin/develop` (reinicia el reloj de actividad de GitHub Actions / keep-alive).
- [x] Auditar ramas locales pendientes contra `main`:
  - `codex/shopping-icons-aliases`: ya integrada en `main` mediante `e01cf280` (`feat(shopping): ES→EN icon alias matching (client-side, no SQL)`), que descartó deliberadamente las migraciones SQL redundantes. No requiere merge.
  - `claude/determined-ritchie-fe4446`: el fix de `home_couple_view.dart` (`587c04ca`) ya está en `main`, y los otros 2 commits (`a37ee504`, `32ce2d51`) tocaban archivos ya reemplazados por `couple_space`. No requiere merge.
  - `codex/convivencia-mode`: 100% mergeada en `main` (0 commits de diferencia).
- [x] Actualizar rutas locales de `flutter_client/android/local.properties` y `flutter_client/android/key.properties`, y eliminar `homesync-release.keystore.old` de la raíz (según `docs/PRELAUNCH_CONFIG_GUIDE.md` §4.3; pendiente backup externo manual de los `.keystore`).

### Fase 3 — Destrabar el Loop Viral y Activación (En curso)
- [x] Conectar `app_links` (`homesync://` y query/path params) en `SetupScreen` y agregar extracción automática del código al pegar mensajes completos de WhatsApp en `SetupStartStep` (`InstallReferrerService.parseInviteDeepLink` / `extractInviteCodeFromText` + tests).
- [ ] Configurar **App Links HTTPS verificados** (`assetlinks.json` en dominio propio) para que links `https://` abran directo la app sin pasar por Play cuando ya está instalada.
- [x] Optimizar el estado *"Esperando a tu pareja"* en `HomeCoupleView`: `PartnerInviteCard` compacto ahora muestra el arte de sobre en acuarela, botón directo a WhatsApp y `InviteCodeBox` visible/copiable en un toque desde el Inicio sin perder la posibilidad de cargar tareas y gastos.
- [ ] Validar end-to-end las notificaciones push de reactivación (nota recibida, gasto compartido cargado, aprobación pendiente en familia, recordatorio a 48 h si el hogar sigue con 1 miembro).

### Fase 4 — Relanzamiento y Promoción
- [ ] Regenerar las 8 capturas de Google Play con `goldie` (`1080x1920`, `es-AR` y `en-US`) reflejando el nuevo estilo en acuarela, los 36 avatares dobles y el nuevo ícono de mascota.
- [ ] Publicar el release `1.5.4` desde `main` mediante `deploy-production.yml` (`shorebird release android` con `--obfuscate`).
- [ ] Verificar en producción el flujo de datos hacia los 3 tableros de **PostHog** (Activación, Retención, Monetización) y el conector `growth-mcp`.
- [ ] Ejecutar el calendario de 2 semanas de Reels y Carruseles en Instagram y TikTok (`docs/marketing/social-launch.md`) con capturas actualizadas del estilo nuevo y links UTM por campaña.
