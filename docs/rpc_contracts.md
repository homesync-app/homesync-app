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

Aprueba la ultima `task_approval` pendiente de una tarea. Solo adultos operativos del hogar (`owner/admin` con `member_type` `parent` o `guardian`). Aca recien se crea la activity y se acreditan recompensas.

- **Migration canonica**: `supabase/migrations/20260514120000_task_commands_v1.sql`
- **Hardening vigente**: `supabase/migrations/20260606135502_harden_parent_mode_task_approval_rpcs.sql`
- **Legacy alias**: `verify_task_transaction` queda como wrapper SQL. Borrar despues de 1-2 releases.
- **Versionado**: ✅ `_v1`
- **Transaccional**: ✅ explicito
- **Idempotente full**: ✅ (activity por `request_id`, ledger por `on conflict`, notificacion guarded por `not exists`)

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_request_id` | `text` | idempotencia |
| `p_user_id` | `uuid` | actor esperado; debe coincidir con `current_app_user_id()` |
| `p_task_id` | `uuid` | tarea |
| `p_verified_by` | `uuid` | actor que aprueba; debe coincidir con `current_app_user_id()` |
| `p_next_due_at` | `timestamptz` | **ignorado**, el server recalcula |

**Autorizacion**

- `current_app_user_id()` debe resolver un usuario autenticado.
- `p_user_id` y `p_verified_by` deben coincidir con `current_app_user_id()`.
- El actor debe pasar `private.is_adult_household_admin(task.household_id, null)`: `role in ('owner','admin')` y `member_type in ('parent','guardian')`.
- `anon` no tiene `EXECUTE`; `authenticated` y `service_role` si.

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

- `"Not authenticated"` (`status=unauthenticated`)
- `"User mismatch"` (`status=forbidden`)
- `"Task not found"` (status `not_found`)
- `"Only adult household admins can approve tasks"` (status `forbidden`)
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
| `public.household_members` | R | check adulto owner/admin via `private.is_adult_household_admin` |

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

Rechaza la ultima `task_approval` pendiente de una tarea. Solo adultos operativos del hogar (`owner/admin` con `member_type` `parent` o `guardian`). No acredita XP/coins; vuelve la tarea a `assigned`, guarda motivo y notifica al submitter.

- **Migration canonica**: `supabase/migrations/20260514194500_reject_task_v1.sql`
- **Hardening vigente**: `supabase/migrations/20260606135502_harden_parent_mode_task_approval_rpcs.sql`
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

**Autorizacion**

- `current_app_user_id()` debe resolver un usuario autenticado.
- `p_user_id` y `p_rejected_by` deben coincidir con `current_app_user_id()`.
- El actor debe pasar `private.is_adult_household_admin(task.household_id, null)`: `role in ('owner','admin')` y `member_type in ('parent','guardian')`.
- `anon` no tiene `EXECUTE`; `authenticated` y `service_role` si.

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
- `"Only adult household admins can reject tasks"` (`status=forbidden`)
- `"No pending approval for task"` (`status=not_found`)

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.tasks` | R + W (update) | vuelve a `assigned` y limpia completion |
| `public.task_approvals` | R + W (update status=rejected) | guarda `decision_request_id` |
| `public.notifications` | W (insert) | notifica al submitter |
| `public.audit_logs` | W (insert) | registra rechazo |
| `public.household_members` | R | check adulto owner/admin via `private.is_adult_household_admin` |

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

## save_expense_v4 *(canonico actual, pendiente de wrapper/documentacion final)*

RPC actual para crear/editar gastos.

- **Cliente**: [supabase_expense_repository.dart:287](flutter_client/lib/features/expenses/data/repositories/supabase_expense_repository.dart:287)
- **Estado**: se mantiene como comando canonico por ahora. El backlog permite documentar `save_expense_v4` como principal o crear `save_expense_v1`; no hacer ambos sin motivo.

Pendiente para un corte futuro: entrada completa con inputs/output/tablas/idempotencia/providers.

---

## settle_debt_v1

Saldar un balance entre dos miembros del hogar. Crea un `expense` de tipo `settlement` (`split_type='fixed'`, `is_shared=true`) que ajusta el balance al instante. Reemplaza el path anterior (`save_expense_v4` con `p_type='settlement'`) que no era idempotente y producía duplicados en doble-tap o reintento.

- **Migration canonica**: `supabase/migrations/20260519204019_settle_debt_v1.sql` (RPC reconstruida en `20260601180000_fix_settle_debt_v1_encoding.sql` para limpiar el título UTF-8 y re-confirmar grants).
- **Versionado**: ✅ `_v1`
- **Transaccional**: implicito (plpgsql)
- **Idempotente full**: ✅ (vía `p_request_id` + unique index `uq_expenses_request_id` + EXCEPTION `unique_violation`)

**Inputs**

| nombre | tipo | descripcion |
|---|---|---|
| `p_request_id` | `text` | clave de idempotencia (UUID v4 generado en cliente) |
| `p_household_id` | `uuid` | hogar del settlement |
| `p_from_user_id` | `uuid` | miembro que paga / salda |
| `p_to_user_id` | `uuid` | miembro que recibe / es saldado |
| `p_amount` | `numeric` | monto a liquidar (> 0) |

**Output** (`jsonb`)

Caso normal:

```json
{
  "success": true,
  "message": "Debt settled",
  "status": "settled",
  "expense_id": "uuid",
  "idempotent": false
}
```

Caso idempotente (mismo `p_request_id` reenviado):

```json
{
  "success": true,
  "message": "Already settled",
  "status": "idempotent",
  "expense_id": "uuid",
  "expense_id_existente": "uuid",
  "idempotent": true
}
```

**Tablas afectadas**

| tabla | R/W | nota |
|---|---|---|
| `public.expenses` | R + W | SELECT pre-insert por `request_id`; INSERT vía `save_expense_v4`; UPDATE para setear `request_id` |
| `public.audit_logs` | W | una fila con `action='settle_debt'`, `entity_type='expense'`, `source='rpc'` |
| `public.expense_splits` | W (via `save_expense_v4`) | un split `fixed` para el `to_user_id` |

**Idempotencia**: si (clave = `p_request_id`). Unique index `uq_expenses_request_id` (parcial: `where request_id is not null`) + SELECT pre-insert + `EXCEPTION unique_violation` como safety net. El cliente DEBE generar un `request_id` nuevo por tap; el server garantiza que el mismo `request_id` devuelve siempre el mismo `expense_id`.

**Errores** (via `jsonb` con `success: false`)

- `status='unauthenticated'` -> `current_app_user_id()` devolvio null.
- `status='invalid'` con `message='request_id is required'` -> `p_request_id` null/vacío.
- `status='invalid'` con `message='household and users are required'` -> algun uuid null.
- `status='invalid'` con `message='amount must be greater than 0'` -> `p_amount <= 0`.

**Providers a invalidar en cliente (tras exito)**

- `expenseBalancesProvider`
- `personalFinanceSummaryProvider`
- `combinedFeedControllerProvider`
- `recentActivityRemoteProvider`

**Cliente**

- Repositorio: [supabase_expense_repository.dart:369](flutter_client/lib/features/expenses/data/repositories/supabase_expense_repository.dart:369) (`settleDebt`)
- Controller: [expense_provider.dart:213](flutter_client/lib/features/expenses/presentation/providers/expense_provider.dart:213) (`ExpenseController.settleDebt`, genera `requestId = Uuid().v4()`)
- Use case: [settle_debt_usecase.dart](flutter_client/lib/features/expenses/domain/usecases/settle_debt_usecase.dart) (documenta la validacion + generacion de UUID, mismo path)
- Tests: [settle_debt_idempotency_test.dart](flutter_client/test/settle_debt_idempotency_test.dart) (6 tests, valida UUID v4, idempotencia, validaciones, propagacion de failures)

**Notas**

- El cliente NUNCA debe llamar a `save_expense_v4` con `p_type='settlement'` para liquidar: ese path no es idempotente. Toda liquidación pasa por `settle_debt_v1`.
- Smoke gate (`scripts/prod_ops/post_deploy_smoke.sql`) incluye `settle_debt_v1` en su lista de RPCs críticos y en la lista de mutaciones no ejecutables por `anon`.

---

## `get_solo_progress_snapshot(p_user_id, p_household_id)`

Snapshot de lectura para Modo Solo. Centraliza XP total, XP semanal, racha real, tareas completadas, dias activos, categorias fuertes y resumen financiero personal para que Home y `Mi espacio` no calculen progreso con reglas divergentes.

**Inputs**

| parametro | tipo | nota |
|---|---|---|
| `p_user_id` | `uuid` | usuario autenticado esperado; debe coincidir con `current_app_user_id()` |
| `p_household_id` | `uuid` | hogar actual; el usuario debe ser miembro |

**Output**

Devuelve `jsonb`. En exito:

- `authorized: true`
- `xp`, `weekly_xp`, `previous_week_xp`, `weekly_xp_delta`
- `tasks_completed`, `weekly_tasks_completed`, `previous_week_tasks_completed`, `tasks_completed_delta`
- `current_streak_days`, `active_days_14`, `recent_activity_count`
- `monthly_expense`, `monthly_income`
- `top_task_category`, `top_expense_category`
- `generated_at`, `week_start`, `household_type`

Si falla la autorizacion devuelve `authorized: false` con contadores en cero y `reason`.

**Tablas / RPCs**

| objeto | R/W | nota |
|---|---|---|
| `public.households` | R | valida tipo de hogar y existencia |
| `public.household_members` | R | valida membresia del caller |
| `public.ledger_entries` | R | XP total y semanal |
| `public.household_activities` | R | tareas completadas, racha, actividad reciente |
| `public.expenses` | R | categoria fuerte de gasto del mes |
| `public.get_personal_finance_summary` | R | ingreso/gasto personal existente |

**Seguridad**

- `security definer`, `set search_path = ''`, referencias `public.` completas.
- Usa `current_app_user_id()` y exige `v_uid = p_user_id`.
- Rechaza usuarios que no pertenecen al hogar pedido.
- `EXECUTE` revocado a `public`/`anon`, concedido a `authenticated`.

**Idempotencia**

Solo lectura. No escribe datos ni necesita `request_id`.

**Providers a invalidar en cliente**

- `soloProgressServerSnapshotProvider`
- `userBalanceProvider`
- `personalFinanceSummaryProvider`
- `recentActivityRemoteProvider`
- `statsControllerProvider`
- `tasksProvider`

**Cliente**

- Provider: `flutter_client/lib/features/dashboard/presentation/providers/solo_progress_provider.dart`
- Modelo: `flutter_client/lib/features/dashboard/domain/models/solo_progress_snapshot.dart`
- UI: `flutter_client/lib/features/dashboard/presentation/screens/solo_space_screen.dart`

---

## `generate_planned_payment_reminders_v1()`

Genera recordatorios de pagos planificados para hogares PREMIUM. NO es un RPC de clientes: lo ejecuta el cron diario via la edge function `planned-payment-reminders` (auth `CRON_SECRET`/service role, mismo patron que `cleanup-old-receipts`).

- `planned_payment_upcoming`: el planificado `pending` vence en exactamente 3 dias.
- `planned_payment_due`: vence hoy.

**Inputs**

Sin parametros (opera sobre `current_date` del servidor).

**Output**

`jsonb`: `{ success, upcoming, due_today, run_date }` — contadores de notificaciones insertadas en esta corrida.

**Tablas / RPCs**

| objeto | R/W | nota |
|---|---|---|
| `public.planned_expenses` | R | `status = 'pending'` con `due_date` en hoy o hoy+3 |
| `public.households` | R | gate premium: `is_premium` y `premium_until` vigente |
| `public.household_members` | R | destinatarios: `payer_default` o todos los adultos (`parent`/`guardian`/`adult`) |
| `public.notifications` | W | inserta el recordatorio; el webhook existente lo convierte en push (send-notification) |

**Seguridad**

- `security definer`, `set search_path = public`.
- `EXECUTE` revocado a `public`/`anon`/`authenticated`; solo `service_role`.

**Idempotencia**

Si: `NOT EXISTS` por `(type, related_entity_id, user_id)`. Correr el cron N veces el mismo dia no duplica; cada periodo de un recurrente es una fila nueva de `planned_expenses`, asi que recuerda una vez por vencimiento.

**Providers a invalidar en cliente**

Ninguno de forma directa (el cliente recibe la notificacion por push/realtime y el listado sale del controller de notificaciones al refrescar).

**Cliente / Ops**

- Edge function: `supabase/functions/planned-payment-reminders/index.ts`.
- Cron sugerido: diario 12:00 UTC (manana en AR). Configurar en Supabase Cron con header `Authorization: Bearer <CRON_SECRET>`.
- Copy sin tildes a proposito (convencion de notificaciones de RPC); `type` + `related_entity_*` quedan estructurados para localizarlas client-side mas adelante.

---

## Apendice: como agregar una entrada nueva

1. Crear la migration con el RPC (`security definer`, `set search_path = public`, validar `current_app_user_id()`).
2. Agregar entrada en este archivo con TODAS las secciones (inputs/output/tablas/idempotencia/errores/providers).
3. Implementar la invocacion en el `*_rpc_service.dart` correspondiente.
4. En el controller/notifier, invalidar exactamente los providers listados.
5. Si hay optimistic update, documentarlo en `docs/optimistic_policy.md`.
