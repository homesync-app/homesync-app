-- Resolve remaining finance correctness and legacy RPC authorization debt.
-- Public compatibility signatures remain stable, but all mutations derive the
-- actor and server-authoritative values instead of trusting client parameters.

create or replace function public.get_debts(p_household_id uuid)
returns table (
  debtor_id uuid,
  debtor_email text,
  creditor_id uuid,
  creditor_email text,
  amount decimal
)
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_debtor_ids uuid[];
  v_debtor_emails text[];
  v_debts numeric[];
  v_creditor_ids uuid[];
  v_creditor_emails text[];
  v_credits numeric[];
  v_debtor_index integer := 1;
  v_creditor_index integer := 1;
  v_transfer numeric;
begin
  if not coalesce(public.is_current_household_member(p_household_id), false) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  with balances as (
    select
      balance_row.user_id,
      balance_row.user_email,
      round(balance_row.balance, 2) as balance
    from public.get_expense_balance(p_household_id) balance_row
  )
  select
    array_agg(b.user_id order by abs(b.balance) desc, b.user_id),
    array_agg(b.user_email order by abs(b.balance) desc, b.user_id),
    array_agg(abs(b.balance) order by abs(b.balance) desc, b.user_id)
  into v_debtor_ids, v_debtor_emails, v_debts
  from balances b
  where b.balance < -0.005;

  with balances as (
    select
      balance_row.user_id,
      balance_row.user_email,
      round(balance_row.balance, 2) as balance
    from public.get_expense_balance(p_household_id) balance_row
  )
  select
    array_agg(b.user_id order by b.balance desc, b.user_id),
    array_agg(b.user_email order by b.balance desc, b.user_id),
    array_agg(b.balance order by b.balance desc, b.user_id)
  into v_creditor_ids, v_creditor_emails, v_credits
  from balances b
  where b.balance > 0.005;

  while v_debtor_index <= coalesce(cardinality(v_debts), 0)
      and v_creditor_index <= coalesce(cardinality(v_credits), 0) loop
    v_transfer := round(
      least(v_debts[v_debtor_index], v_credits[v_creditor_index]),
      2
    );

    if v_transfer > 0 then
      debtor_id := v_debtor_ids[v_debtor_index];
      debtor_email := v_debtor_emails[v_debtor_index];
      creditor_id := v_creditor_ids[v_creditor_index];
      creditor_email := v_creditor_emails[v_creditor_index];
      amount := v_transfer;
      return next;
    end if;

    v_debts[v_debtor_index] :=
      round(v_debts[v_debtor_index] - v_transfer, 2);
    v_credits[v_creditor_index] :=
      round(v_credits[v_creditor_index] - v_transfer, 2);

    if v_debts[v_debtor_index] <= 0.005 then
      v_debtor_index := v_debtor_index + 1;
    end if;
    if v_credits[v_creditor_index] <= 0.005 then
      v_creditor_index := v_creditor_index + 1;
    end if;
  end loop;
end;
$function$;

revoke execute on function public.get_debts(uuid)
  from public, anon, service_role;
grant execute on function public.get_debts(uuid)
  to authenticated;

comment on function public.get_debts(uuid) is
  'Returns a deterministic minimal debtor-to-creditor settlement plan using the canonical household balances.';

-- The admin portal authenticates as an authenticated Supabase user and relies
-- on is_current_app_admin(); service_role is never shipped to the frontend.
create or replace function public.admin_get_all_households()
returns table (
  id uuid,
  name text,
  household_type text,
  owner_email text,
  member_count bigint,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $function$
begin
  if not coalesce(public.is_current_app_admin(), false) then
    raise exception 'Admin access required' using errcode = '42501';
  end if;

  return query
  select
    h.id,
    h.name,
    h.household_type,
    owner_info.email,
    (
      select count(*)
      from public.household_members counted_member
      where counted_member.household_id = h.id
    ),
    h.created_at
  from public.households h
  left join lateral (
    select owner_user.email
    from public.household_members owner_member
    join public.users owner_user on owner_user.id = owner_member.user_id
    where owner_member.household_id = h.id
      and owner_member.role = 'owner'
    order by owner_member.user_id
    limit 1
  ) owner_info on true
  order by h.created_at desc;
end;
$function$;

revoke execute on function public.admin_get_all_households()
  from public, anon, service_role;
grant execute on function public.admin_get_all_households()
  to authenticated;

comment on function public.admin_get_all_households() is
  'Authenticated-admin-only household inventory. The frontend must use an anon key plus an authenticated admin session, never service_role.';

-- Route both installed-client legacy signatures through the authorized public
-- completion boundary. The old eight-argument implementation was a bypass.
create or replace function public.complete_task_transaction(
  p_request_id text,
  p_user_ids uuid[],
  p_task_id uuid,
  p_household_id uuid,
  p_xp_reward integer,
  p_coin_reward integer,
  p_task_title text,
  p_completed_at timestamptz default null
) returns jsonb
language sql
security definer
set search_path = ''
as $function$
  select public.complete_task_v1(
    p_request_id,
    p_user_ids,
    p_task_id,
    p_household_id,
    p_xp_reward,
    p_coin_reward,
    p_task_title,
    p_completed_at
  );
$function$;

create or replace function public.complete_task_transaction(
  p_request_id text,
  p_user_ids uuid[],
  p_task_id uuid,
  p_household_id uuid,
  p_xp_reward integer,
  p_coin_reward integer,
  p_task_title text
) returns jsonb
language sql
security definer
set search_path = ''
as $function$
  select public.complete_task_v1(
    p_request_id,
    p_user_ids,
    p_task_id,
    p_household_id,
    p_xp_reward,
    p_coin_reward,
    p_task_title,
    null::timestamptz
  );
$function$;

revoke execute on function public.complete_task_transaction(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) from public, anon;
revoke execute on function public.complete_task_transaction(
  text, uuid[], uuid, uuid, integer, integer, text
) from public, anon;
grant execute on function public.complete_task_transaction(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) to authenticated, service_role;
grant execute on function public.complete_task_transaction(
  text, uuid[], uuid, uuid, integer, integer, text
) to authenticated, service_role;

-- Preserve the obsolete join signature for installed clients, but reject a
-- forged user ID and delegate all invitation semantics to the current RPC.
create or replace function public.join_household(
  p_code text,
  p_user_id uuid
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := public.current_app_user_id();
begin
  if v_actor is null then
    return jsonb_build_object(
      'success', false,
      'error', 'unauthenticated',
      'message', 'Not authenticated'
    );
  end if;

  if p_user_id is distinct from v_actor then
    return jsonb_build_object(
      'success', false,
      'error', 'forbidden',
      'message', 'User mismatch'
    );
  end if;

  return public.join_household_by_code(p_code);
end;
$function$;

revoke execute on function public.join_household(text, uuid)
  from public, anon, service_role;
grant execute on function public.join_household(text, uuid)
  to authenticated;

create or replace function public.reconcile_points_and_history(
  p_household_id uuid
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_fixed_activities integer := 0;
begin
  if not coalesce(public.is_current_household_member(p_household_id), false) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  insert into public.household_activities (
    household_id, user_id, event_type, title, metadata, created_at
  )
  select
    task_row.household_id,
    coalesce(task_row.completed_by, task_row.assigned_to),
    'task_completed',
    task_row.title,
    jsonb_build_object(
      'xp', task_row.xp_reward,
      'coins', task_row.coin_reward,
      'category', task_row.category,
      'task_id', task_row.id
    ),
    coalesce(task_row.completed_at, task_row.updated_at)
  from public.tasks task_row
  where task_row.household_id = p_household_id
    and task_row.status in ('pending_verification', 'verified', 'objected')
    and not exists (
      select 1
      from public.household_activities activity
      where activity.metadata ->> 'task_id' = task_row.id::text
    );

  get diagnostics v_fixed_activities = row_count;

  return jsonb_build_object(
    'success', true,
    'activities_reconstructed', v_fixed_activities,
    'message', 'Data reconciliation completed'
  );
end;
$function$;

revoke execute on function public.reconcile_points_and_history(uuid)
  from public, anon, service_role;
grant execute on function public.reconcile_points_and_history(uuid)
  to authenticated;

-- Harden the legacy objection pair. Both functions now derive the actor from
-- JWT claims and constrain activity/ledger mutations to the selected task.
create or replace function public.object_task_v2(
  p_task_id uuid,
  p_user_id uuid,
  p_reason text,
  p_activity_id uuid default null
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_task public.tasks%rowtype;
  v_activity_id uuid := p_activity_id;
begin
  if v_actor is null then
    return jsonb_build_object('success', false, 'status', 'unauthenticated');
  end if;

  if p_user_id is distinct from v_actor then
    return jsonb_build_object('success', false, 'status', 'forbidden');
  end if;

  select task_row.*
  into v_task
  from public.tasks task_row
  where task_row.id = p_task_id
  for update;

  if not found then
    return jsonb_build_object('success', false, 'status', 'not_found');
  end if;

  if not coalesce(public.is_current_household_member(v_task.household_id), false)
      or v_task.completed_by is not distinct from v_actor then
    return jsonb_build_object('success', false, 'status', 'forbidden');
  end if;

  if v_task.status not in ('pending_verification', 'verified') then
    return jsonb_build_object('success', false, 'status', 'invalid_state');
  end if;

  if v_activity_id is null then
    select activity.id
    into v_activity_id
    from public.household_activities activity
    where activity.household_id = v_task.household_id
      and activity.metadata ->> 'task_id' = p_task_id::text
      and activity.event_type = 'task_completed'
    order by activity.created_at desc
    limit 1;
  elsif not exists (
    select 1
    from public.household_activities activity
    where activity.id = v_activity_id
      and activity.household_id = v_task.household_id
      and activity.metadata ->> 'task_id' = p_task_id::text
  ) then
    return jsonb_build_object('success', false, 'status', 'invalid_activity');
  end if;

  update public.tasks
  set status = 'objected',
      objection_reason = p_reason,
      objected_by = v_actor,
      objected_at = now(),
      updated_at = now()
  where id = p_task_id;

  if v_activity_id is not null then
    delete from public.ledger_entries entry
    where entry.reference_id = v_activity_id::text
      and entry.reference_type = 'activity'
      and entry.household_id = v_task.household_id;

    update public.household_activities activity
    set description = concat_ws(
      ' ',
      nullif(activity.description, ''),
      '(OBJETADA: ' || coalesce(nullif(trim(p_reason), ''), 'Sin motivo') || ')'
    )
    where activity.id = v_activity_id;
  end if;

  return jsonb_build_object(
    'success', true,
    'status', 'objected',
    'activity_id', v_activity_id
  );
end;
$function$;

revoke execute on function public.object_task_v2(uuid, uuid, text, uuid)
  from public, anon, service_role;
grant execute on function public.object_task_v2(uuid, uuid, text, uuid)
  to authenticated;

create or replace function public.restore_task_coins(
  p_task_id uuid,
  p_user_id uuid
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_task public.tasks%rowtype;
begin
  if v_actor is null then
    return jsonb_build_object('success', false, 'status', 'unauthenticated');
  end if;

  if p_user_id is distinct from v_actor then
    return jsonb_build_object('success', false, 'status', 'forbidden');
  end if;

  select task_row.*
  into v_task
  from public.tasks task_row
  where task_row.id = p_task_id
  for update;

  if not found then
    return jsonb_build_object('success', false, 'status', 'not_found');
  end if;

  if not coalesce(public.is_current_household_member(v_task.household_id), false)
      or (
        v_task.objected_by is distinct from v_actor
        and not private.is_adult_household_admin(v_task.household_id, null)
      ) then
    return jsonb_build_object('success', false, 'status', 'forbidden');
  end if;

  if v_task.status <> 'objected' then
    return jsonb_build_object('success', false, 'status', 'invalid_state');
  end if;

  update public.tasks
  set status = 'verified',
      objection_reason = null,
      objected_by = null,
      objected_at = null,
      updated_at = now()
  where id = p_task_id;

  if coalesce(v_task.coin_reward, 0) > 0 and v_task.completed_by is not null then
    insert into public.ledger_entries (
      user_id, household_id, amount, currency, type, description,
      reference_type, reference_id
    ) values (
      v_task.completed_by,
      v_task.household_id,
      v_task.coin_reward,
      'COIN',
      'coins_restored',
      'Coins restaurados',
      'task',
      p_task_id::text
    )
    on conflict (user_id, type, reference_id) do nothing;
  end if;

  return jsonb_build_object('success', true, 'status', 'verified');
end;
$function$;

revoke execute on function public.restore_task_coins(uuid, uuid)
  from public, anon, service_role;
grant execute on function public.restore_task_coins(uuid, uuid)
  to authenticated;

-- Remove genuine dead locals while preserving public signatures. Source
-- patches are guarded so replay fails loudly if an upstream definition drifts.
do $$
declare
  v_source text;
  v_patched text;
begin
  v_source := replace(
    pg_get_functiondef(
      'public.calculate_task_effective_due_at(timestamptz,text,integer,timestamptz,integer[],integer[])'::regprocedure
    ),
    E'\r\n',
    E'\n'
  );
  if position(E'  v_days_ahead integer;\n' in v_source) > 0 then
    v_patched := replace(v_source, E'  v_days_ahead integer;\n', '');
    if v_patched = v_source
        or position(E'  v_days_ahead integer;\n' in v_patched) > 0 then
      raise exception 'calculate_task_effective_due_at dead local not removed';
    end if;
    execute v_patched;
  end if;

  v_source := replace(
    pg_get_functiondef(
      'public.get_weekly_family_summary(uuid,timestamptz)'::regprocedure
    ),
    E'\r\n',
    E'\n'
  );
  if position('v_prev_rate' in v_source) > 0 then
    v_patched := replace(v_source, E'  v_prev_rate numeric;\n', '');
    v_patched := regexp_replace(
      v_patched,
      E'  v_prev_rate := case\n    when v_prev_done = 0 and v_tasks_done = 0 then 1\n    when v_prev_done = 0 then 0\n    else null  -- no comparamos tasa, solo done counts\n  end;\n',
      '',
      'g'
    );
    if v_patched = v_source
        or position('v_prev_rate' in v_patched) > 0 then
      raise exception 'get_weekly_family_summary dead calculation not removed';
    end if;
    execute v_patched;
  end if;
end;
$$;

-- These obsolete mutation endpoints have no current Flutter, admin, Edge
-- Function or SQL callers. Keep their signatures for schema compatibility,
-- but make them owner-only instead of exposing client-trusted parameters.
revoke execute on function public.create_expense(
  uuid, uuid, text, numeric, uuid, text, text, text, text, uuid[]
) from public, anon, authenticated, service_role;
comment on function public.create_expense(
  uuid, uuid, text, numeric, uuid, text, text, text, text, uuid[]
) is 'Deprecated and disabled. Use save_expense_v4.';

revoke execute on function public.create_next_recurring_task(uuid, uuid)
  from public, anon, authenticated, service_role;
comment on function public.create_next_recurring_task(uuid, uuid) is
  'Deprecated and disabled. Recurrence is materialized by the current task command flow.';
