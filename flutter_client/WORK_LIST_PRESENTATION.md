# 🏠 HomeSync — Lista de Trabajo para Presentación
Análisis honesto del estado actual de la app y lo que falta para llevarla a nivel profesional y escalable.
Fecha: Marzo 2026 | Versión actual: 1.0.0+48

## 🔴 CRÍTICO — Bloquea la presentación o el negocio

### 1. Monetización Real (Sistema Premium)
*   **Estado:** `premium_provider.dart` usa un mock con SharedPreferences.
*   **Riesgo:** Inversores verán que no hay modelo de negocio real.
*   **Acción:** Integrar `in_app_purchase` para suscripciones reales (Google Play / App Store).

### 2. Identidad Visual (Branding & Splash) [EN PROGRESO 🛠️]
*   **Estado:** Logo de Flutter por defecto en launcher. Splash incompleto.
*   **Acción:** 
    *   [x] Logo premium programático (HomeSyncLogo).
    *   [x] Splash Screen animado (2.5s branded).
    *   [ ] Generar iconos nativos (android/ios).
    *   [ ] Configurar Native Splash para evitar pantalla blanca.

### 3. Onboarding Finalizado [COMPLETO ✅]
*   **Estado:** Login unificado con registro de nombre y propuesta de valor funcional.

---

## 🟡 PRIORIDAD ALTA — Pulido Profesional

### 4. Refactor de Módulos Monolíticos
*   **Estado:** Archivos como `ExpensesScreen` o `SettingsScreen` son muy largos.
*   **Acción:** Separar en widgets lógicos y refactorizar lógica a providers.

### 5. Consistencia Visual (Dark Mode & Colores)
*   **Estado:** El modo oscuro tiene algunos textos difíciles de leer.
*   **Acción:** Auditar todos los temas y asegurar contraste WCAG.

### 6. Sistema de "Logros" (Rewards)
*   **Estado:** Mockeado o estático.
*   **Acción:** Implementar sistema real de XP y monedas basado en tareas completadas.

---

## 🟢 DESEABLE — El "Wow Factor"

### 7. Widget de Escritorio/iOS
*   **Acción:** Crear widgets para ver la lista de compras o tareas rápidas desde el home del cel.

### 8. Notificaciones Push (Firebase)
*   **Acción:** Notificar cuando la pareja completa una tarea o añade un gasto.
