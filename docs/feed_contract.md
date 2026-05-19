# HomeSync - Contrato del feed combinado

Este contrato cubre "Movimientos del hogar" y cualquier card que consuma `get_combined_feed`.

## Tipos conceptuales

- `resource`: recurso financiero persistente. Incluye gasto, ingreso, settlement y planned expense.
- `activity`: actividad social o de tareas derivada. Incluye tarea completada, aprobacion, nota y recompensa.
- `system`: evento interno generado por reglas.

## Estado actual del codigo

`get_combined_feed` hoy devuelve solo items financieros con `record_type` y `transaction_type` (no manda `kind` todavia). El contrato de columnas vive en `docs/rpc_contracts.md`.

`FeedItemModel` ya expone `kind` (`FeedItemKind`: `resource` | `activity` | `system`). Se deriva de `map['kind']` con default `resource` (forward-compatible: cuando el RPC mande `kind`, se respeta sin tocar el modelo). Todo item es `resource` hoy.

## Reglas

- Recursos financieros se borran o editan en su tabla fuente mediante RPC especifico.
- Actividades derivadas no se editan como recurso financiero. Al deshacer una tarea, se borra/oculta la activity y se revierte el ledger asociado.
- Si hay conflicto entre tabla fuente y `household_activities`, manda la tabla fuente para recursos financieros.
- El feed combinado es cache/lectura. Despues de cualquier comando critico se invalida y se recarga desde backend.
- **Las cards ramifican acciones por `kind` (gate `item.isResource`) y subtipo, NO por strings de titulo/categoria.**

## Primer corte (hecho 2026-05-19)

- ✅ `FeedItemModel.kind` (`FeedItemKind` resource/activity/system) + getter `isResource`.
- ✅ `transactionType` queda como subtipo financiero (`expense`/`income`/`settlement`) y solo aplica cuando `kind == resource`.
- ✅ `_buildFeedItemCard` gatea por `isResource` antes de tratar el item como gasto.
- ✅ Eliminada la inferencia `title.contains('liquidación') ? 'settlement' : 'expense'`; ahora usa `transactionType` estructurado.

Fuera de alcance (flag, no es accion del feed): `expense_detail_sheet.dart` infiere `isShoppingList` por `title.contains('compra')`. Es heuristica de display sobre `ExpenseModel`, no decide acciones del feed. Revisar solo si da bug real.
