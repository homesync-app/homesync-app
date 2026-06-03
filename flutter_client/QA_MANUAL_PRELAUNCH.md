# 📱 HomeSync — Runbook de QA Manual Pre-Lanzamiento

> **Qué es esto:** el paso a paso hands-on en **dispositivo físico** de los flujos que la suite automática NO cubre (auth real, trial/RevenueCat, push, OCR, pagos entre cuentas).
> **Qué NO es:** el go/no-go de alto nivel (eso está en `PLAYSTORE_FINAL_CHECKLIST.md`) ni la suite automática (`TESTING_GUIDE.md`).
>
> **Regla de oro:** testear sobre el **build de release real con `--obfuscate`** (no debug), instalado en un teléfono Android físico. La ofuscación, FCM y los pagos no se comportan igual en debug/emulador.

---

## Pre-requisitos (antes de empezar)

- [ ] Migración `20260603120000` aplicada a prod (ver `docs/SECURITY_PRELAUNCH_2026-06.md` §2.2)
- [ ] Smoke test del admin pasó (ShoppingIcons cross-hogar)
- [ ] Suite automática verde: `flutter test`
- [ ] AAB/APK de release con obfuscación instalado en device:
  ```powershell
  cd flutter_client
  shorebird release android --dart-define=APP_ENV=production --dart-define=AUTH_MODE=firebase_third_party `
    -- --obfuscate --split-debug-info=build/symbols
  # luego instalar el APK universal del bundle en el teléfono
  ```
- [ ] **2 dispositivos** (o device + emulador) para los flujos de hogar compartido entre 2 cuentas
- [ ] Cuenta de prueba de Google Play en el grupo de **Internal Testing** (para probar compras reales sin cobrar)

---

## A. Onboarding & Auth (build de release, no debug)

> Ojo: con `--obfuscate`, si algo usa reflexión/nombres de clase en runtime, acá explota. Por eso se testea en release.

- [ ] **A1.** Instalar limpio (app nunca abierta) → abre sin crash, muestra onboarding
- [ ] **A2.** Signup con email nuevo → recibe verificación / entra → crea usuario en `users`
- [ ] **A3.** Logout → vuelve a login
- [ ] **A4.** Login con la cuenta recién creada → entra al dashboard
- [ ] **A5.** Reset password → llega el mail → cambia → login con la nueva
- [ ] **A6.** Cerrar app por completo y reabrir → **sesión persiste** (no re-pide login)
- [ ] **A7.** Elegir cada uno de los 4 modos de hogar (couple/solo/friends/family) → copy y tono correctos por modo *(ver memoria household modes)*
- [ ] **A8.** Modo avión al abrir → mensaje de error claro, sin crash (connectivity provider)

## B. Hogar compartido (2 cuentas reales)

- [ ] **B1.** Cuenta 1 crea hogar → genera código de invitación (animación reveal-and-copy)
- [ ] **B2.** Cuenta 2 se une con el código → ambas se ven en el hogar
- [ ] **B3.** Cuenta 1 crea una tarea → Cuenta 2 la ve en tiempo real (Realtime + poll de 15s de respaldo)
- [ ] **B4.** Cuenta 2 completa la tarea → Cuenta 1 ve el feed actualizado + notificación
- [ ] **B5.** Tarea recurrente: completar → verificar que regenera con el próximo due date

## C. 💳 Trial de 14 días + Premium (RevenueCat) — EL MÁS DELICADO

> Este es el flujo que paga las cuentas. Testealo entero, sin saltear pasos.

- [ ] **C1.** Usuario free recién creado → ¿arranca con trial activo o hay que activarlo? Confirmar el estado inicial esperado
- [ ] **C2.** Verificar **qué features premium** están bloqueadas en free vs. desbloqueadas en trial (avatares IA, task approval, etc.)
- [ ] **C3.** Iniciar el trial → confirmar contador/fecha de fin visible y correcta (14 días)
- [ ] **C4.** Con trial activo → las features premium se desbloquean
- [ ] **C5.** **Compra real** (cuenta de Internal Testing): suscribirse → RevenueCat procesa → webhook actualiza `revenuecat_customer_state` → premium del hogar se recomputa
- [ ] **C6.** Verificar que el **estado premium se comparte a nivel hogar** (si Cuenta 1 paga, Cuenta 2 del mismo hogar también tiene premium)
- [ ] **C7.** **Restaurar compras** (reinstalar app o login en otro device) → premium se mantiene
- [ ] **C8.** **Cancelar** la suscripción → confirmar el comportamiento al expirar (degrada a free, no rompe datos)
- [ ] **C9.** Simular **fin de trial sin pagar** → degrada a free correctamente, features se re-bloquean
- [ ] **C10.** Verificar que no hay forma de **bypassear premium** desde la app (las RLS de `harden_premium_bypass_rls` lo cubren server-side, pero confirmar la UX)

## D. 🔔 Push Notifications (FCM) — solo en device físico

- [ ] **D1.** Permitir notificaciones en el primer prompt → token FCM se guarda en `user_fcm_tokens`
- [ ] **D2.** Acción de la otra cuenta (completar tarea, registrar gasto) → llega la push
- [ ] **D3.** Tocar la push → abre la pantalla correcta (deep link)
- [ ] **D4.** App en background y cerrada → la push llega igual
- [ ] **D5.** Rechazar permisos → la app sigue funcionando sin crash

## E. 💸 Finanzas & Pagos

- [ ] **E1.** Registrar gasto compartido → split correcto entre miembros
- [ ] **E2.** Registrar gasto personal/privado → NO visible para el otro miembro (privacy contracts)
- [ ] **E3.** Gasto planificado → **un miembro paga por el otro** → "Pendiente"/"Pagado" reflejan total de hogar *(ver memoria planned payment semantics)*
- [ ] **E4.** Saldar deuda (`settle_debt`) → balances se actualizan en ambas cuentas
- [ ] **E5.** Verificar montos/moneda correctos (no hay glitches de redondeo ni símbolos raros)

## F. 📸 OCR de Recibos & Avatares

- [ ] **F1.** Escanear recibo con cámara real → extrae monto/items → log en `receipt_scan_logs`
- [ ] **F2.** Foto borrosa/no-recibo → error claro, sin crash
- [ ] **F3.** Generar avatar premium con IA → se sube a `custom-avatars` → se renderiza
- [ ] **F4.** Usuario free intenta avatar premium → bloqueado correctamente

## G. Robustez general (en release)

- [ ] **G1.** Rotar pantalla / multitarea en flujos clave → sin pérdida de estado
- [ ] **G2.** Conexión lenta/intermitente → spinners y reintentos, sin pantallas en blanco
- [ ] **G3.** Recorrer las pantallas principales buscando **textos sin traducir** (l10n) o keys crudas
- [ ] **G4.** Forzar un crash conocido si tenés uno → verificar que **Crashlytics recibe el reporte** y que con `build/symbols` se des-ofusca legible
- [ ] **G5.** `app_runtime_config` force-update → simular versión vieja → muestra el gate de actualización

---

## Registro de bugs encontrados

| # | Pantalla / flujo | Qué pasó | Severidad | ¿Bloquea launch? |
|---|---|---|---|---|
|   |   |   |   |   |

---

## Go / No-Go de QA manual

- **GO** si: A, B, C (entero), D pasan sin bugs bloqueantes.
- **NO-GO** si: cualquier fallo en **C (trial/pagos)** o crash al iniciar en release con obfuscación.
- Bugs de E/F/G no-bloqueantes → anotar y priorizar post-launch.
