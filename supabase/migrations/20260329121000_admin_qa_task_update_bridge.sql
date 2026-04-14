create or replace function public.qa_admin_update_task_v1(
  p_household_id uuid,
  p_task_id uuid,
  p_title text default null,
  p_description text default null,
  p_category text default null,
  p_assigned_to uuid default null,
  p_due_at timestamptz default null,
  p_recurrence_type text default null,
  p_recurrence_interval integer default null,
  p_recurrence_weekdays integer[] default null,
  p_recurrence_month_days integer[] default null,
  p_status text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.qa_admin_require_access();

  if not exists (
    select 1
    from public.qa_admin_household_defaults(p_household_id)
    where household_name is not null
  ) then
    raise exception 'Escenario QA invalido';
  end if;

  if not exists (
    select 1
    from public.tasks t
    where t.id = p_task_id
      and t.household_id = p_household_id
  ) then
    raise exception 'Task not found in QA household';
  end if;

  if p_assigned_to is not null and not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = p_assigned_to
  ) then
    raise exception 'El miembro asignado no pertenece al hogar QA seleccionado';
  end if;

  update public.tasks
  set
    title = coalesce(p_title, title),
    description = coalesce(p_description, description),
    category = coalesce(p_category, category),
    assigned_to = case
      when p_assigned_to is not null then p_assigned_to
      else assigned_to
    end,
    due_at = case
      when p_due_at is not null then p_due_at
      else due_at
    end,
    recurrence_type = case
      when p_recurrence_type is not null then p_recurrence_type
      else recurrence_type
    end,
    recurrence_interval = coalesce(p_recurrence_interval, recurrence_interval),
    recurrence_weekdays = coalesce(p_recurrence_weekdays, recurrence_weekdays),
    recurrence_month_days = coalesce(p_recurrence_month_days, recurrence_month_days),
    status = coalesce(p_status, status),
    updated_at = now()
  where id = p_task_id
    and household_id = p_household_id;

  return jsonb_build_object(
    'success', true,
    'task_id', p_task_id,
    'household_id', p_household_id
  );
end;
$$;

grant execute on function public.qa_admin_update_task_v1(uuid, uuid, text, text, text, uuid, timestamptz, text, integer, integer[], integer[], text) to authenticated;
