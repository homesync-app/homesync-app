# Playbook: Finanzas

## Reglas canónicas

Ver `docs/FINANCE_CANONICAL_RULES_2026-04-01.md` para la definición completa. Este archivo es la fuente de verdad — si hay conflicto con otros docs, este gana.

## Tres capas del modelo

1. **`expense_templates`** — Solo regla. Define recurrencia, monto default, split type. No toca balances.
2. **`planned_expenses`** — Forecast. Visible en feed y resumen, pero NO afecta balance real.
3. **`expenses`** — Realidad confirmada. Solo estos afectan balance compartido e historial financiero.

## Archivos clave

- `flutter_client/lib/features/expenses/` — feature completa
- `flutter_client/lib/features/expenses/presentation/screens/expenses_screen.dart` (2720 LOC)
  - Tab Recurrentes (lines ~492-1841): templates, proyecciones, breakdowns
  - Tab Metas (lines ~1842-2720): savings goals
- `docs/schema.md` — tablas y columnas
- `docs/playbooks/fix-expense.md` — para bugs específicos

## Reglas

- NO mezclar lógica de planned_expenses con expenses
- Los breakdowns (proyección, ingresos, gastos pendientes) son bottom sheets en el tab Recurrentes
- Probar con `cd flutter_client && flutter test`

## Saldar deuda (settle up)

- RPC canonico: `settle_debt_v1` (ver entrada completa en `docs/rpc_contracts.md`).
- **Idempotencia por `p_request_id`**: el cliente genera un UUID v4 por cada tap (en `SettleDebtUseCase` o `ExpenseController.settleDebt`) y la RPC devuelve siempre el mismo `expense_id` para un `request_id` repetido. Esto cubre doble-tap y reintento por timeout de red.
- **No llamar a `save_expense_v4` con `p_type='settlement'`**: ese path no es idempotente y crea duplicados. Toda liquidación pasa por `settle_debt_v1`.
- **Offline**: la acción se encola con `OfflineActionType.rpc` / `target: 'settle_debt_v1'` / `params` completos. Al reconectar, el replay con el mismo `request_id` colapsa a una sola liquidación (verificado en `expense_e2e_test.dart`).
- **UI**: la sección `DebtSettlementSection` (convivencia) y el dialog de settle-up en `home_couple_view.dart` deshabilitan el botón con `_isSettling` / `isSubmitting` mientras la request está en vuelo. Eso, sumado a la idempotencia server-side, da doble red de seguridad.
