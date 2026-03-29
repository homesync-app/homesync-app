create or replace function public.qa_admin_complete_task(
  p_household_id uuid,
  p_user_ids uuid[],
  p_task_id uuid,
  p_xp_reward integer,
  p_coin_reward integer,
  p_task_title text,
  p_completed_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid;
  v_user_id uuid;
  v_activity_id uuid;
  v_task_desc text;
  v_task_cat text;
begin
  v_actor_id := public.qa_admin_require_access();

  if not exists (
    select 1
    from public.qa_admin_household_defaults(p_household_id)
    where household_name is not null
  ) then
    raise exception 'Escenario QA invalido';
  end if;

  if p_user_ids is null or coalesce(array_length(p_user_ids, 1), 0) = 0 then
    raise exception 'Debe informarse al menos un usuario';
  end if;

  if exists (
    select 1
    from unnest(p_user_ids) as uid
    where not exists (
      select 1
      from public.household_members hm
      where hm.household_id = p_household_id
        and hm.user_id = uid
    )
  ) then
    raise exception 'Uno o mas usuarios no pertenecen al hogar QA seleccionado';
  end if;

  select description, category
    into v_task_desc, v_task_cat
  from public.tasks
  where id = p_task_id
    and household_id = p_household_id
    and status in (
      'assigned',
      'active',
      'in_progress',
      'objected',
      'pending_approval',
      'pending_verification',
      'verified'
    )
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Task not found or not in completable state',
      'status', 'skipped'
    );
  end if;

  insert into public.household_activities (
    household_id,
    user_id,
    event_type,
    title,
    description,
    metadata
  ) values (
    p_household_id,
    p_user_ids[1],
    'task_completed',
    p_task_title,
    v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'task_title', p_task_title,
      'xp_reward', p_xp_reward,
      'coins_reward', p_coin_reward,
      'performers', p_user_ids,
      'category', v_task_cat
    )
  ) returning id into v_activity_id;

  update public.tasks
  set
    status = 'active',
    completed_at = p_completed_at,
    completed_by = p_user_ids[1],
    last_completed_at = p_completed_at,
    last_verified_by = null,
    updated_at = now()
  where id = p_task_id;

  foreach v_user_id in array p_user_ids
  loop
    if p_xp_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned', p_xp_reward, 'XP', v_activity_id::text, 'activity', 'XP: ' || p_task_title, 'qa_admin', v_actor_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;

    if p_coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned', p_coin_reward, 'COIN', v_activity_id::text, 'activity', 'Coins: ' || p_task_title, 'qa_admin', v_actor_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;
  end loop;

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id, new_value, reason, source
  ) values (
    'qa_admin_' || extract(epoch from now())::bigint,
    v_actor_id,
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object('status', 'active', 'activity_id', v_activity_id, 'performers', p_user_ids),
    'QA admin completed task',
    'qa_admin'
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Task completed',
    'status', 'ok',
    'activity_id', v_activity_id,
    'task_status', 'active',
    'xp_earned', p_xp_reward,
    'coins_earned', p_coin_reward
  );
end;
$$;

create or replace function public.qa_admin_save_expense_v1(
  p_actor_user_id uuid,
  p_id uuid default null,
  p_household_id uuid default null,
  p_title text default null,
  p_amount decimal default null,
  p_category text default null,
  p_paid_by uuid default null,
  p_paid_at timestamptz default now(),
  p_description text default null,
  p_split_type text default 'equal',
  p_is_shared boolean default true,
  p_type text default 'expense',
  p_splits jsonb default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid;
  v_expense_id uuid := p_id;
  v_is_shared boolean := p_is_shared;
  v_member_id uuid;
  v_member_count int;
  v_household_id uuid := p_household_id;
  v_rows_updated int := 0;
begin
  v_actor_id := public.qa_admin_require_access();

  if v_household_id is null then
    raise exception 'Household requerido';
  end if;

  if not exists (
    select 1
    from public.qa_admin_household_defaults(v_household_id)
    where household_name is not null
  ) then
    raise exception 'Escenario QA invalido';
  end if;

  if p_actor_user_id is null then
    raise exception 'Actor requerido';
  end if;

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_household_id
      and hm.user_id = p_actor_user_id
  ) then
    raise exception 'Actor no pertenece al hogar QA seleccionado';
  end if;

  if p_paid_by is null or not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_household_id
      and hm.user_id = p_paid_by
  ) then
    raise exception 'paid_by must be a member of the household';
  end if;

  if lower(coalesce(p_split_type, 'equal')) in ('personal', 'gift') then
    v_is_shared := false;
  end if;

  if v_expense_id is null then
    insert into public.expenses (
      household_id, created_by_id, title, description, category,
      amount, paid_by, paid_at, split_type, is_shared, type
    ) values (
      v_household_id, p_actor_user_id, p_title, p_description, p_category,
      p_amount, p_paid_by, p_paid_at, p_split_type, v_is_shared, p_type::transaction_type
    ) returning id into v_expense_id;
  else
    update public.expenses
    set
      title = p_title,
      description = p_description,
      category = p_category,
      amount = p_amount,
      paid_by = p_paid_by,
      paid_at = p_paid_at,
      split_type = p_split_type,
      is_shared = v_is_shared,
      type = p_type::transaction_type,
      updated_at = now()
    where id = v_expense_id
      and household_id = v_household_id;

    get diagnostics v_rows_updated = row_count;
    if v_rows_updated = 0 then
      raise exception 'Expense not found in QA household';
    end if;

    delete from public.expense_splits where expense_id = v_expense_id;
  end if;

  if lower(coalesce(p_split_type, 'equal')) in ('gift', 'personal') then
    insert into public.expense_splits (expense_id, user_id, amount)
    values (v_expense_id, p_paid_by, p_amount);

  elsif lower(coalesce(p_split_type, 'equal')) = 'equal'
    and (p_splits is null or jsonb_array_length(p_splits) <= 1) then
    select count(*) into v_member_count
    from public.household_members
    where household_id = v_household_id;

    for v_member_id in
      select user_id from public.household_members where household_id = v_household_id
    loop
      insert into public.expense_splits (expense_id, user_id, amount)
      values (v_expense_id, v_member_id, p_amount / nullif(v_member_count, 0));
    end loop;

  elsif p_splits is not null then
    if exists (
      select 1
      from jsonb_array_elements(p_splits) s
      where not exists (
        select 1
        from public.household_members hm
        where hm.household_id = v_household_id
          and hm.user_id = (s->>'user_id')::uuid
      )
    ) then
      raise exception 'One or more split users are not household members';
    end if;

    insert into public.expense_splits (expense_id, user_id, amount)
    select v_expense_id, (s->>'user_id')::uuid, (s->>'amount')::decimal
    from jsonb_array_elements(p_splits) as s;
  end if;

  insert into public.household_activities (
    household_id,
    user_id,
    event_type,
    title,
    description,
    metadata
  ) values (
    v_household_id,
    p_actor_user_id,
    'expense_added',
    'Nuevo movimiento',
    coalesce(nullif(trim(p_title), ''), 'Gasto del hogar'),
    jsonb_build_object(
      'expense_id', v_expense_id,
      'expense_title', p_title,
      'amount', p_amount,
      'category', p_category,
      'split_type', p_split_type,
      'is_shared', v_is_shared,
      'type', p_type
    )
  );

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id, new_value, reason, source
  ) values (
    'qa_admin_' || extract(epoch from now())::bigint,
    v_actor_id,
    v_household_id,
    case when p_id is null then 'create_expense' else 'update_expense' end,
    'expense',
    v_expense_id,
    jsonb_build_object('amount', p_amount, 'title', p_title, 'split_type', p_split_type),
    'QA admin saved expense',
    'qa_admin'
  );

  return v_expense_id;
end;
$$;

create or replace function public.qa_admin_get_recent_activity(
  p_household_id uuid,
  p_since timestamptz default null
)
returns table (
  id uuid,
  event_type text,
  title text,
  description text,
  metadata jsonb,
  created_at timestamptz,
  user_id uuid,
  "user" jsonb
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
    ha.id,
    ha.event_type,
    ha.title,
    ha.description,
    ha.metadata,
    ha.created_at,
    ha.user_id,
    jsonb_build_object(
      'id', u.id,
      'full_name', u.full_name,
      'avatar_url', u.avatar_url
    ) as "user"
  from public.household_activities ha
  left join public.users u on u.id = ha.user_id
  where ha.household_id = p_household_id
    and (p_since is null or ha.created_at >= p_since)
  order by ha.created_at desc
  limit 30;
end;
$$;

grant execute on function public.qa_admin_complete_task(uuid, uuid[], uuid, integer, integer, text, timestamptz) to authenticated;
grant execute on function public.qa_admin_save_expense_v1(uuid, uuid, uuid, text, decimal, text, uuid, timestamptz, text, text, boolean, text, jsonb) to authenticated;
grant execute on function public.qa_admin_get_recent_activity(uuid, timestamptz) to authenticated;
