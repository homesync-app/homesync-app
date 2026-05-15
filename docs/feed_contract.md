# HomeSync - Contrato del feed combinado

Este contrato cubre "Movimientos del hogar" y cualquier card que consuma `get_combined_feed`.

## Tipos conceptuales

- `resource`: recurso financiero persistente. Incluye gasto, ingreso, settlement y planned expense.
- `activity`: actividad social o de tareas derivada. Incluye tarea completada, aprobacion, nota y recompensa.
- `system`: evento interno generado por reglas.

## Estado actual del codigo

`get_combined_feed` hoy devuelve items financieros con `record_type` y `transaction_type`. El contrato de columnas vive en `docs/rpc_contracts.md`.

`FeedItemModel` todavia no tiene `FeedItemKind`; por eso las cards no deben inferir acciones nuevas desde strings libres hasta hacer el corte de modelo.

## Reglas

- Recursos financieros se borran o editan en su tabla fuente mediante RPC especifico.
- Actividades derivadas no se editan como recurso financiero. Al deshacer una tarea, se borra/oculta la activity y se revierte el ledger asociado.
- Si hay conflicto entre tabla fuente y `household_activities`, manda la tabla fuente para recursos financieros.
- El feed combinado es cache/lectura. Despues de cualquier comando critico se invalida y se recarga desde backend.

## Primer corte pendiente

- Cambiar `FeedItemModel` para exponer `kind`: `resource`, `activity`, `system`.
- Mantener `transactionType` solo como subtipo financiero (`expense`, `income`, `settlement`).
- Cambiar cards para decidir acciones por `kind` y subtipo, no por strings de titulo/categoria.
