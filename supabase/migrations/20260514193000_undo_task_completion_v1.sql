-- =============================================================================
-- undo_task_completion_v1
-- =============================================================================
-- Versiona el undo de tareas completadas y deja el nombre legacy como wrapper.
-- El comando revierte recompensas vinculadas a la activity, borra la activity
-- completada y limpia los campos de completion de la tarea sin depender de una
-- funcion historica que no esta presente en las migraciones locales.
-- =============================================================================

create or replace function public.undo_task_completion_v1(
  p_activity_id uuid,
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_current_user_id uuid := public.current_app_user_id();
  v_activity public.household_activities%rowtype;
  v_task_id uuid;
  v_is_admin boolean := false;
  v_deleted_ledger_count integer := 0;
  v_deleted_activity_count integer := 0;
  v_previous_completed_at timestamptz;
  v_previous_completed_by uuid;
begin
  if v_current_user_id is null then
    return jsonb_build_object(
      'success', false,
      'status', 'unauthenticated',
      'message', 'Not authenticated'
    );
  end if;

  if p_user_id is distinct from v_current_user_id then
    return jsonb_build_object(
      'success', false,
      'status', 'forbidden',
      'message', 'User mismatch'
    );
  end if;

  select *
    into v_activity
  from public.household_activities
  where id = p_activity_id
    and event_type = 'task_completed'
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'status', 'not_found',
      'message', 'Task completion activity not found'
    );
  end if;

  v_task_id := nullif(v_activity.metadata ->> 'task_id', '')::uuid;

  if v_task_id is null then
    return jsonb_build_object(
      'success', false,
      'status', 'invalid',
      'message', 'Activity has no task_id metadata'
    );
  end if;

  if not public.is_current_household_member(v_activity.household_id) then
    return jsonb_build_object(
      'success', false,
      'status', 'forbidden',
      'message', 'Not a household member'
    );
  end if;

  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_activity.household_id
      and hm.user_id = v_current_user_id
      and hm.role in ('owner', 'admin')
  )
  into v_is_admin;

  if not v_is_admin and v_activity.user_id is distinct from v_current_user_id then
    return jsonb_build_object(
      'success', false,
      'status', 'forbidden',
      'message', 'Only the performer or a household admin can undo this task'
    );
  end if;

  delete from public.ledger_entries le
  where le.reference_type = 'activity'
    and le.reference_id = p_activity_id::text
    and le.type in ('xp_earned', 'coins_earned');

  get diagnostics v_deleted_ledger_count = row_count;

  delete from public.household_activities ha
  where ha.id = p_activity_id
    and ha.household_id = v_activity.household_id;

  get diagnostics v_deleted_activity_count = row_count;

  if v_deleted_activity_count <> 1 then
    return jsonb_build_object(
      'success', false,
      'status', 'not_deleted',
      'message', 'Completion activity was not deleted'
    );
  end if;

  select ha.created_at, ha.user_id
    into v_previous_completed_at, v_previous_completed_by
  from public.household_activities ha
  where ha.household_id = v_activity.household_id
    and ha.event_type = 'task_completed'
    and ha.metadata ->> 'task_id' = v_task_id::text
  order by ha.created_at desc
  limit 1;

  update public.tasks t
  set
    status = 'active',
    completed_at = v_previous_completed_at,
    completed_by = v_previous_completed_by,
    last_completed_at = v_previous_completed_at,
    verified_by = null,
    verified_at = null,
    last_verified_by = null,
    rejection_reason = null,
    rejected_at = null,
    rejected_by = null,
    updated_at = now()
  where t.id = v_task_id
    and t.household_id = v_activity.household_id;

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    'undo:' || p_activity_id::text,
    v_current_user_id,
    v_activity.household_id,
    'undo_task_completion',
    'task',
    v_task_id,
    jsonb_build_object(
      'activity_id', p_activity_id,
      'metadata', v_activity.metadata,
      'deleted_ledger_entries', v_deleted_ledger_count,
      'previous_completed_at', v_previous_completed_at,
      'previous_completed_by', v_previous_completed_by
    ),
    'Completion undone',
    'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'status', 'undone',
    'message', 'Task completion undone',
    'task_id', v_task_id,
    'activity_id', p_activity_id,
    'household_id', v_activity.household_id,
    'deleted_ledger_entries', v_deleted_ledger_count,
    'previous_completed_at', v_previous_completed_at,
    'previous_completed_by', v_previous_completed_by
  );
end;
$$;

grant execute on function public.undo_task_completion_v1(uuid, uuid)
  to authenticated, service_role;

create or replace function public.undo_task_completion(
  p_activity_id uuid,
  p_user_id uuid
)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select public.undo_task_completion_v1(p_activity_id, p_user_id);
$$;

grant execute on function public.undo_task_completion(uuid, uuid)
  to authenticated, service_role;
