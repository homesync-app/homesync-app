-- Fix three SECURITY DEFINER RPCs that fail plpgsql_check/runtime validation.
-- Keep their public signatures stable while tightening search paths and ACLs.

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
begin
  if not coalesce(public.is_current_household_member(p_household_id), false) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  return query
  with balances as (
    select
      u.id as user_id,
      u.email as user_email,
      coalesce(payments.total_paid, 0) - coalesce(owed.total_owed, 0) as balance
    from public.users u
    left join (
      select e.paid_by, sum(e.amount) as total_paid
      from public.expenses e
      where e.household_id = p_household_id and e.is_shared = true
      group by e.paid_by
    ) payments on payments.paid_by = u.id
    left join (
      select es.user_id, sum(es.amount) as total_owed
      from public.expense_splits es
      join public.expenses e on e.id = es.expense_id
      where e.household_id = p_household_id and e.is_shared = true
      group by es.user_id
    ) owed on owed.user_id = u.id
    where exists (
      select 1
      from public.household_members hm
      where hm.household_id = p_household_id and hm.user_id = u.id
    )
  ),
  debtors as (
    select b.user_id, b.user_email, b.balance
    from balances b
    where b.balance < -0.01
  ),
  creditors as (
    select b.user_id, b.user_email, b.balance
    from balances b
    where b.balance > 0.01
  )
  select
    d.user_id,
    d.user_email,
    c.user_id,
    c.user_email,
    least(abs(d.balance), c.balance)::decimal
  from debtors d
  cross join creditors c
  where abs(d.balance) > 0.01 and c.balance > 0.01
  order by least(abs(d.balance), c.balance) desc;
end;
$function$;

revoke execute on function public.get_debts(uuid) from public, anon, service_role;
grant execute on function public.get_debts(uuid) to authenticated;

create or replace function public.delete_task_v1(p_task_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
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
      ha.metadata ->> 'task_id' = p_task_id::text
      or ha.metadata ->> 'id' = p_task_id::text
    );

  delete from public.notifications n
  where n.household_id = v_household_id
    and n.related_entity_type = 'task'
    and n.related_entity_id = p_task_id;

  update public.tasks child
  set recurrence_parent_id = null,
      updated_at = now()
  where child.recurrence_parent_id = p_task_id;

  delete from public.tasks t
  where t.id = p_task_id and t.household_id = v_household_id;

  get diagnostics v_rows_deleted = row_count;

  return jsonb_build_object(
    'success', v_rows_deleted = 1,
    'status', case when v_rows_deleted = 1 then 'deleted' else 'not_deleted' end,
    'task_id', p_task_id,
    'household_id', v_household_id
  );
end;
$function$;

revoke execute on function public.delete_task_v1(uuid) from public, anon;
grant execute on function public.delete_task_v1(uuid) to authenticated, service_role;

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
declare
  v_uid uuid;
begin
  v_uid := public.current_app_user_id();
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  if not exists (
    select 1
    from public.users admin_user
    where admin_user.id = v_uid and admin_user.is_admin = true
  ) then
    raise exception 'Admin access required';
  end if;

  return query
  select
    h.id,
    h.name,
    h.household_type,
    owner_user.email,
    (
      select count(*)
      from public.household_members counted_member
      where counted_member.household_id = h.id
    ),
    h.created_at
  from public.households h
  join public.household_members owner_member
    on owner_member.household_id = h.id and owner_member.role = 'owner'
  join public.users owner_user on owner_user.id = owner_member.user_id
  order by h.created_at desc;
end;
$function$;

revoke execute on function public.admin_get_all_households()
  from public, anon, authenticated;
grant execute on function public.admin_get_all_households()
  to service_role;
