# HomeSync - Contratos de RPCs

Este archivo es **infraestructura para la IA**. Antes de tocar cualquier accion critica, la IA debe leer la entrada correspondiente. Si un RPC cambia, esta tabla cambia en el mismo PR.

Formato por entrada:

- **Inputs**: parametros y tipos.
- **Output**: estructura del payload de respuesta.
- **Tablas afectadas**: lectura (R) y escritura (W).
- **Idempotencia**: si/no, en base a que clave.
- **Errores**: condiciones que disparan `raise exception` o `success: false`.
- **Providers a invalidar en cliente**: lista exacta tras exito.
- **Cliente**: archivo y linea donde se invoca hoy.

> Nomenclatura: los RPCs marcados sin sufijo `_v1` estan pendientes de versionar (Corte 2 del backlog). Ver `architecture_improvement_backlog.md`.

---

## delete_expense_v1

Borra un gasto y limpia activity feed + notificaciones asociadas. Splits y balances son materializados desde `ledger_entries`, no se tocan.

- **Migration**: `supabase/migrations/20260513163300_delete_expense_with_activity_cleanup.sql`
- **Versionado**: ✅ `_v1`
- **Transaccional**: implicito (plpgsql)

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_expense_id` | `uuid` | id del gasto a borrar |

**Output**: `void` (lanza exception si falla).

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.expenses` | R + W (delete) | el gasto |
| `public.household_activities` | W (delete) | filtra `event_type='expense_added'` por `metadata.expense_id` o `metadata.id` |
| `public.notifications` | W (delete) | filtra por `related_entity_type='expense'` |

**Idempotencia**: no. Si el gasto ya no existe, lanza `'Expense not deleted'`.

**Errores**

- `'Not authenticated'` -> sin sesion.
- `'Expense not found'` -> no existe.
- `'Expense not found or not owned by user'` -> no es creador ni owner del hogar.
- `'Expense not deleted'` -> rows afectadas = 0.

**Providers a invalidar en cliente (tras exito)**

- `expenseBalancesProvider`
- `personalFinanceSummaryProvider`
- `combinedFeedControllerProvider`
- `recentActivityProvider`

**Cliente**

- Invocacion: [task_rpc_service.dart no aplica - es expense](flutter_client/lib/features/expenses/presentation/widgets/expense_form_sheet.dart:880)
- Controller: [ExpenseController.deleteExpense](flutter_client/lib/features/expenses/presentation/providers/expense_provider.dart:153)
- Optimistic update: si (lineas 160-166), rollback en 171-181.

---

## complete_task_v1

Completa una tarea. Tiene dos caminos segun si el hogar requiere aprobacion:

- **Camino directo**: marca tarea `active`, crea activity, acredita XP/coins, reprograma recurrencia.
- **Camino con aprobacion**: crea `task_approval` pending, marca tarea `pending_approval`, notifica admins. NO acredita XP/coins; eso lo hace `approve_task_v1` despues.

- **Migration canonica**: `supabase/migrations/20260514120000_task_commands_v1.sql`
- **Legacy alias**: `complete_task_transaction` queda como wrapper SQL delegando a `_v1`. Borrar despues de 1-2 releases.
- **Versionado**: ✅ `_v1`
- **Transaccional**: ✅ explicito
- **Idempotente full**: ✅ (activity guard por `request_id` + ledger por `on conflict`)

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_request_id` | `text` | clave de idempotencia generada en cliente |
| `p_user_ids` | `uuid[]` | performers (al menos 1) |
| `p_task_id` | `uuid` | tarea a completar |
| `p_household_id` | `uuid` | hogar |
| `p_xp_reward` | `integer` | XP por usuario |
| `p_coin_reward` | `integer` | coins por usuario |
| `p_task_title` | `text` | titulo para activity/notifications |

**Output** (`jsonb`)

Camino directo:

```json
{
  "success": true,
  "message": "Task completed",
  "status": "completed",  // implicito en payload
  "task_status": "active",
  "activity_id": "uuid",
  "next_due_at": "timestamptz | null",
  "xp_earned": 10,
  "coins_earned": 5,
  "requires_approval": false
}
```

Camino con aprobacion:

```json
{
  "success": true,
  "message": "Task submitted for approval",
  "status": "pending_approval",
  "task_status": "pending_approval",
  "approval_id": "uuid",
  "requires_approval": true
}
```

Error / no completable:

```json
{ "success": false, "message": "...", "status": "invalid|skipped" }
```

**Tablas afectadas**

| tabla | R/W | camino |
|---|---|---|
| `public.tasks` | R + W (update) | ambos |
| `public.household_activities` | W (insert) | directo |
| `public.ledger_entries` | W (insert, idempotente `on conflict (user_id, type, reference_id)`) | directo |
| `public.task_approvals` | W (insert) | aprobacion |
| `public.notifications` | W (insert por cada admin) | aprobacion |
| `public.audit_logs` | W (insert) | ambos |
| `public.users`, `public.household_members` | R | aprobacion |

**Idempotencia**

- **Camino aprobacion**: si por `p_request_id` (en `task_approvals.request_id`).
- **Camino directo**: si. Activity usa `request_id = 'complete:' || p_request_id` con unique index parcial. Ledger usa `on conflict (user_id, type, reference_id)`. Reintento devuelve la misma activity sin duplicar nada.

**Errores** (todos devueltos como `success: false`, no exception)

- `"At least one performer is required"` -> array vacio.
- `"Task not found or not in completable state"` -> tarea no esta en estado completable.

**Providers a invalidar en cliente (tras exito)**

- `userBalanceProvider`
- `recentActivityProvider`
- (recomendado, no se hace hoy: `Tasks` se actualiza optimisticamente)

**Cliente**

- Invocacion: [task_rpc_service.dart:61](flutter_client/lib/core/services/rpc/task_rpc_service.dart:61) (`completeTaskTransaction` -> llama `complete_task_v1`)
- Offline queue target: `complete_task_v1` ([supabase_task_repository.dart:181](flutter_client/lib/features/tasks/data/repositories/supabase_task_repository.dart:181))
- Notifier: [Tasks.completeTask](flutter_client/lib/features/tasks/presentation/providers/task_provider.dart:175)
- Optimistic update: si (lineas 189-202), rollback en 235.

---

## complete_tasks_batch_v1

Completa varias tareas en un lote. El cliente solo manda `p_task_ids`; el batch resuelve `title`/`xp_reward`/`coin_reward` desde `public.tasks` por tarea y delega cada una a `complete_task_v1`. Hereda de `complete_task_v1` los dos caminos (directo / aprobacion) por tarea.

- **Migration canonica**: `supabase/migrations/20260519002000_complete_tasks_batch_v1.sql`
- **Legacy alias**: `complete_tasks_batch` (sin versionar) queda como wrapper SQL. REQUERIDO mientras existan colas offline persistidas en dispositivos con ese target. Borrar despues de 1-2 releases.
- **Versionado**: ✅ `_v1`
- **Transaccional**: ✅ una transaccion por lote (atomico)
- **Idempotente full**: ✅ heredada de `complete_task_v1` via `request_id` por tarea

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_request_id` | `text` | clave de idempotencia del lote (cliente). Por tarea se deriva `p_request_id || ':' || task_id` |
| `p_user_ids` | `uuid[]` | performers (al menos 1) |
| `p_task_ids` | `uuid[]` | tareas a completar |
| `p_household_id` | `uuid` | hogar |
| `p_completed_at` | `timestamptz` | opcional, default null |

**Output** (`jsonb`)

```json
{
  "success": true,
  "message": "Tareas procesadas: 3 ok, 1 omitidas",
  "results": [ /* un payload de complete_task_v1 por tarea */ ],
  "success_count": 3,
  "skipped_count": 1
}
```

`success` top-level es `true` si el lote corrio (mismo criterio que `qa_admin_complete_tasks_batch`); el detalle por tarea esta en `results`. Lista vacia -> `success: true`, `0/0`.

**Tablas afectadas**

Las mismas que `complete_task_v1` (delegacion), mas lectura de `public.tasks` para resolver title/xp/coin por tarea.

**Idempotencia**

Por `p_request_id` del lote. Cada tarea recibe `p_request_id || ':' || task_id`, que `complete_task_v1` namespacea (`complete:` / `approve:`) y deduplica con unique index parcial + ledger `on conflict`. Reintentar el lote completo o uno parcial NO duplica activities ni re-acredita XP/coins.

**Errores** (devueltos como `success: false`, no exception)

- `"At least one performer is required"` -> `p_user_ids` vacio (lote entero).
- Por tarea: `"Task not found in household"` (`status: skipped`) o los de `complete_task_v1`.

**Providers a invalidar en cliente (tras exito)**

- `userBalanceProvider`
- `recentActivityProvider`

**Cliente**

- Invocacion: [task_rpc_service.dart:102](flutter_client/lib/core/services/rpc/task_rpc_service.dart:102) (`completeTasksBatch` -> llama `complete_tasks_batch_v1`)
- Offline queue target: `complete_tasks_batch_v1` ([supabase_task_repository.dart:263](flutter_client/lib/features/tasks/data/repositories/supabase_task_repository.dart:263))
- Camino admin/QA aparte: `qa_admin_complete_tasks_batch` (no tocado por esta migracion).

---

## approve_task_v1

Aprueba la ultima `task_approval` pendiente de una tarea. Solo admins/owners. Aca recien se crea la activity y se acreditan recompensas.

- **Migration canonica**: `supabase/migrations/20260514120000_task_commands_v1.sql`
- **Legacy alias**: `verify_task_transaction` queda como wrapper SQL. Borrar despues de 1-2 releases.
- **Versionado**: ✅ `_v1`
- **Transaccional**: ✅ explicito
- **Idempotente full**: ✅ (activity por `request_id`, ledger por `on conflict`, notificacion guarded por `not exists`)

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_request_id` | `text` | idempotencia |
| `p_user_id` | `uuid` | (legacy, no se usa internamente) |
| `p_task_id` | `uuid` | tarea |
| `p_verified_by` | `uuid` | admin que aprueba |
| `p_next_due_at` | `timestamptz` | **ignorado**, el server recalcula |

**Output** (`jsonb`)

```json
{
  "success": true,
  "message": "Task approved",
  "status": "approved",
  "task_status": "active",
  "approval_id": "uuid",
  "activity_id": "uuid",
  "next_due_at": "timestamptz | null",
  "xp_earned": 10,
  "coins_earned": 5
}
```

Errores como `success: false`:

- `"Task not found"` (status `not_found`)
- `"Only admins can approve tasks"` (status `forbidden`)
- `"No pending approval for task"` (status `not_found`)

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.tasks` | R + W (update) | `for update` lock |
| `public.task_approvals` | R + W (update status=approved) | `for update` lock |
| `public.household_activities` | W (insert) | con `approval_id` en metadata |
| `public.ledger_entries` | W (insert, idempotente) | por cada performer |
| `public.notifications` | W (insert) | al submitter |
| `public.audit_logs` | W (insert) | |
| `public.household_members` | R | check de rol admin |

**Idempotencia**: full. Activity guarded por `request_id = 'approve:' || p_request_id` con unique index parcial. Ledger por `on conflict (user_id, type, reference_id)`. Notificacion de aprobacion guarded por `not exists` contra rows posteriores a la creacion del approval. Update del approval guarded por `status = 'pending'`.

**Providers a invalidar en cliente (tras exito)**

- `recentActivityProvider`
- `Tasks` (refrescar lista)
- `userBalanceProvider` (XP/coins del performer cambiaron)
- `combinedFeedControllerProvider` (nueva activity en feed)
- Lista de pendientes de aprobacion (refrescar)

**Cliente**

- Invocacion: [task_rpc_service.dart:134](flutter_client/lib/core/services/rpc/task_rpc_service.dart:134) (`verifyTaskTransaction` -> llama `approve_task_v1`)
- Hoy invalida via `silentRefresh()`; recomendado explicitar la lista en un proximo corte.

---

## reject_task_v1

Rechaza la ultima `task_approval` pendiente de una tarea. Solo admins/owners. No acredita XP/coins; vuelve la tarea a `assigned`, guarda motivo y notifica al submitter.

- **Migration canonica**: `supabase/migrations/20260514194500_reject_task_v1.sql`
- **Legacy alias**: `reject_task_transaction` queda como wrapper SQL. Borrar despues de 1-2 releases.
- **Versionado**: si, `_v1`
- **Transaccional**: implicito (plpgsql)
- **Idempotente**: si, por `task_approvals.decision_request_id = p_request_id`

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_request_id` | `text` | idempotencia de la decision |
| `p_user_id` | `uuid` | usuario autenticado esperado |
| `p_task_id` | `uuid` | tarea |
| `p_rejected_by` | `uuid` | admin que rechaza; debe coincidir con `current_app_user_id()` |
| `p_reason` | `text` | motivo opcional |

**Output** (`jsonb`)

```json
{
  "success": true,
  "message": "Task rejected",
  "status": "rejected",
  "task_status": "assigned",
  "approval_id": "uuid",
  "idempotent_replay": "boolean | omitted"
}
```

Errores como `success: false`:

- `"Not authenticated"` (`status=unauthenticated`)
- `"User mismatch"` (`status=forbidden`)
- `"Task not found"` (`status=not_found`)
- `"Only admins can reject tasks"` (`status=forbidden`)
- `"No pending approval for task"` (`status=not_found`)

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.tasks` | R + W (update) | vuelve a `assigned` y limpia completion |
| `public.task_approvals` | R + W (update status=rejected) | guarda `decision_request_id` |
| `public.notifications` | W (insert) | notifica al submitter |
| `public.audit_logs` | W (insert) | registra rechazo |
| `public.household_members` | R | check de rol admin |

**Idempotencia**: full para retries con el mismo `p_request_id`. Si la decision ya fue aplicada, devuelve success con `idempotent_replay=true` sin duplicar notificacion ni audit log.

**Providers a invalidar en cliente (tras exito)**

- Lista de pendientes de aprobacion (`pendingTaskApprovalsProvider`)
- `tasksProvider`
- `todayTasksProvider`
- `recentActivityProvider` si la pantalla muestra actividad/notificaciones derivadas

**Cliente**

- Invocacion: [task_rpc_service.dart:160](flutter_client/lib/core/services/rpc/task_rpc_service.dart:160) (`rejectTaskTransaction` -> llama `reject_task_v1`)
- Accion UI: [pending_approvals_provider.dart](flutter_client/lib/features/tasks/presentation/providers/pending_approvals_provider.dart)

---

## undo_task_completion_v1

Revierte una completion ya confirmada desde su activity. Borra la activity, elimina XP/coins asociados y deja la tarea con los ultimos campos de completion conocidos si habia una activity anterior de la misma tarea.

- **Migration canonica**: `supabase/migrations/20260514193000_undo_task_completion_v1.sql`
- **Legacy alias**: `undo_task_completion` queda como wrapper SQL delegando a `_v1`. Borrar despues de 1-2 releases.
- **Versionado**: si, `_v1`
- **Transaccional**: implicito (plpgsql)

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_activity_id` | `uuid` | activity `task_completed` a revertir |
| `p_user_id` | `uuid` | usuario autenticado esperado; debe coincidir con `current_app_user_id()` |

**Output** (`jsonb`)

Exito:

```json
{
  "success": true,
  "status": "undone",
  "message": "Task completion undone",
  "task_id": "uuid",
  "activity_id": "uuid",
  "household_id": "uuid",
  "deleted_ledger_entries": 2,
  "previous_completed_at": "timestamptz | null",
  "previous_completed_by": "uuid | null"
}
```

Errores como `success: false`:

- `"Not authenticated"` (`status=unauthenticated`)
- `"User mismatch"` (`status=forbidden`)
- `"Task completion activity not found"` (`status=not_found`)
- `"Activity has no task_id metadata"` (`status=invalid`)
- `"Not a household member"` (`status=forbidden`)
- `"Only the performer or a household admin can undo this task"` (`status=forbidden`)
- `"Completion activity was not deleted"` (`status=not_deleted`)

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.household_activities` | R + W (delete) | activity `task_completed` indicada |
| `public.ledger_entries` | W (delete) | `xp_earned` y `coins_earned` con `reference_id = p_activity_id` |
| `public.tasks` | W (update) | limpia/restaura campos de completion |
| `public.household_members` | R | valida admin/owner |
| `public.audit_logs` | W (insert) | registra undo |

**Idempotencia**: parcial. El primer llamado revierte; un retry posterior devuelve `not_found` porque la activity ya no existe. No duplica rewards ni activities.

**Providers a invalidar en cliente (tras exito)**

- `tasksProvider`
- `todayTasksProvider`
- `recentActivityProvider`
- `combinedFeedControllerProvider`
- `expenseBalancesProvider`
- `personalFinanceSummaryProvider`
- `statsControllerProvider`

**Cliente**

- Invocacion: [task_rpc_service.dart:247](flutter_client/lib/core/services/rpc/task_rpc_service.dart:247) (`undoTaskCompletion` -> llama `undo_task_completion_v1`)
- Offline queue target: `undo_task_completion_v1` ([supabase_task_repository.dart:636](flutter_client/lib/features/tasks/data/repositories/supabase_task_repository.dart:636))

---

## get_combined_feed

Feed financiero combinado usado por "Movimientos del hogar".

- **Migration canonica actual**: `supabase/migrations/20260512000000_localizable_finance_titles.sql`
- **Versionado**: no. Es lectura estable; evaluar `get_combined_feed_v1` solo si cambia semantica o output.
- **Transaccional**: lectura.
- **Cliente**: [supabase_expense_repository.dart:183](flutter_client/lib/features/expenses/data/repositories/supabase_expense_repository.dart:183)
- **Contrato funcional**: ver `docs/feed_contract.md`.
- **`kind`**: el RPC NO devuelve `kind` todavia (solo financieros). `FeedItemModel` lo deriva con default `FeedItemKind.resource`. Si en el futuro este RPC suma activities/system, debe emitir la columna `kind` (`resource`/`activity`/`system`) y el modelo la respeta sin cambios.

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_household_id` | `uuid` | hogar a consultar |
| `p_limit` | `integer` | limite, default 20 |
| `p_offset` | `integer` | offset, default 0 |

**Output** (`table`)

| columna | tipo | descripcion |
|---|---|---|
| `record_type` | `text` | `expense` o `planned` |
| `transaction_type` | `text` | `expense`, `income` o `settlement`; planned siempre `expense` |
| `id` | `uuid` | id del recurso fuente |
| `title` | `text` | titulo localizable/fallback |
| `title_key` | `text` | key localizable opcional |
| `amount` | `numeric` | monto |
| `category` | `text` | categoria |
| `split_type` | `text` | tipo de split |
| `payer_id` | `uuid` | pagador/default payer |
| `payer_email` | `text` | email del payer |
| `payer_full_name` | `text` | nombre del payer |
| `payer_avatar_url` | `text` | avatar del payer |
| `date` | `timestamptz` | `paid_at` o `due_date` |
| `status` | `text` | `paid` para expenses, status de planned |

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.expenses` | R | `type in ('expense','income','settlement')` |
| `public.planned_expenses` | R | solo `status='pending'` |
| `public.users` | R | payer display/avatar |
| `public.household_members` | R | via `is_current_household_member()` |

**Privacidad / visibilidad**

- Si no hay `current_app_user_id()`, devuelve lista vacia.
- Si el usuario no pertenece al hogar, devuelve lista vacia.
- Expenses compartidos son visibles para el hogar.
- Expenses `personal`/`gift` no compartidos solo son visibles para `paid_by` o `created_by_id`.
- Planned `personal`/`gift` solo son visibles para `payer_default`.

**Idempotencia**: no aplica, lectura.

**Providers a invalidar despues de comandos que afectan el feed**

- `combinedFeedControllerProvider`
- `recentActivityProvider` solo si el comando tambien toca activity social

**Pendiente**

- Alinear `FeedItemModel` con `FeedItemKind` para distinguir `resource`, `activity`, `system`.

---

## save_expense_v4 *(canonico actual)*

RPC canonico para **crear y editar** gastos/ingresos/settlements. Lo usa toda la creacion de gastos del cliente y `settle_debt_v1` por dentro.

- **Estado**: canonico. No se crea `save_expense_v1` salvo motivo concreto (backlog seccion 1). Naming legacy aceptado a proposito.
- **Versionado**: ⚠️ `_v4` (no sigue la convencion `_v1`; es deuda de naming, no de comportamiento)
- **Transaccional**: ✅ una transaccion (insert/update expense + regenera splits)
- **Idempotente**: ❌ **NO**. `p_id` null siempre inserta una fila nueva. La idempotencia de settlements la aporta `settle_debt_v1` (ver su entrada). Para crear gastos comunes no hay guard: reintentar puede duplicar.

**Overloads en prod** (hay 2; el cliente usa la de `p_id` primero):

1. `(p_id, p_household_id, p_title, p_amount, p_category, p_paid_by, p_paid_at, p_description, p_split_type, p_is_shared, p_type, p_splits, p_receipt_path)` → `uuid` ← **usada por el cliente**
2. `(p_household_id, p_title, p_amount, p_category, p_paid_by, p_type, p_description, p_split_type, p_splits, p_paid_at, p_id, p_receipt_path)` → `uuid` (overload heredada, no usada por el cliente)

**Inputs** (overload 1)

| nombre | tipo | descripcion |
|---|---|---|
| `p_id` | `uuid` | null → crear; presente → editar (solo si `created_by_id = caller`) |
| `p_household_id` | `uuid` | si null, se resuelve por membresia del caller |
| `p_title` | `text` | titulo |
| `p_amount` | `numeric` | monto |
| `p_category` | `text` | categoria |
| `p_paid_by` | `uuid` | debe ser miembro del hogar |
| `p_paid_at` | `timestamptz` | default `now()` |
| `p_description` | `text` | opcional |
| `p_split_type` | `text` | `equal` / `personal` / `gift` / `fixed` |
| `p_is_shared` | `boolean` | forzado a false si `personal`/`gift` |
| `p_type` | `text` | `expense` / `income` / `settlement` (cast a `transaction_type`) |
| `p_splits` | `jsonb` | `[{user_id, amount}]`; ignorado en `personal`/`gift`; auto-equal si vacio y `equal` |
| `p_receipt_path` | `text` | opcional |

**Output**: `uuid` del gasto creado/editado.

**Validaciones / errores** (via `RAISE EXCEPTION`)

- `Not authenticated` → `current_app_user_id()` null.
- `Household not found for user` / `User is not member of household`.
- `paid_by must be a member of the household`.
- `Expense not found or not owned by user` → editar un gasto de otro.
- `One or more split users are not household members`.

**Logica de splits**

- `personal`/`gift` → `is_shared=false`, un split al pagador.
- `equal` sin `p_splits` (o ≤1) → divide en partes iguales entre todos los miembros.
- resto con `p_splits` → valida miembros e inserta los splits provistos (camino de `settlement`).
- En edicion borra `expense_splits` previos y los regenera.

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.expenses` | W (insert o update) + R | en update exige `created_by_id = caller` |
| `public.expense_splits` | W (delete+insert) | regenerados siempre |
| `public.household_members` | R | validaciones de membresia |

No escribe ledger ni tabla de balances: el balance se **deriva** de `expenses` + `expense_splits`.

**Idempotencia**: ninguna propia. Settlements protegidos por `settle_debt_v1`. Gastos comunes: el reintento online/offline puede duplicar (riesgo conocido, fuera de alcance de este corte).

**Cliente**

- Crear/editar: [supabase_expense_repository.dart:285](flutter_client/lib/features/expenses/data/repositories/supabase_expense_repository.dart:285) (`saveExpense`), mismo `target` en cola offline (linea 323).
- Camino admin/QA: `qa_admin_save_expense_v1` (no tocado).
- **Providers a invalidar tras exito** (de `expense_provider.dart`): `expenseBalancesProvider`, `personalFinanceSummaryProvider`, `combinedFeedControllerProvider`, `recentActivityRemoteProvider`.

---

## settle_debt_v1

Salda una deuda entre dos miembros: registra un gasto `type = 'settlement'` (pagado por `from`, split fijo a `to`). Reusa `save_expense_v4` como capa canonica y agrega el guard de idempotencia que faltaba.

- **Migration canonica**: `supabase/migrations/20260519003000_settle_debt_v1.sql`
- **Sin wrapper legacy**: el cliente nunca llamo a un RPC `settle_debt`; saldaba via `save_expense_v4` directo (que NO se rerutea, lo usa toda la creacion de gastos). El cliente pasa a `settle_debt_v1`.
- **Versionado**: ✅ `_v1`
- **Transaccional**: ✅ una transaccion
- **Idempotente full**: ✅ `expenses.request_id` + unique index parcial `uq_expenses_request_id`

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_request_id` | `text` | clave de idempotencia. **Generada UNA vez en el cliente y reusada entre el intento online y la cola offline** |
| `p_household_id` | `uuid` | hogar |
| `p_from_user_id` | `uuid` | quien paga (salda) |
| `p_to_user_id` | `uuid` | quien recibe |
| `p_amount` | `numeric` | monto, > 0 |

**Output** (`jsonb`)

```json
{ "success": true, "status": "settled|idempotent", "expense_id": "uuid", "idempotent": false }
```

Errores (devueltos como `success: false`, no exception): `Not authenticated`, `request_id is required`, `household and users are required`, `amount must be greater than 0`.

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.expenses` | R (pre-check por `request_id`) + W (insert via `save_expense_v4`, update `request_id`) | |
| `public.expense_splits` | W (insert via `save_expense_v4`) | split fijo a `to` |
| `public.audit_logs` | W (insert) | `action = 'settle_debt'` |

**Idempotencia**

Por `p_request_id`. Pre-check: si ya existe expense con ese `request_id`, devuelve esa (no-op). Carrera: dos requests identicos crean su expense, el 2do UPDATE viola `uq_expenses_request_id` -> `exception when unique_violation` hace rollback de la expense duplicada (misma tx) y devuelve la existente. Persiste **exactamente una** liquidacion.

**Providers a invalidar en cliente (tras exito)**

- `userBalanceProvider`
- `recentActivityProvider` / feed combinado

**Cliente**

- Invocacion + offline queue target: `settle_debt_v1` ([supabase_expense_repository.dart](flutter_client/lib/features/expenses/data/repositories/supabase_expense_repository.dart) — `settleDebt`, mismo `requestId` en ambos caminos).

---

## Apendice: como agregar una entrada nueva

1. Crear la migration con el RPC (`security definer`, `set search_path = public`, validar `current_app_user_id()`).
2. Agregar entrada en este archivo con TODAS las secciones (inputs/output/tablas/idempotencia/errores/providers).
3. Implementar la invocacion en el `*_rpc_service.dart` correspondiente.
4. En el controller/notifier, invalidar exactamente los providers listados.
5. Si hay optimistic update, documentarlo en `docs/optimistic_policy.md`.
