create or replace function public.qa_admin_get_rewards(
  p_household_id uuid
)
returns setof public.rewards
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
  select r.*
  from public.rewards r
  where r.household_id = p_household_id
  order by r.created_at desc;
end;
$$;

create or replace function public.qa_admin_seed_default_rewards(
  p_household_id uuid
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_created_by uuid;
  v_inserted_count integer := 0;
begin
  perform public.qa_admin_require_access();

  if not exists (
    select 1
    from public.qa_admin_household_defaults(p_household_id)
    where household_name is not null
  ) then
    raise exception 'Escenario QA invalido';
  end if;

  if exists (
    select 1
    from public.rewards
    where household_id = p_household_id
  ) then
    return 0;
  end if;

  select hm.user_id
    into v_created_by
  from public.household_members hm
  where hm.household_id = p_household_id
  order by case when hm.role = 'owner' then 0 else 1 end, hm.joined_at, hm.user_id
  limit 1;

  insert into public.rewards (
    household_id,
    title,
    description,
    cost,
    icon,
    is_active,
    created_by,
    is_approved,
    category
  )
  select
    p_household_id,
    rt.title,
    rt.description,
    rt.cost,
    coalesce(rt.icon, '🎁'),
    true,
    v_created_by,
    true,
    rt.category
  from public.reward_templates rt
  order by rt.sort_order, rt.created_at, rt.title;

  get diagnostics v_inserted_count = row_count;
  return v_inserted_count;
end;
$$;

create or replace function public.qa_admin_get_member_activity_stats(
  p_household_id uuid
)
returns table (
  user_id uuid,
  user_name text,
  avatar_url text,
  tasks_completed integer,
  xp_earned integer,
  coins_earned integer
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
    u.id,
    u.full_name,
    u.avatar_url,
    0::integer as tasks_completed,
    0::integer as xp_earned,
    0::integer as coins_earned
  from public.household_members hm
  join public.users u on u.id = hm.user_id
  where hm.household_id = p_household_id
  order by case when hm.role = 'owner' then 0 else 1 end, hm.joined_at, u.full_name;
end;
$$;

create or replace function public.qa_admin_get_task_stats_by_category(
  p_household_id uuid
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

  return '[]'::jsonb;
end;
$$;

create or replace function public.qa_admin_get_weekly_ranking(
  p_household_id uuid
)
returns table (
  user_id uuid,
  user_name text,
  avatar_url text,
  xp_earned integer,
  coins_earned integer,
  tasks_completed integer
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
    u.id,
    u.full_name,
    u.avatar_url,
    0::integer as xp_earned,
    0::integer as coins_earned,
    0::integer as tasks_completed
  from public.household_members hm
  join public.users u on u.id = hm.user_id
  where hm.household_id = p_household_id
  order by case when hm.role = 'owner' then 0 else 1 end, hm.joined_at, u.full_name;
end;
$$;

create or replace function public.qa_admin_get_weekly_duel_history(
  p_household_id uuid
)
returns setof public.weekly_duel_history
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
  select h.*
  from public.weekly_duel_history h
  where h.household_id = p_household_id
  order by h.week_start_date desc, h.created_at desc;
end;
$$;

grant execute on function public.qa_admin_get_rewards(uuid) to authenticated;
grant execute on function public.qa_admin_seed_default_rewards(uuid) to authenticated;
grant execute on function public.qa_admin_get_member_activity_stats(uuid) to authenticated;
grant execute on function public.qa_admin_get_task_stats_by_category(uuid) to authenticated;
grant execute on function public.qa_admin_get_weekly_ranking(uuid) to authenticated;
grant execute on function public.qa_admin_get_weekly_duel_history(uuid) to authenticated;
