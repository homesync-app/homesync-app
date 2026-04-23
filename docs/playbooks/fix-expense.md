# Playbook: Fix Bug en Expenses

## Archivos clave

- `flutter_client/lib/features/expenses/presentation/screens/expenses_screen.dart` (~1834 LOC — NO leer entero)
- `flutter_client/lib/features/expenses/presentation/screens/savings_tab.dart` (~460 LOC — Metas/Savings tab)
- `flutter_client/lib/features/expenses/presentation/screens/recurrentes_tab.dart` (~310 LOC — Recurrentes tab)
- `flutter_client/lib/features/expenses/presentation/widgets/expense_form_sheet.dart` (~1523 LOC — NO leer entero)
- `flutter_client/lib/features/expenses/` — repos, providers, widgets

## Estructura de expenses_screen

3 tabs via TabBarView:
- **Movimientos**: feed de gastos, settlements (inline en expenses_screen)
- **Recurrentes**: `recurrentes_tab.dart` — RecurrentesTab ConsumerWidget
- **Metas**: `savings_tab.dart` — SavingsTab ConsumerWidget

## Estructura de expense_form_sheet

Ya parcialmente extraído — importa de:
- `expense_form_components.dart` (incluye ExpenseScanButton)
- `expense_form_data.dart`
- `expense_form_selectors.dart`
- `expense_split_builder.dart`, `expense_split_components.dart`, `expense_split_state.dart`

## Reglas

- Usar grep para encontrar el método relevante, NO leer el archivo completo
- Los `_build` methods son privados dentro del State — buscar por nombre
- Para bugs de Metas: ir directo a `savings_tab.dart`
- Para bugs de Recurrentes: ir directo a `recurrentes_tab.dart`
- Probar con `cd flutter_client && flutter test` después del fix
