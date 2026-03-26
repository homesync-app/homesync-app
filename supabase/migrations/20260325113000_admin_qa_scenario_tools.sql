create or replace function public.qa_admin_require_access()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid;
  v_is_admin boolean;
begin
  v_actor_id := public.current_app_user_id();

  if v_actor_id is null then
    raise exception 'Debes iniciar sesion para usar herramientas QA admin';
  end if;

  select coalesce(is_admin, false)
    into v_is_admin
  from public.users
  where id = v_actor_id;

  if not coalesce(v_is_admin, false) then
    raise exception 'Solo los usuarios admin pueden usar herramientas QA';
  end if;

  return v_actor_id;
end;
$$;

create or replace function public.qa_admin_ensure_identity(
  p_user_id uuid,
  p_email text,
  p_full_name text,
  p_avatar_url text default null,
  p_is_admin boolean default false
)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_now timestamptz := timezone('utc', now());
begin
  insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    is_sso_user,
    is_anonymous
  )
  values (
    null,
    p_user_id,
    'authenticated',
    'authenticated',
    lower(p_email),
    '',
    v_now,
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    jsonb_build_object('qa', true, 'full_name', p_full_name),
    v_now,
    v_now,
    false,
    false
  )
  on conflict (id) do update
    set email = excluded.email,
        updated_at = v_now,
        raw_user_meta_data = coalesce(auth.users.raw_user_meta_data, '{}'::jsonb)
          || jsonb_build_object('qa', true, 'full_name', p_full_name);

  insert into public.users (
    id,
    email,
    full_name,
    avatar_url,
    is_admin,
    updated_at
  )
  values (
    p_user_id,
    lower(p_email),
    p_full_name,
    p_avatar_url,
    p_is_admin,
    v_now
  )
  on conflict (id) do update
    set email = excluded.email,
        full_name = excluded.full_name,
        avatar_url = excluded.avatar_url,
        is_admin = excluded.is_admin,
        updated_at = v_now;
end;
$$;

create or replace function public.qa_admin_household_defaults(
  p_household_id uuid
)
returns table (
  household_name text,
  household_type text,
  display_name text
)
language sql
immutable
as $$
  select
    case p_household_id
      when '11111111-1111-1111-1111-111111111111'::uuid then 'Testing: Solo'
      when '22222222-2222-2222-2222-222222222222'::uuid then 'Testing: Pareja'
      when '33333333-3333-3333-3333-333333333333'::uuid then 'Testing: Amigos'
      when '44444444-4444-4444-4444-444444444444'::uuid then 'Testing: Familia'
      else null
    end,
    case p_household_id
      when '11111111-1111-1111-1111-111111111111'::uuid then 'solo'
      when '22222222-2222-2222-2222-222222222222'::uuid then 'couple'
      when '33333333-3333-3333-3333-333333333333'::uuid then 'friends'
      when '44444444-4444-4444-4444-444444444444'::uuid then 'family'
      else null
    end,
    case p_household_id
      when '11111111-1111-1111-1111-111111111111'::uuid then 'Modo Solo QA'
      when '22222222-2222-2222-2222-222222222222'::uuid then 'Modo Pareja QA'
      when '33333333-3333-3333-3333-333333333333'::uuid then 'Modo Amigos QA'
      when '44444444-4444-4444-4444-444444444444'::uuid then 'Modo Familia QA'
      else null
    end;
$$;

create or replace function public.qa_admin_seed_scenario_members(
  p_household_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_household_id = '11111111-1111-1111-1111-111111111111'::uuid then
    perform public.qa_admin_ensure_identity(
      '11110000-0000-0000-0000-000000000001'::uuid,
      'qa.solo.luna@homesync.local',
      'Luna',
      '🧘'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values (p_household_id, '11110000-0000-0000-0000-000000000001'::uuid, 'owner', 'Usuario Solo')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;

  elsif p_household_id = '22222222-2222-2222-2222-222222222222'::uuid then
    perform public.qa_admin_ensure_identity(
      '22220000-0000-0000-0000-000000000001'::uuid,
      'qa.couple.alex@homesync.local',
      'Alex',
      '🦊'
    );
    perform public.qa_admin_ensure_identity(
      '22220000-0000-0000-0000-000000000002'::uuid,
      'qa.couple.mora@homesync.local',
      'Mora',
      '🐰'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values
      (p_household_id, '22220000-0000-0000-0000-000000000001'::uuid, 'owner', 'Pareja A'),
      (p_household_id, '22220000-0000-0000-0000-000000000002'::uuid, 'member', 'Pareja B')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;

  elsif p_household_id = '33333333-3333-3333-3333-333333333333'::uuid then
    perform public.qa_admin_ensure_identity(
      '33330000-0000-0000-0000-000000000001'::uuid,
      'qa.friends.nico@homesync.local',
      'Nico',
      '😎'
    );
    perform public.qa_admin_ensure_identity(
      '33330000-0000-0000-0000-000000000002'::uuid,
      'qa.friends.cami@homesync.local',
      'Cami',
      '🌻'
    );
    perform public.qa_admin_ensure_identity(
      '33330000-0000-0000-0000-000000000003'::uuid,
      'qa.friends.juli@homesync.local',
      'Juli',
      '🎧'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values
      (p_household_id, '33330000-0000-0000-0000-000000000001'::uuid, 'owner', 'Amigo 1'),
      (p_household_id, '33330000-0000-0000-0000-000000000002'::uuid, 'member', 'Amigo 2'),
      (p_household_id, '33330000-0000-0000-0000-000000000003'::uuid, 'member', 'Amigo 3')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;

  elsif p_household_id = '44444444-4444-4444-4444-444444444444'::uuid then
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000001'::uuid,
      'qa.family.leo@homesync.local',
      'Leo',
      '🧔'
    );
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000002'::uuid,
      'qa.family.ana@homesync.local',
      'Ana',
      '👩'
    );
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000003'::uuid,
      'qa.family.tomi@homesync.local',
      'Tomi',
      '🧒'
    );
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000004'::uuid,
      'qa.family.mili@homesync.local',
      'Mili',
      '👧'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values
      (p_household_id, '44440000-0000-0000-0000-000000000001'::uuid, 'owner', 'Papá'),
      (p_household_id, '44440000-0000-0000-0000-000000000002'::uuid, 'member', 'Mamá'),
      (p_household_id, '44440000-0000-0000-0000-000000000003'::uuid, 'member', 'Hijo 1'),
      (p_household_id, '44440000-0000-0000-0000-000000000004'::uuid, 'member', 'Hija 1')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;
  else
    raise exception 'El hogar % no es un escenario QA conocido', p_household_id;
  end if;
end;
$$;

create or replace function public.qa_admin_reset_scenario_internal(
  p_household_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_household_name text;
  v_household_type text;
  v_display_name text;
begin
  select household_name, household_type, display_name
    into v_household_name, v_household_type, v_display_name
  from public.qa_admin_household_defaults(p_household_id);

  if v_household_name is null then
    raise exception 'Escenario QA invalido';
  end if;

  update public.expenses
    set planned_expense_id = null
  where household_id = p_household_id;

  update public.planned_expenses
    set expense_id = null
  where household_id = p_household_id;

  delete from public.expense_splits
  where expense_id in (
    select id from public.expenses where household_id = p_household_id
  );

  delete from public.reward_redemptions where household_id = p_household_id;
  delete from public.notifications where household_id = p_household_id;
  delete from public.shopping_items where household_id = p_household_id;
  delete from public.household_activities where household_id = p_household_id;
  delete from public.household_invitations where household_id = p_household_id;
  delete from public.ledger_entries where household_id = p_household_id;
  delete from public.weekly_winners where household_id = p_household_id;
  delete from public.weekly_duel_history where household_id = p_household_id;
  delete from public.audit_logs where household_id = p_household_id;
  delete from public.integrity_checks where household_id = p_household_id;
  delete from public.system_events where household_id = p_household_id;

  delete from public.savings_contributions
  where goal_id in (
    select id from public.savings_goals where household_id = p_household_id
  );

  delete from public.savings_goals where household_id = p_household_id;

  delete from public.expense_template_history
  where template_id in (
    select id from public.expense_templates where household_id = p_household_id
  );

  delete from public.planned_expenses where household_id = p_household_id;
  delete from public.expense_templates where household_id = p_household_id;
  delete from public.rewards where household_id = p_household_id;
  delete from public.expenses where household_id = p_household_id;
  delete from public.tasks where household_id = p_household_id;
  delete from public.household_members where household_id = p_household_id;

  update public.households
    set name = v_household_name,
        household_type = v_household_type,
        display_name = v_display_name,
        updated_at = timezone('utc', now())
  where id = p_household_id;

  perform public.qa_admin_seed_scenario_members(p_household_id);

  insert into public.system_events (
    event_type,
    entity_type,
    entity_id,
    household_id,
    operation,
    result,
    source,
    metadata
  )
  values (
    'qa_scenario_reset',
    'household',
    p_household_id,
    p_household_id,
    'reset',
    'success',
    'qa_admin',
    jsonb_build_object('household_type', v_household_type)
  );

  return jsonb_build_object(
    'success', true,
    'household_id', p_household_id,
    'household_name', v_household_name,
    'household_type', v_household_type
  );
end;
$$;

create or replace function public.qa_admin_reset_scenario(
  p_household_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid;
begin
  v_actor_id := public.qa_admin_require_access();

  return public.qa_admin_reset_scenario_internal(p_household_id)
    || jsonb_build_object('actor_id', v_actor_id);
end;
$$;

create or replace function public.qa_admin_add_dummy_member(
  p_household_id uuid,
  p_full_name text,
  p_display_role text default null,
  p_avatar_url text default null,
  p_role text default 'member'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid;
  v_user_id uuid := gen_random_uuid();
  v_safe_name text;
  v_email text;
  v_household_type text;
  v_role text := case
    when lower(coalesce(p_role, 'member')) = 'owner' then 'owner'
    else 'member'
  end;
begin
  v_actor_id := public.qa_admin_require_access();

  if nullif(trim(coalesce(p_full_name, '')), '') is null then
    raise exception 'El nombre del miembro es obligatorio';
  end if;

  if not exists (
    select 1
    from public.qa_admin_household_defaults(p_household_id)
    where household_name is not null
  ) then
    raise exception 'Escenario QA invalido';
  end if;

  select household_type
    into v_household_type
  from public.qa_admin_household_defaults(p_household_id);

  v_safe_name := regexp_replace(lower(trim(p_full_name)), '[^a-z0-9]+', '', 'g');
  if v_safe_name = '' then
    v_safe_name := 'miembro';
  end if;

  v_email := format(
    'qa.%s.%s.%s@homesync.local',
    coalesce(v_household_type, 'scenario'),
    v_safe_name,
    replace(substr(v_user_id::text, 1, 8), '-', '')
  );

  perform public.qa_admin_ensure_identity(
    v_user_id,
    v_email,
    trim(p_full_name),
    nullif(trim(coalesce(p_avatar_url, '')), ''),
    false
  );

  insert into public.household_members (household_id, user_id, role, display_role)
  values (
    p_household_id,
    v_user_id,
    v_role,
    nullif(trim(coalesce(p_display_role, '')), '')
  );

  insert into public.system_events (
    user_id,
    event_type,
    entity_type,
    entity_id,
    household_id,
    operation,
    result,
    source,
    metadata
  )
  values (
    v_actor_id,
    'qa_dummy_member_added',
    'user',
    v_user_id,
    p_household_id,
    'insert',
    'success',
    'qa_admin',
    jsonb_build_object(
      'full_name', trim(p_full_name),
      'display_role', nullif(trim(coalesce(p_display_role, '')), ''),
      'role', v_role
    )
  );

  return jsonb_build_object(
    'success', true,
    'user_id', v_user_id,
    'household_id', p_household_id,
    'full_name', trim(p_full_name),
    'display_role', nullif(trim(coalesce(p_display_role, '')), ''),
    'avatar_url', nullif(trim(coalesce(p_avatar_url, '')), ''),
    'role', v_role
  );
end;
$$;

grant execute on function public.qa_admin_reset_scenario(uuid) to authenticated;
grant execute on function public.qa_admin_add_dummy_member(uuid, text, text, text, text) to authenticated;

select public.qa_admin_reset_scenario_internal('11111111-1111-1111-1111-111111111111'::uuid);
select public.qa_admin_reset_scenario_internal('22222222-2222-2222-2222-222222222222'::uuid);
select public.qa_admin_reset_scenario_internal('33333333-3333-3333-3333-333333333333'::uuid);
select public.qa_admin_reset_scenario_internal('44444444-4444-4444-4444-444444444444'::uuid);
