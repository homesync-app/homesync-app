-- =============================================================================
-- reject_task_v1
-- =============================================================================
-- Versiona el rechazo de tareas pendientes de aprobacion y agrega idempotencia
-- por request_id de decision. El nombre legacy queda como wrapper.
-- =============================================================================

alter table public.task_approvals
  add column if not exists decision_request_id text;

create unique index if not exists uniq_task_approvals_decision_request_id
  on public.task_approvals(decision_request_id)
  where decision_request_id is not null;

create or replace function public.reject_task_v1(
  p_request_id text,
  p_user_id uuid,
  p_task_id uuid,
  p_rejected_by uuid,
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_current_user_id uuid := public.current_app_user_id();
  v_approval public.task_approvals%rowtype;
  v_task_household uuid;
begin
  if v_current_user_id is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'status', 'unauthenticated'
    );
  end if;

  if p_user_id is distinct from v_current_user_id
      or p_rejected_by is distinct from v_current_user_id then
    return jsonb_build_object(
      'success', false,
      'message', 'User mismatch',
      'status', 'forbidden'
    );
  end if;

  if p_request_id is not null then
    select * into v_approval
    from public.task_approvals
    where decision_request_id = p_request_id
      and status = 'rejected';

    if found then
      return jsonb_build_object(
        'success', true,
        'message', 'Task rejected',
        'status', 'rejected',
        'task_status', 'assigned',
        'approval_id', v_approval.id,
        'idempotent_replay', true
      );
    end if;
  end if;

  select household_id into v_task_household
  from public.tasks
  where id = p_task_id
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Task not found',
      'status', 'not_found'
    );
  end if;

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_task_household
      and hm.user_id = v_current_user_id
      and hm.role in ('owner', 'admin')
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Only admins can reject tasks',
      'status', 'forbidden'
    );
  end if;

  select * into v_approval
  from public.task_approvals
  where task_id = p_task_id
    and status = 'pending'
  order by created_at desc
  limit 1
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'No pending approval for task',
      'status', 'not_found'
    );
  end if;

  update public.task_approvals
  set
    status = 'rejected',
    decided_by = v_current_user_id,
    decided_at = now(),
    rejection_reason = p_reason,
    decision_request_id = p_request_id
  where id = v_approval.id;

  update public.tasks
  set
    status = 'assigned',
    completed_at = null,
    completed_by = null,
    rejection_reason = p_reason,
    rejected_at = now(),
    rejected_by = v_current_user_id,
    updated_at = now()
  where id = p_task_id;

  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id
  ) values (
    v_task_household,
    v_approval.submitted_by,
    v_current_user_id,
    'Tarea no aprobada',
    coalesce(p_reason, 'Tu tarea "' || v_approval.task_title || '" necesita ajustes.'),
    'task_rejected',
    'task',
    p_task_id
  );

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    v_current_user_id,
    v_task_household,
    'reject_task',
    'task_approval',
    v_approval.id,
    jsonb_build_object('task_id', p_task_id, 'reason', p_reason),
    coalesce(p_reason, 'Rejected'),
    'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Task rejected',
    'status', 'rejected',
    'task_status', 'assigned',
    'approval_id', v_approval.id
  );
end;
$$;

grant execute on function public.reject_task_v1(text, uuid, uuid, uuid, text)
  to authenticated, service_role;

create or replace function public.reject_task_transaction(
  p_request_id text,
  p_user_id uuid,
  p_task_id uuid,
  p_rejected_by uuid,
  p_reason text default null
)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select public.reject_task_v1(
    p_request_id, p_user_id, p_task_id, p_rejected_by, p_reason
  );
$$;

grant execute on function public.reject_task_transaction(text, uuid, uuid, uuid, text)
  to authenticated, service_role;
