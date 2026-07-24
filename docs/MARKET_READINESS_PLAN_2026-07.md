# Plan de market readiness — HomeSync

> Objetivo: pasar de "app técnicamente lista" a "app con posibilidad real de éxito en el mercado".
> Fecha: 2026-07-24 · Rama: `develop` · Base: build `1.2.5+86`, track `production` en Play (`com.blas.homesync`).

## 0. Diagnóstico

La app **no tiene un problema técnico**. Tiene ~120k LOC de Flutter bien estructuradas
(feature/data/domain/presentation), backend Supabase endurecido (RLS, RPCs versionados,
`SECURITY DEFINER`, cron), i18n completa (2.284 claves ES/EN), Shorebird, Crashlytics,
CI/CD a producción y features que la competencia directa no tiene (4 modos de hogar con
copy adaptativo, OCR de tickets, avatares generados con IA).

Los tres problemas son **de producto y de distribución**:

1. **No se puede medir nada.** 15 `logEvent` en 120k LOC, 7 de 438 archivos tocan
   analytics, PostHog conectado pero vacío. Sin funnel de activación ni retención
   D1/D7/D30, cada decisión de producto es una apuesta a ciegas.
2. **El loop viral está roto.** Es una app de dos lados (sin la pareja adentro vale ~0)
   y la invitación es un código alfanumérico que hay que tipear a mano. No hay App
   Links, así que un link de WhatsApp no abre la app ni preserva el código.
3. **La ficha de Play vende 1/4 del producto.** Título "Tareas y Gastos en Pareja"
   mientras la app tiene modos familia, convivencia y solo completos. `STORE_LISTING`
   está en v46 con la app en build 86.

### Evidencia recogida (2026-07-24)

| Hallazgo | Evidencia |
| --- | --- |
| Analytics casi inexistente | 15 `logEvent` en `lib/`; solo 7 archivos referencian analytics |
| PostHog vacío | proyecto `HommeSync` (id 377955): 0 eventos custom, solo defaults del sistema |
| Sin evento de compra exitosa | `premium_service.dart:205` trackea `purchase_started`, nunca el resultado |
| Sin App Links | `AndroidManifest.xml` solo declara el scheme `homesync://` |
| iOS nunca configurado | `PRODUCT_BUNDLE_IDENTIFIER = com.example.homesyncClient` |
| Sin motor de reseñas | 0 usos de `in_app_review` en todo el repo |
| Ficha desactualizada | `playstore_assets/STORE_LISTING_es-AR_v46.md` vs build 86 |
| Onboarding largo | `SetupStep` tiene 8 pasos antes del primer dato propio |
| Peso | 21 MB de assets (20 MB imágenes); AAB v71 = 91 MB |
| Retención pasiva | `notifyMember` usado en 1 solo lugar (love notes) |
| Accesibilidad | `Semantics` en 9 de 438 archivos |

### Métrica que define todo

**% de hogares que llegan a 2 miembros activos a los 7 días.**
Si ese número es bajo, nada más importa hasta arreglar la Fase 2. Hoy es
**inobservable**: por eso la Fase 1 va primero.

---

## Fase 1 — Ver (bloquea todo lo demás)

> Sin instrumentación, las fases 2 y 3 se ejecutan a ciegas y no se puede saber si
> funcionaron.

**Decisión de arquitectura:** PostHog entra como **segundo sink dentro de
`AnalyticsService`**, no como llamadas dispersas. Un solo punto de cambio; los call
sites existentes empiezan a emitir a ambos destinos sin tocarlos. Firebase Analytics se
mantiene (Crashlytics y Play lo usan); PostHog aporta funnels, cohortes, retención,
feature flags y experimentos, que Firebase no da bien.

### 1.1 Infraestructura — HECHO
- [x] `posthog_flutter ^5.33.0` en `pubspec.yaml`
- [x] `AppEnvironment.postHogApiKey` / `postHogHost` / `postHogEnabled`
- [x] Init en `main.dart`, en paralelo con Supabase, esperado antes de `runApp`
- [x] `PostHogSink` (`core/services/posthog_sink.dart`): único lugar que importa
      el SDK; todo método es no-op si `setup()` no corrió
- [x] Sink dual dentro de `AnalyticsService` (Firebase + PostHog)
- [x] `PosthogObserver` en `navigatorObservers` → `$screen` automático
- [x] `identify()` al autenticar / `reset()` al cerrar sesión (vía `setUserId`)
- [x] Super properties `household_mode`, `member_count`, `is_premium` cableadas con
      `listenManual` en `MyApp._wireAnalyticsContext`

### 1.2 Funnel de activación — HECHO
- [x] `auth_sign_up_succeeded` (ya existía)
- [x] `setup_step_viewed` (`step` + `mode`) — emitido desde `_goToStep`, el único
      punto de cambio de paso del wizard
- [x] `setup_completed` (`mode`, `path`: created | joined)
- [x] `invite_sent` (`channel`: whatsapp | copy)
- [x] `invite_accepted`
- [x] `household_second_member_joined` ← **la métrica del negocio**
- [x] `first_expense_created` / `first_task_created` (ya existían; ahora llegan
      también a PostHog por el sink dual)

### 1.3 Funnel de monetización — HECHO
- [x] `paywall_opened` con `source` real en los 17 puntos de entrada
      (`dashboard_bills`, `budgets`, `avatar_picker`, `parent_mode`, …)
- [x] **Bug corregido**: `PremiumPaywall.show` emitía `paywall_opened` y además
      lo emitía `PremiumPaywallScreen.initState` → toda apertura contaba doble.
      Ahora la pantalla es el único emisor y `source` es parámetro obligatorio.
- [x] `paywall_dismissed` (en `dispose`, así cuenta también el back del sistema)
- [x] `premium_purchase_completed` ← **el que faltaba**
- [x] `premium_purchase_cancelled` / `premium_purchase_failed` (con `error_code`)
- [x] `premium_restore_completed`

### 1.4 Dashboards en PostHog — HECHO (vacíos hasta que salga el build)

Proyecto `HommeSync` / `Default project` (id 377955). Los tres dashboards están
**pineados** y etiquetados `market-readiness` + `fase-1`.

- [x] [Fase 1 · Activación](https://us.posthog.com/project/377955/dashboard/1903165)
  - Funnel de activación · instalación → primer gasto (5 pasos, ventana 7 d)
  - ★ **LA MÉTRICA**: hogares que llegan a 2 miembros en 7 días
  - Dónde se cae el wizard de setup (`setup_step_viewed` por `step`)
  - Invitaciones enviadas por canal (línea base para medir la Fase 2.1)
  - Funnel de activación por modo de hogar
- [x] [Fase 1 · Retención](https://us.posthog.com/project/377955/dashboard/1903166)
  - Retención diaria D0–D30 global + semanal W0–W8
  - Retención D0–D30 por modo: pareja / solo / familia / amigos
- [x] [Fase 1 · Monetización](https://us.posthog.com/project/377955/dashboard/1903167)
  - Funnel paywall → compra con breakdown por `source`
  - Aperturas de paywall por `source`
  - Resultado de la compra: completada vs cancelada vs fallida
  - Fallos de compra por `error_code`
- [x] Cohorte [Hogares varados en 1 miembro (>7 días)](https://us.posthog.com/project/377955/cohorts/435089)
      — dinámica: completó setup hace 7–90 días y nunca hubo segundo miembro.
      Es la lista de targeting de la Fase 2.2.

**Notas de implementación (para no repetir el trabajo de descubrimiento):**

- `RetentionQuery` **ignora** `breakdownFilter` — la segmentación por
  `household_mode` se hace con un insight por modo y un filtro `properties`.
  Por eso hay 4 tiles de retención y no uno con breakdown.
- La retención usa `Application opened` (que emite el SDK gracias a
  `captureApplicationLifecycleEvents`), no un evento propio.
- El funnel de activación usa ventana de **7 días** a propósito: así el número
  que devuelve es literalmente la métrica del negocio, sin post-proceso.

**Criterio de salida:** poder responder, sin tocar código, "de cada 100 instalaciones,
cuántas llegan a un hogar de 2 personas activo a los 7 días".

> **Estado real:** los tableros existen pero están en cero. PostHog no tiene ni un
> evento custom todavía porque la instrumentación de 1.1–1.3 aún no llegó a
> producción. La Fase 1 no se cierra al crear los tableros: se cierra cuando el
> build con PostHog está publicado y estos tableros muestran datos.

---

## Fase 2 — Crecer (acá está el dinero)

> Arranca recién cuando la Fase 1 esté emitiendo datos en producción.

### 2.1 Invitación de un toque (máxima prioridad)
- [ ] Dominio verificado + **App Links** (`assetlinks.json`)
- [ ] **Play Install Referrer**: el código de invitación sobrevive a la instalación
- [ ] Deep link que crea la cuenta y entra al hogar sin tipear nada
- [ ] Fallback actual (código manual) intacto para quien ya lo tiene

### 2.2 Cerrar el loop de la pareja ausente
- [ ] Recordatorio a las 48 h si el hogar sigue con 1 miembro
- [ ] Estado explícito en el dashboard: "falta que se una X" con CTA de reenvío
- [ ] Win-back a 7 / 14 / 30 días

### 2.3 Store listing y ASO
- [ ] Reescribir título y descripción para **los 4 modos**, no solo pareja
- [ ] Keywords: "dividir gastos", "gastos compartidos", "convivencia", "organizar familia"
- [ ] Screenshots por modo (ya generadas en `playstore_assets/screenshots/2026-07`,
      falta commitearlas y subirlas)
- [ ] Video promocional
- [ ] Evaluar el nombre: "HomeSync" es genérico y colisiona en la store
- [ ] Privacy policy y términos en dominio propio (hoy en `github.io`)

### 2.4 Motor de reseñas
- [ ] `in_app_review` en 3 momentos de éxito: meta de ahorro completada,
      deuda saldada, racha de tareas cerrada
- [ ] Rate limit: máximo 1 pedido cada 90 días, nunca tras un error

---

## Fase 3 — Escalar

- [ ] **iOS**: bundle id real, certificados, App Store Connect, RevenueCat iOS key
      (`revenueCatIosPublicApiKey` hoy está vacío)
- [ ] Reducir bundle: avatares premium bajo demanda (Play Asset Delivery) en vez de
      los 20 MB de imágenes empaquetadas
- [ ] Experimentos de pricing con feature flags de PostHog
- [ ] Accesibilidad: `Semantics` en los flujos críticos (hoy 9/438 archivos)
- [ ] Canal de soporte in-app visible (las edge functions `send-feedback-*` ya existen)

---

## Orden de ejecución

1. **Fase 1 completa** — es el prerequisito de todo lo demás.
   Código (1.1–1.3) y tableros (1.4) están listos; falta **publicar el build**.
   Hasta que no haya un release en Play con la instrumentación adentro, los
   tableros siguen en cero y la Fase 2 sigue bloqueada.
2. Dejar correr 2 semanas y **leer los datos** antes de decidir 2.1 vs 2.3.
3. **Fase 2** priorizada por lo que digan los datos: si la caída está en el invite,
   2.1 y 2.2 primero; si la caída está en instalaciones, 2.3 primero.
4. **Fase 3** cuando haya evidencia de retención sana en Android.

## Fuera de alcance (deliberado)

- Reescribir el onboarding de 8 pasos **antes** de medirlo. Primero el dato de en qué
  paso se cae la gente, después el rediseño.
- Nuevas features de producto. El backlog (`ideas_features_from_animations.md`,
  `TEEN_FINANCES_SPEC.md`) queda congelado hasta tener retención medida.
