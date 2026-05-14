create or replace function public.delete_task_v1(
  p_task_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
  v_household_id uuid;
  v_rows_deleted integer := 0;
begin
  if v_uid is null then
    return jsonb_build_object(
      'success', false,
      'status', 'unauthenticated',
      'message', 'Not authenticated'
    );
  end if;

  select t.household_id
  into v_household_id
  from public.tasks t
  where t.id = p_task_id;

  if v_household_id is null then
    return jsonb_build_object(
      'success', false,
      'status', 'not_found',
      'message', 'Task not found'
    );
  end if;

  if not public.is_current_household_owner(v_household_id) then
    return jsonb_build_object(
      'success', false,
      'status', 'forbidden',
      'message', 'Only household owners can delete tasks'
    );
  end if;

  delete from public.household_activities ha
  where ha.household_id = v_household_id
    and (
      (ha.related_entity_type = 'task' and ha.related_entity_id = p_task_id)
      or ha.metadata ->> 'task_id' = p_task_id::text
      or ha.metadata ->> 'id' = p_task_id::text
    );

  delete from public.notifications n
  where n.household_id = v_household_id
    and (
      n.related_entity_type = 'task'
      and n.related_entity_id = p_task_id
    );

  update public.tasks child
  set recurrence_parent_id = null,
      updated_at = now()
  where child.recurrence_parent_id = p_task_id;

  delete from public.tasks t
  where t.id = p_task_id
    and t.household_id = v_household_id;

  get diagnostics v_rows_deleted = row_count;

  return jsonb_build_object(
    'success', v_rows_deleted = 1,
    'status', case when v_rows_deleted = 1 then 'deleted' else 'not_deleted' end,
    'task_id', p_task_id,
    'household_id', v_household_id
  );
end;
$$;

grant execute on function public.delete_task_v1(uuid) to authenticated;

