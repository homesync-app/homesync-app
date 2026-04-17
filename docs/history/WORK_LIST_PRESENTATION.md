# 🏠 HomeSync — Lista de Trabajo para Presentación

Análisis honesto del estado actual de la app y lo que falta para llevarla a nivel profesional y escalable.  
**Fecha:** Marzo 2026 | **Versión actual:** 1.0.0+48

---

## Estado General
La app tiene una base técnica muy sólida: arquitectura limpia (`features/data/domain/presentation`), Riverpod bien usado, Supabase con RLS, Firebase Crashlytics, offline queue, dark mode, múltiples tipos de hogar. Es una app real, no un prototipo.

**El problema central:** Tiene el cuerpo de una app de producción pero algunos sistemas críticos están simulados (monetización), hay flows incompletos (onboarding, offboarding), y la consistencia visual tiene baches. Para una presentación que convenza a inversores o usuarios reales, hay trabajo por delante.

---

## 🔴 CRÍTICO — Bloquea la presentación o el negocio

### 1. Monetización Real (Sistema Premium) ✅
**Estado:** Integrado con `in_app_purchase`, `PremiumService` y backend de Supabase.
**Lo realizado:**
*   Se instaló `in_app_purchase`.
*   Se creó `PremiumService` con soporte para suscripciones reales y validación local/remota.
*   Se refactorizó `PremiumNotifier` para ser database-driven (Supabase `users.is_premium`).
*   Se diseñó `PremiumPaywallScreen` profesional con animaciones y "Modo Desarrollador".
*   Se sincronizó el estado en `main.dart` y `SettingsScreen`.

**Por qué es crítico:** Sin monetización real no hay negocio. En una presentación esto es la primera pregunta.

### 2. Onboarding Incompleto y Fragmentado
**El problema:** Existen `onboarding_screen.dart` y `setup_screen.dart` pero están desconectados. `OnboardingScreen` nunca es llamada desde ningún lugar visible (no aparece en `main.dart` ni `main_screen.dart`). El onboarding actual en `SetupScreen` es funcional pero básico.

**Lo que hay que hacer:**
*   Diseñar un onboarding unificado de 3-4 pasos con propuesta de valor clara:
    *   **Paso 1:** "¿Para quién es tu hogar?" (solo, pareja, familia, amigos).
    *   **Paso 2:** "Invita a tu pareja/familia" con código QR/link directo.
    *   **Paso 3:** "Configura tus primeras tareas" (ya existe).
    *   **Paso 4:** Tour rápido de la app (tooltips o walkthrough).
*   El onboarding debe MOSTRAR el valor antes de pedir registro.
*   Agregar la opción "Probar sin cuenta" o demo mode para presentaciones.

**Por qué es crítico:** El onboarding es la primera impresión. Un onboarding malo = churn alto.

### 3. El Tab "Progreso" (StatsScreen) está incompleto
**El problema:** `StatsScreen` tiene 3 tabs: "Semana", "Evolucion", "Logros". "Evolucion" y "Logros" dependen de datos que pueden estar vacíos. La tab "Evolución" usa un `ProgressTab` con gráficos de `fl_chart` pero sin datos de largo plazo se ve vacía. El tab "Logros" (`AchievementsTab`) probablemente muestra placeholders.

**Lo que hay que hacer:**
*   Definir y completar el sistema de logros (achievements) con badges reales.
*   Mostrar estado vacío atractivo con call-to-action ("¡Completá tu primera semana!").
*   Agregar datos de ejemplo para la presentación si los usuarios son nuevos.
*   Revisar que `WeeklyWinnerScreen` funcione correctamente al fin de semana.

---

## 🟠 IMPORTANTE — Afecta la percepción profesional

### 4. Falta Pantalla de Ahorros Integrada
**El problema:** `SavingsScreen` existe pero no aparece en el `bottomNavigationBar` de `main_screen.dart`. Los ahorros son una feature de valor altísimo pero el usuario tiene que encontrarla dentro de "Finanzas".

**Lo que hay que hacer:**
*   Decidir si Ahorros merece su propio tab o queda dentro de Finanzas como sub-sección.
*   Si queda en Finanzas, agregar una tab visible dentro de `ExpensesScreen`.
*   Conectar los objetivos de ahorro con el sistema de rewards/XP para gamificación.

### 5. Pantalla de Notificaciones sin Contenido Real
**El problema:** `NotificationsScreen` existe pero hay que verificar que el sistema de push notifications (Firebase Messaging + send-notification Edge Function) funcione end-to-end. El in-app banner (`InAppNotificationBanner`) funciona, pero las notificaciones push pueden no llegar.

**Lo que hay que hacer:**
*   Testear el flow completo: acción en app A → notificación push en dispositivo B.
*   Asegurarse que las notificaciones de tareas completadas, gastos y challenges lleguen.
*   Agregar pantalla de configuración de notificaciones (qué tipo recibir).
*   Implementar notificaciones de recordatorio de tareas pendientes.

### 6. Inconsistencias de UX entre Modos de Hogar
**El problema:** Hay 4 modos (solo, pareja, familia, amigos) pero la experiencia no está diferenciada suficientemente. El modo "familia" recién se está trabajando. El tab "Pareja" dice "Pareja" cuando el hogar es de amigos (aunque `caps.showPartnerTab` controla la visibilidad).

**Lo que hay que hacer:**
*   Auditar cada modo y verificar que el contenido tenga sentido contextual.
*   En modo "solo", ocultar toda referencia a "pareja" o "competir con...".
*   En modo "familia", adaptar la gamificación para incluir hijos (puntos por tareas escolares, etc.).
*   Revisar el label del tab dinámico ("Pareja" → "Familia" → "Equipo" según el tipo).

### 7. Settings Screen: muy extensa y sin organización clara
**El problema:** `settings_screen.dart` tiene 86KB — es un archivo monolítico. Mezcla perfil, hogar, apariencia, notificaciones, premium, debug, FAQ. En una app escalable, esto es difícil de mantener.

**Lo que hay que hacer:**
*   Dividir en sections claramente agrupadas con separadores visuales.
*   Separar "Configuración del Hogar" en su propia pantalla/sección.
*   Mover el panel de admin/debug a un acceso oculto (triple tap en versión, etc.).
*   En producción, remover el toggle de "Simular Premium" del settings visible.

### 8. El Sign-Up no pide nombre ni avatar
**El problema:** `_handleSignUp` en `login_screen.dart` pasa null como nombre completo. El usuario crea cuenta y queda con nombre vacío. Esto genera una experiencia rara donde el app muestra "Hola, !" o similar.

**Lo que hay que hacer:**
*   Agregar campo de nombre en el registro (o capturarlo post-registro en el primer paso del onboarding).
*   Forzar que el usuario elija un avatar antes de poder invitar a alguien a su hogar.
*   Capitalizar y validar el nombre adecuadamente.

---

## 🟡 MEJORAS — Para escalar y diferenciarse

### 9. Arquitectura: Archivos Demasiado Grandes
**El problema:** `expenses_screen.dart` (93KB), `settings_screen.dart` (86KB), `rewards_screen.dart` (55KB), `tasks_screen.dart` (45KB), `setup_screen.dart` (49KB). Estos archivos son difíciles de mantener, revisar y testear.

**Lo que hay que hacer:**
*   Extraer widgets complejos a sus propios archivos en `/widgets/`.
*   En `ExpensesScreen`, separar: `MovementsTab`, `BalanceTab`, `SplitTab` en widgets propios.
*   Aplicar el principio de *single responsibility*: cada archivo < 300-400 líneas máximo.
*   Documentar los widgets públicos con comentarios de API.

### 10. Testing: Cobertura Real y CI/CD
**El problema:** Existen 17 archivos de test pero es probable que muchos sean a nivel unitario o vacíos. No hay evidencia de CI/CD corriendo tests automáticamente (el `GITHUB_ACTIONS_SETUP.md` existe pero hay que verificar que esté activo).

**Lo que hay que hacer:**
*   Verificar que todos los tests en `/test/` pasen (`flutter test`).
*   Agregar widget tests para los flows más críticos (login, task completion, expense creation).
*   Activar GitHub Actions para que cada push corra los tests.
*   Agregar test de integración básico que valide el flow de auth + household.

### 11. Profundizar la Gamificación
**El problema:** XP y coins existen pero el sistema de "por qué me importa" no está completo. Los usuarios pueden ganar XP y coins pero ¿para qué sirven los coins? ¿Los rewards son reales (canjeables) o decorativos?

**Lo que hay que hacer:**
*   Definir claramente qué se puede hacer con los coins ganados.
*   Implementar al menos 1-2 rewards canjeables concretos (ej: "El que gana elige la peli", "Cena gratis").
*   Agregar "desafíos" o challenges semanales automáticos entre miembros.
*   Hacer el sistema de niveles (XP thresholds) más visible y motivador.

### 12. Mejorar la Pantalla de Tareas
**El problema:** `tasks_screen.dart` tiene 45KB con toda la lógica mezclada. El calendario (`calendar_screen.dart`) existe pero no está en la navegación principal.

**Lo que hay que hacer:**
*   Agregar vista de calendario accesible desde la pantalla de tareas.
*   Implementar filtros rápidos: "Mías", "Del partner", "Atrasadas", "Esta semana".
*   Agregar drag-to-reorder para priorizar tareas.
*   Mostrar streak de días seguidos completando tareas.

### 13. App sin Logo/Branding definido
**El problema:** El logo actual en `login_screen.dart` es un `Icons.home_rounded` + `Icons.favorite_rounded` programático. No hay un logo SVG o PNG real. El nombre "HomeSync" está definido pero la identidad visual no está consolidada.

**Lo que hay que hacer:**
*   Diseñar o conseguir un logo real para HomeSync.
*   Actualizar el ícono de la app en Android/iOS (`android/app/src/main/res/` y `ios/Runner/Assets.xcassets`).
*   Definir la paleta de colores oficial y asegurarse que sea consistente en toda la app.
*   Crear una Splash Screen branded (la actual usa el spinner genérico).

### 14. MercadoPago: Integration Incompleta
**El problema:** `mercadopago_service.dart` existe y hay una Edge Function `mercadopago-api`, pero el Deep Link handler en `main_screen.dart` ya trata con `payment-success/failure/pending`. Hay que verificar que el flow completo funcione.

**Lo que hay que hacer:**
*   Testear el flow completo de pago: usuario hace tap → MercadoPago → deep link de vuelta → update en app.
*   Implementar webhook server-side para confirmar pagos (no solo confiar en el deep link).
*   Documentar qué se puede pagar con MercadoPago (¿suscripción premium? ¿split de gastos?).
*   Agregar historial de transacciones de MercadoPago.

### 15. Pantalla de Lista de Compras: Features Faltantes
**El problema:** `shopping_list_screen.dart` (36KB) existe pero hay que evaluar si tiene: sincronización en tiempo real, tachado colaborativo (cuando pareja tilda un ítem), precios estimados.

**Lo que hay que hacer:**
*   Verificar que los cambios de una persona se reflejen en tiempo real en el otro dispositivo (Supabase Realtime).
*   Agregar precio estimado por ítem y total estimado de compra.
*   Implementar "tiendas" o categorías de supermercado (Verdulería, Lácteos, etc.).
*   Agregar historial de compras frecuentes para autocompletar.

---

## 🔵 TÉCNICO — Para que sea escalable

### 16. Migraciones de Base de Datos Desordenadas
**El problema:** El directorio `database/migrations/` tiene numeración duplicada: `008_fix_rpc_uid.sql`, `008_fix_task_persistence_and_tx.sql`, `008_notifications.sql` — tres archivos con el prefijo 008. Lo mismo con `011_notification_push_trigger.sql` y `011_reward_templates_sync.sql`.

**Lo que hay que hacer:**
*   Ordenar y renumerar las migraciones correctamente.
*   Verificar que las migraciones en `/database/migrations/` y `/supabase/migrations/` estén sincronizadas.
*   Implementar un sistema de versioning de DB (ej: Supabase migration history).
*   Documentar en README el orden correcto de aplicación.

### 17. Variables de Entorno y Seguridad
**El problema:** `cert.pem` está en la raíz del proyecto (podría tener información sensible). Los `.keystore` files también están en la raíz (riesgo si el repo se hace público).

**Lo que hay que hacer:**
*   Verificar que `.gitignore` incluya `*.keystore`, `*.pem`, y archivos con secrets.
*   Usar GitHub Secrets para CI/CD en vez de archivos locales.
*   Revisar que `AppEnvironment` no exponga keys en builds de producción.
*   Separar configuración de staging vs producción de manera más clara.

### 18. El paquete mcp_server: any en pubspec.yaml
**El problema:** `mcp_server: any` está listado como dependencia en producción. Esto es probablemente un remanente de desarrollo y no debería ir al build de producción.

**Lo que hay que hacer:**
*   Remover `mcp_server` de `dependencies` o moverlo a `dev_dependencies`.
*   Verificar que no cause conflictos o aumente el tamaño del APK innecesariamente.

---

## 📊 Resumen Ejecutivo para la Presentación

| Área | Estado Actual | Prioridad |
| :--- | :--- | :--- |
| **Monetización** | ✅ Integrado con Store e IDs reales | 🟢 Completo |
| **Onboarding** | ⚠️ Fragmentado, sin propuesta de valor clara | 🔴 Crítico |
| **Gamificación** | ✅ Base sólida, falta completar rewards | 🟠 Importante |
| **Finanzas** | ✅ Muy completo (93KB de código) | 🟡 Pulir UX |
| **Tareas** | ✅ Completo y funcional | 🟡 Agregar filtros |
| **Notificaciones** | ⚠️ UI lista, push notifications por verificar | 🟠 Importante |
| **Branding/Logo** | ❌ Sin logo real | 🟠 Para presentación |
| **Testing** | ⚠️ Tests existen, cobertura incierta | 🟡 Agregar cobertura |
| **Arquitectura** | ✅ Clean Architecture bien aplicada | 🟡 Reducir tamaño archivos |
| **Base de datos** | ✅ RLS, migraciones, RPC functions | 🔵 Ordenar numeración |
| **Multi-modo hogar** | ✅ Solo/Pareja/Familia/Amigos | 🟡 Completar modo Familia |
| **Offline support** | ✅ Cola offline implementada | ✅ Production ready |

---

## 🎯 Plan Recomendado para la Presentación (3 semanas)

### Semana 1 — Monetización y Primera Impresión
*   Implementar `in_app_purchase` con planes Freemium definidos.
*   Rediseñar onboarding unificado con propuesta de valor.
*   Crear logo real e icono de app.

### Semana 2 — Completar Features Claves
*   Completar sistema de logros (achievements con badges reales).
*   Verificar y testear notificaciones push end-to-end.
*   Implementar rewards canjeables concretos.

### Semana 3 — Calidad y Pulido
*   Corregir el Sign-Up (nombre/avatar obligatorio).
*   Modo familia completo y consistente.
*   Limpiar settings screen y remover debug tools.
*   Verificar todos los tests pasen y activar CI/CD.
