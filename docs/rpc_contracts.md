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

## undo_task_completion *(existe, pendiente de versionar a `_v1`)*

Revierte una tarea ya completada. Implementacion existente:

- Invocacion cliente: [task_rpc_service.dart:247](flutter_client/lib/core/services/rpc/task_rpc_service.dart:247) (`undoTaskCompletion`).
- Inputs: `p_activity_id uuid`, `p_user_id uuid`.
- Pendiente: documentar contrato real (tablas, idempotencia, providers a invalidar) y renombrar a `_v1` en un corte futuro.

---

## Apendice: como agregar una entrada nueva

1. Crear la migration con el RPC (`security definer`, `set search_path = public`, validar `current_app_user_id()`).
2. Agregar entrada en este archivo con TODAS las secciones (inputs/output/tablas/idempotencia/errores/providers).
3. Implementar la invocacion en el `*_rpc_service.dart` correspondiente.
4. En el controller/notifier, invalidar exactamente los providers listados.
5. Si hay optimistic update, documentarlo en `docs/optimistic_policy.md` (pendiente de crear).
