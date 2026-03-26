create or replace function public.qa_admin_get_tasks(
  p_household_id uuid
)
returns setof public.tasks
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

  return query
  select t.*
  from public.tasks t
  where t.household_id = p_household_id
  order by t.created_at desc;
end;
$$;

create or replace function public.qa_admin_create_task(
  p_household_id uuid,
  p_created_by uuid,
  p_title text,
  p_description text default null,
  p_category text default null,
  p_assigned_to uuid default null,
  p_type text default 'one_time',
  p_difficulty text default 'medium',
  p_xp_reward integer default 0,
  p_coin_reward integer default 0,
  p_priority text default 'medium',
  p_due_at timestamptz default null,
  p_recurrence_type text default null,
  p_recurrence_interval integer default 1,
  p_recurrence_end_at timestamptz default null,
  p_recurrence_weekdays integer[] default '{}'::integer[],
  p_recurrence_month_days integer[] default '{}'::integer[]
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_task_id uuid := gen_random_uuid();
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
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = p_created_by
  ) then
    raise exception 'El creador no pertenece al hogar QA seleccionado';
  end if;

  if p_assigned_to is not null and not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = p_assigned_to
  ) then
    raise exception 'El miembro asignado no pertenece al hogar QA seleccionado';
  end if;

  insert into public.tasks (
    id,
    household_id,
    assigned_to,
    created_by_id,
    title,
    description,
    category,
    type,
    difficulty,
    xp_reward,
    coin_reward,
    priority,
    due_at,
    status,
    recurrence_type,
    recurrence_interval,
    recurrence_end_at,
    recurrence_weekdays,
    recurrence_month_days
  ) values (
    v_task_id,
    p_household_id,
    p_assigned_to,
    p_created_by,
    p_title,
    nullif(trim(coalesce(p_description, '')), ''),
    p_category,
    p_type,
    p_difficulty,
    p_xp_reward,
    p_coin_reward,
    p_priority,
    p_due_at,
    'active',
    p_recurrence_type,
    p_recurrence_interval,
    p_recurrence_end_at,
    p_recurrence_weekdays,
    p_recurrence_month_days
  );

  return v_task_id;
end;
$$;

create or replace function public.qa_admin_get_shopping_items(
  p_household_id uuid
)
returns table (
  id uuid,
  household_id uuid,
  name text,
  quantity text,
  unit text,
  category text,
  emoji text,
  note text,
  added_by uuid,
  completed boolean,
  completed_by uuid,
  completed_at timestamptz,
  created_at timestamptz,
  should_sync boolean,
  added_by_name text,
  completed_by_name text
)
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

  return query
  select
    si.id,
    si.household_id,
    si.name,
    si.quantity,
    si.unit,
    si.category,
    si.emoji,
    si.note,
    si.added_by,
    si.completed,
    si.completed_by,
    si.completed_at,
    si.created_at,
    true as should_sync,
    abu.full_name as added_by_name,
    cbu.full_name as completed_by_name
  from public.shopping_items si
  left join public.users abu on abu.id = si.added_by
  left join public.users cbu on cbu.id = si.completed_by
  where si.household_id = p_household_id
  order by si.completed asc, si.created_at desc;
end;
$$;

create or replace function public.qa_admin_add_shopping_item(
  p_id uuid,
  p_household_id uuid,
  p_name text,
  p_added_by uuid,
  p_quantity text default null,
  p_unit text default null,
  p_category text default 'general',
  p_emoji text default '🛒',
  p_note text default null
)
returns table (
  id uuid,
  household_id uuid,
  name text,
  quantity text,
  unit text,
  category text,
  emoji text,
  note text,
  added_by uuid,
  completed boolean,
  completed_by uuid,
  completed_at timestamptz,
  created_at timestamptz,
  should_sync boolean,
  added_by_name text,
  completed_by_name text
)
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
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = p_added_by
  ) then
    raise exception 'El usuario no pertenece al hogar QA seleccionado';
  end if;

  insert into public.shopping_items (
    id,
    household_id,
    name,
    quantity,
    unit,
    category,
    emoji,
    note,
    added_by,
    completed
  ) values (
    p_id,
    p_household_id,
    trim(p_name),
    nullif(trim(coalesce(p_quantity, '')), ''),
    nullif(trim(coalesce(p_unit, '')), ''),
    p_category,
    p_emoji,
    nullif(trim(coalesce(p_note, '')), ''),
    p_added_by,
    false
  );

  return query
  select * from public.qa_admin_get_shopping_items(p_household_id)
  where qa_admin_get_shopping_items.id = p_id;
end;
$$;

create or replace function public.qa_admin_toggle_shopping_item(
  p_item_id uuid,
  p_household_id uuid,
  p_completed boolean,
  p_user_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.qa_admin_require_access();

  update public.shopping_items
  set
    completed = p_completed,
    completed_by = case when p_completed then p_user_id else null end,
    completed_at = case when p_completed then timezone('utc', now()) else null end
  where id = p_item_id
    and household_id = p_household_id;
end;
$$;

create or replace function public.qa_admin_delete_shopping_item(
  p_item_id uuid,
  p_household_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.qa_admin_require_access();

  delete from public.shopping_items
  where id = p_item_id
    and household_id = p_household_id;
end;
$$;

create or replace function public.qa_admin_clear_completed_shopping_items(
  p_household_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.qa_admin_require_access();

  delete from public.shopping_items
  where household_id = p_household_id
    and completed = true;
end;
$$;

create or replace function public.qa_admin_uncomplete_all_shopping_items(
  p_household_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.qa_admin_require_access();

  update public.shopping_items
  set
    completed = false,
    completed_by = null,
    completed_at = null
  where household_id = p_household_id
    and completed = true;
end;
$$;

grant execute on function public.qa_admin_get_tasks(uuid) to authenticated;
grant execute on function public.qa_admin_create_task(uuid, uuid, text, text, text, uuid, text, text, integer, integer, text, timestamptz, text, integer, timestamptz, integer[], integer[]) to authenticated;
grant execute on function public.qa_admin_get_shopping_items(uuid) to authenticated;
grant execute on function public.qa_admin_add_shopping_item(uuid, uuid, text, uuid, text, text, text, text, text) to authenticated;
grant execute on function public.qa_admin_toggle_shopping_item(uuid, uuid, boolean, uuid) to authenticated;
grant execute on function public.qa_admin_delete_shopping_item(uuid, uuid) to authenticated;
grant execute on function public.qa_admin_clear_completed_shopping_items(uuid) to authenticated;
grant execute on function public.qa_admin_uncomplete_all_shopping_items(uuid) to authenticated;
