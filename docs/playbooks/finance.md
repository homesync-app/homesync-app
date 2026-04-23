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
