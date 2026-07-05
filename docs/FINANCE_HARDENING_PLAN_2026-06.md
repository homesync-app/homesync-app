# Plan de endurecimiento estructural — Finanzas & capa Riverpod

> Objetivo: pasar el sistema de finanzas (y la capa de datos transversal) de **~7/10 a 10/10**.
> Fecha: 2026-06-17 · Rama: `develop` · Autor del diagnóstico: revisión asistida.

## 1. Diagnóstico

Los **cimientos son sólidos** (idempotencia real en settle, optimistic updates con
rollback, cola offline, RLS + `SECURITY DEFINER` + `audit_logs`, arquitectura por
capas limpia). Lo que generaba "muchos errores" no eran muchos bugs distintos sino
**un mismo patrón repetido**, agravado porque **los errores eran invisibles**.

### Causa raíz única: `Ref` usado tras un `await` en providers auto-dispose
Un provider `@riverpod` (auto-dispose) se invoca con `ref.read(...)` (que no deja
listener). Durante el `await` de la operación nadie lo mantiene vivo → se destruye →
al volver del `await` cualquier uso de `ref`/`_ref` lanza
`Cannot use the Ref ... after it has been disposed`.

- **Capa repositorio**: el repo guarda `final Ref _ref` y lo lee después de un await
  (logs, analytics, flags admin, `currentUserId`). Presente en 8 repos.
- **Capa controller/notifier**: `ref.read`/`ref.invalidate` en la cola de un método de
  mutación, después del await.

### Multiplicador: errores invisibles
- El error de UI se mostraba con un `SnackBar` del `ScaffoldMessenger` de fondo, que
  **se renderiza detrás del barrier del modal** → el usuario veía "no pasa nada".
- El cliente **ignora el envelope JSON** que devuelven los RPC (`{success:false,...}`),
  tratando cualquier no-excepción como éxito → fallos "blandos" silenciosos.

## 2. Lo ya corregido (esta tanda)

| Área | Cambio | Estado |
|------|--------|--------|
| `expenseRepository` | → `@Riverpod(keepAlive: true)` | ✅ |
| `savings/shopping/dashboard/tasks/rewards/settings` repos | → `keepAlive` | ✅ |
| `ExpenseController.{settleDebt,saveExpense,deleteExpense}` | guard `if (ref.mounted && ...)` antes del refresco | ✅ |
| Diálogo de settle (`_showSettlementDialog`) | error inline visible + cierre robusto + caja de error con `maxHeight`/scroll (anti-overflow) | ✅ |
| `auth`/`household` repos | ya eran `Provider` plano (keepAlive) | ✅ n/a |
| `TaskController` | ya guardaba con `ref.mounted` | ✅ n/a |

## 3. Roadmap a 10/10

### P0 — Disciplina de ciclo de vida (cerrar la clase de bug)
1. **Notifiers de mutación**: auditar y guardar el uso de `ref` post-await en
   `SavingsGoals.{addGoal,contribute,removeGoal}` (11 invalidaciones, hoy enmascaradas
   por `AsyncValue.guard`), `RewardController` (2) y `household_providers` (1).
   Patrón de referencia: `TaskController` (`if (!ref.mounted) return;` y
   `if (ref.mounted) state = ...`). Guardar **tanto** invalidaciones **como**
   asignaciones de `state`.
2. **Regla automatizada**: agregar lint (riverpod_lint ya está activo) o un test de
   convención que falle si un método async de un Notifier usa `ref` después de un
   `await` sin `ref.mounted`. Evita reintroducir el patrón.
3. **Convención de repos**: documentar que **todo repositorio es `keepAlive`** (es un
   singleton sin estado). Nuevos repos deben nacer `@Riverpod(keepAlive: true)`.

### P0 — Visibilidad de errores
4. **Nunca** mostrar fallos vía `ScaffoldMessenger` de fondo cuando hay un modal arriba.
   Patrón único: error inline dentro del modal (como quedó el settle) **o** cerrar el
   modal y luego mostrar el snackbar.
5. **Mensajes para humanos**: `homeCoupleSettlementError(e.toString())` expone el stack
   crudo. Mapear excepciones técnicas a mensajes amables; loguear el detalle a
   `application_logs`, no a la cara del usuario.

### P1 — Contrato de los RPC
6. **Leer el envelope**: los RPC (`settle_debt_v1`, `save_expense_v4`, etc.) devuelven
   `jsonb {success, status, message}`. El repo debe parsearlo y devolver `Left(Failure)`
   cuando `success == false`, en vez de asumir éxito ante cualquier no-excepción.
7. **Tipos generados**: considerar `generate_typescript_types`/contratos compartidos
   para que el shape del envelope no derive entre server y cliente.

### P1 — Red de tests
8. **Regresión del bug de Ref**: test que dispare un settle/save mientras se invalida el
   provider host y verifique que (a) no lanza y (b) la operación se reporta como éxito.
   Ya existe `provider_failure_regression_test.dart` como punto de partida.
9. **E2E de settle en pareja**: balance negativo → Equilibrar → confirma → balance 0,
   feed con la liquidación, idempotencia ante doble-tap.
10. **Widget test del diálogo**: éxito cierra; fallo muestra error inline; no overflow.

### P2 — Higiene y observabilidad
11. **Migraciones**: mantener el flujo `db push --dry-run` + `migration repair` (ya
    documentado) y un gate de encoding (ya hay baseline) para evitar mojibake como
    `Liquidaciâ"o"n`.
12. **Métricas de fallo**: alertar sobre tasa de `application_logs` nivel `error` en
    flujos de finanzas; hoy el logging existe pero no hay alerta.
13. **Documentar el contrato de optimistic updates** (ya hay `docs/optimistic_policy.md`)
    y enlazarlo desde cada Notifier que lo use.

## 4. Checklist de ejecución

- [x] Repos auto-dispose → `keepAlive` (6)
- [x] Guards en `ExpenseController`
- [x] Diálogo de settle: error visible + anti-overflow
- [x] Guards en `SavingsGoals` (addGoal/contribute/removeGoal) + `PaginatedSavingsGoals` (refresh/loadMore) (P0-1)
- [x] Guards en `Rewards.redeem` + `PaginatedRewards` (refresh/loadMore) (P0-1)
- [x] `household_providers` ya era keepAlive → sin riesgo (P0-1)
- [x] Test de convención: repos siempre `keepAlive` (`test/ref_lifecycle_convention_test.dart`) (P0-2a)
- [x] Enforcement del guard en notifiers (P0-2b) — **convention test** en vez de custom_lint (el proyecto evita custom_lint a propósito): `test/notifier_ref_guard_convention_test.dart`. Es heurístico a nivel-archivo (no AST), pero ya encontró y nos hizo arreglar un bug real: `AuthController.signOut` invalidaba 5 providers + seteaba `state` tras `await` sin guard (el signout desmonta la UI autenticada → el controller se puede disponer a mitad). Fixed con `if (!ref.mounted) return;`
- [x] Helper `friendlyErrorMessage` + aplicado a settle, allowance, expense form, challenge (P0-5)
- [x] Test del helper (`test/error_messages_test.dart`) — nunca filtra stacks crudos (P0-5)
- [x] Patrón único de error en modales (P0-4): componente compartido `InlineErrorBanner` (lib/shared/widgets/inline_error_banner.dart) usado por el diálogo de settle, `allowance_sheet` y `expense_form_sheet`. Los snackbars de error con el sheet abierto (que quedaban detrás del barrier) ahora son banners inline; el snackbar de éxito se mantiene (se muestra tras el pop).
- [x] Repos parsean el envelope `{success:false}` (P1-6): helper compartido `assertRpcEnvelopeSuccess` + aplicado a `settle_debt_v1`; `pay_planned_expense`/`allowance`/`complete_couple_challenge_v1` ya lo hacían; `save_expense_v4`/`delete_expense_v1` no son envelope
- [x] Test del envelope guard (`test/rpc_envelope_test.dart`)
- [x] Test de regresión del Ref a nivel provider (`test/ref_disposed_mid_mutation_test.dart`) — dispara `settleDebt`, dispone el controller mid-RPC (cierra el único listener → auto-dispose) y exige que complete; **verificado que falla sin el guard** con el error exacto (P1-8)
- [x] Widget test del diálogo (`test/settlement_confirm_dialog_test.dart`): éxito cierra + corre onSettled; fallo muestra error inline y NO cierra; error largo no desborda (P1-10)
- [x] Diálogo extraído a `SettlementConfirmDialog` (widget puro, testeable) — adelgaza `home_couple_view` y centraliza la coreografía; **el test reveló que el cap del error no bastaba en pantallas bajas → ahora todo el diálogo scrollea** (cierra P0-4 para el settle)
- [x] E2E settle (flujo completo contra fake backend) (P1-9): `test/settle_flow_e2e_test.dart` — balance -10.000 → Equilibrar → `expenseBalancesProvider` refetchea a 0; reintento con el mismo request_id es idempotente (2 llamadas, 1 settlement). Atraviesa ExpenseController + ExpenseBalances reales + el cableado de invalidación.

> Nota Riverpod (aprendida acá): `ref.invalidate` re-ejecuta `build()` pero
> **reusa la misma instancia del Notifier**, así que su `Ref` sigue montado. Para
> reproducir el dispose real hay que quitar el último listener de un provider
> auto-dispose (o `container.dispose()`), no invalidarlo.

### Regla de oro de errores (P0-4/5)
- La UI nunca muestra `e.toString()`. Pasá todo error por `friendlyErrorMessage(e)`
  (`lib/core/errors/error_messages.dart`); el detalle crudo va a `log.e/w`.
- Con un modal abierto, mostrá el error **dentro** del modal (inline), no por
  `ScaffoldMessenger` de fondo (queda detrás del barrier). Referencia: el diálogo
  de settle en `home_couple_view.dart`.
- Pendiente de barrido: `allowance_sheet`, `expense_form_sheet` y otros sheets aún
  reportan por snackbar; migrar a error inline cuando se toquen.

### Patrón canónico de mutación en Notifier auto-dispose
```dart
Future<void> mutate() async {
  // 1) Capturá use cases / repos ANTES de cualquier await.
  final useCase = ref.read(someUseCaseProvider);
  state = const AsyncValue.loading();
  // 2) El write va dentro del guard (atrapa fallos de dominio).
  final next = await AsyncValue.guard(() => useCase.execute(...));
  // 3) Guardá ref/state DESPUÉS del await: el notifier pudo morir.
  if (!ref.mounted) return;
  ref.invalidate(otherProvider);
  state = next;
}
```
Referencia ya correcta en el repo: `TaskController`.

## 5. Definición de "10/10"

1. Ninguna ruta de mutación puede crashear por `Ref` dispuesto (cubierto por
   guards + lint).
2. Ningún fallo de finanzas es invisible (patrón de error en modales + envelope).
3. Cada flujo crítico (settle, save, delete, contribute) tiene test de regresión.
4. Convenciones escritas y verificadas por CI (lint + tests de convención).
