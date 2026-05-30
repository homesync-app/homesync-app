-- Reconstructed from remote migration history (version 20260519235257).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Home startup bootstrap: collapse the first-screen data dependencies into a
-- single RPC so the Flutter client can render a complete Home with fewer
-- network roundtrips.

create index if not exists idx_household_members_user
  on public.household_members (user_id);

create or replace function public.get_home_bootstrap(
  p_tasks_limit integer default 50
)
returns jsonb
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_uid uuid := public.current_app_user_id();
  v_task_limit integer := least(greatest(coalesce(p_tasks_limit, 50), 1), 100);
  v_membership public.household_members%rowtype;
  v_household_id uuid;
  v_profile jsonb := null;
  v_household jsonb := null;
  v_members jsonb := '[]'::jsonb;
  v_tasks jsonb := '[]'::jsonb;
  v_expense_balances jsonb := '[]'::jsonb;
  v_user_balance jsonb := null;
begin
  if v_uid is null then
    return jsonb_build_object(
      'authenticated', false,
      'user_id', null,
      'household_id', null,
      'profile', null,
      'household', null,
      'member_onboarding_completed', true,
      'members', v_members,
      'tasks', v_tasks,
      'expense_balances', v_expense_balances,
      'user_balance', v_user_balance
    );
  end if;

  select jsonb_build_object(
      'id', u.id,
      'full_name', u.full_name,
      'email', u.email,
      'avatar_url', u.avatar_url,
      'mercadopago_alias', u.mercadopago_alias,
      'is_admin', u.is_admin
    )
    into v_profile
  from public.users u
  where u.id = v_uid;

  select hm.*
    into v_membership
  from public.household_members hm
  where hm.user_id = v_uid
  order by hm.joined_at desc nulls last
  limit 1;

  v_household_id := v_membership.household_id;

  if v_household_id is null then
    return jsonb_build_object(
      'authenticated', true,
      'user_id', v_uid,
      'household_id', null,
      'profile', v_profile,
      'household', null,
      'member_onboarding_completed', true,
      'members', v_members,
      'tasks', v_tasks,
      'expense_balances', v_expense_balances,
      'user_balance', v_user_balance
    );
  end if;

  select to_jsonb(h)
    into v_household
  from public.households h
  where h.id = v_household_id;

  select coalesce(jsonb_agg(member_row order by member_row->>'joined_at'), '[]'::jsonb)
    into v_members
  from (
    select jsonb_build_object(
      'id', hm.id,
      'user_id', hm.user_id,
      'household_id', hm.household_id,
      'role', hm.role,
      'joined_at', hm.joined_at,
      'display_role', hm.display_role,
      'member_type', hm.member_type,
      'onboarding_completed', hm.onboarding_completed,
      'users', jsonb_build_object(
        'email', u.email,
        'full_name', u.full_name,
        'avatar_url', u.avatar_url,
        'mercadopago_alias', u.mercadopago_alias
      )
    ) as member_row
    from public.household_members hm
    left join public.users u on u.id = hm.user_id
    where hm.household_id = v_household_id
  ) rows;

  select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at desc), '[]'::jsonb)
    into v_tasks
  from (
    select *
    from public.tasks
    where household_id = v_household_id
    order by created_at desc
    limit v_task_limit
  ) t;

  select coalesce(jsonb_agg(to_jsonb(balance_row)), '[]'::jsonb)
    into v_expense_balances
  from public.get_expense_balance(v_household_id) balance_row;

  v_user_balance := public.get_user_balance(v_uid, v_household_id);

  return jsonb_build_object(
    'authenticated', true,
    'user_id', v_uid,
    'household_id', v_household_id,
    'profile', v_profile,
    'household', v_household,
    'member_onboarding_completed',
      coalesce(v_membership.onboarding_completed, true),
    'members', v_members,
    'tasks', v_tasks,
    'expense_balances', v_expense_balances,
    'user_balance', v_user_balance
  );
end;
$function$;

revoke execute on function public.get_home_bootstrap(integer) from public;
revoke execute on function public.get_home_bootstrap(integer) from anon;
grant execute on function public.get_home_bootstrap(integer) to authenticated;
