-- Extend Home startup bootstrap with below-the-fold Home data so the first
-- render can show finance/activity snapshots without duplicate client fetches.

drop function if exists public.get_home_bootstrap(integer);

create or replace function public.get_home_bootstrap(
  p_tasks_limit integer default 50,
  p_feed_limit integer default 200,
  p_activity_limit integer default 30
)
returns jsonb
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_uid uuid := public.current_app_user_id();
  v_task_limit integer := least(greatest(coalesce(p_tasks_limit, 50), 1), 100);
  v_feed_limit integer := least(greatest(coalesce(p_feed_limit, 200), 1), 300);
  v_activity_limit integer := least(greatest(coalesce(p_activity_limit, 30), 1), 60);
  v_activity_since timestamptz :=
    date_trunc('day', timezone('America/Argentina/Buenos_Aires', now()))
    at time zone 'America/Argentina/Buenos_Aires';
  v_membership public.household_members%rowtype;
  v_household_id uuid;
  v_profile jsonb := null;
  v_household jsonb := null;
  v_members jsonb := '[]'::jsonb;
  v_tasks jsonb := '[]'::jsonb;
  v_expense_balances jsonb := '[]'::jsonb;
  v_user_balance jsonb := null;
  v_combined_feed jsonb := '[]'::jsonb;
  v_recent_activity jsonb := '[]'::jsonb;
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
      'user_balance', v_user_balance,
      'combined_feed', v_combined_feed,
      'recent_activity', v_recent_activity
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
      'user_balance', v_user_balance,
      'combined_feed', v_combined_feed,
      'recent_activity', v_recent_activity
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

  select coalesce(jsonb_agg(to_jsonb(feed_row) order by feed_row.date desc), '[]'::jsonb)
    into v_combined_feed
  from public.get_combined_feed(v_household_id, v_feed_limit, 0) feed_row;

  with raw_activity as (
    select
      ha.id::text as id,
      case
        when ha.event_type = 'task_completed' then 'task'
        when ha.event_type = 'expense_added' then 'expense'
        when ha.event_type = 'reward_redeemed' then 'reward'
        else 'unknown'
      end as type,
      ha.created_at,
      ha.user_id as creator_id,
      jsonb_strip_nulls(
        coalesce(ha.metadata, '{}'::jsonb) ||
        case
          when ha.event_type = 'task_completed' then jsonb_build_object(
            'user_name', coalesce(u.full_name, 'Alguien'),
            'avatar_url', u.avatar_url,
            'title', coalesce(t.title, ha.metadata->>'task_title', ha.title, 'Tarea del hogar'),
            'task_title', coalesce(t.title, ha.metadata->>'task_title', ha.title, 'Tarea del hogar'),
            'title_key', coalesce(t.title_key, ha.metadata->>'title_key'),
            'task_id', coalesce(ha.metadata->>'task_id', ha.metadata->>'id'),
            'category', coalesce(ha.metadata->>'category', ha.metadata->>'task_category', ha.metadata->>'category_name'),
            'xp_reward', coalesce(ha.metadata->>'xp_reward', ha.metadata->>'xpReward', ha.metadata->>'p_xp_reward', ha.metadata->>'score_impact', ha.metadata->>'xp', ha.metadata->>'reward'),
            'coins_reward', coalesce(ha.metadata->>'coins_reward', ha.metadata->>'coin_reward', ha.metadata->>'coinsReward', ha.metadata->>'p_coin_reward', ha.metadata->>'p_coins_reward', ha.metadata->>'coins')
          )
          when ha.event_type = 'expense_added' then jsonb_build_object(
            'user_name', coalesce(u.full_name, 'Alguien'),
            'avatar_url', u.avatar_url,
            'title', coalesce(
              nullif(ha.metadata->>'expense_title', ''),
              nullif(ha.metadata->>'merchant', ''),
              nullif(ha.metadata->>'store_name', ''),
              nullif(ha.metadata->>'place_name', ''),
              nullif(ha.metadata->>'description', ''),
              nullif(ha.description, ''),
              nullif(ha.metadata->>'category_name', ''),
              nullif(ha.metadata->>'category', ''),
              nullif(ha.title, ''),
              'Gasto del hogar'
            ),
            'amount', coalesce(ha.metadata->'amount', '0'::jsonb),
            'description', coalesce(
              nullif(ha.metadata->>'expense_title', ''),
              nullif(ha.metadata->>'description', ''),
              nullif(ha.description, ''),
              nullif(ha.title, ''),
              'Gasto del hogar'
            ),
            'expense_id', coalesce(ha.metadata->>'expense_id', ha.metadata->>'id'),
            'is_shared', ha.metadata->'is_shared',
            'split_type', ha.metadata->>'split_type'
          )
          when ha.event_type = 'reward_redeemed' then jsonb_build_object(
            'user_name', coalesce(u.full_name, 'Alguien'),
            'avatar_url', u.avatar_url,
            'title', coalesce(ha.metadata->>'reward_title', ha.title, 'Premio canjeado'),
            'reward_icon', coalesce(ha.metadata->>'reward_icon', ha.metadata->>'icon'),
            'reward_cost', coalesce(ha.metadata->>'cost', ha.metadata->>'coins', ha.metadata->>'coin_cost')
          )
          else jsonb_build_object(
            'user_name', coalesce(u.full_name, 'Alguien'),
            'avatar_url', u.avatar_url,
            'title', coalesce(ha.title, ha.description, 'Realizo una accion')
          )
        end
      ) as data
    from public.household_activities ha
    left join public.users u on u.id = ha.user_id
    left join public.tasks t
      on t.id::text = coalesce(ha.metadata->>'task_id', ha.metadata->>'id')
    where ha.household_id = v_household_id
      and ha.created_at >= v_activity_since
      and (
        ha.event_type <> 'expense_added'
        or (
          coalesce(ha.metadata->>'type', '') not in ('income', 'ingreso')
          and coalesce(ha.metadata->>'category', '') <> 'salary'
          and (
            coalesce((ha.metadata->>'is_shared')::boolean, false)
            or lower(coalesce(ha.metadata->>'split_type', '')) in ('gift', 'regalo')
            or ha.user_id = v_uid
          )
        )
      )
  ),
  pending_approvals as (
    select
      ('pending-task-' || t.id::text) as id,
      'task_pending_approval'::text as type,
      coalesce(t.completed_at, now()) as created_at,
      t.completed_by as creator_id,
      jsonb_build_object(
        'user_name', coalesce(u.full_name, 'Alguien'),
        'avatar_url', u.avatar_url,
        'title', coalesce(t.title, 'Tarea del hogar'),
        'task_title', coalesce(t.title, 'Tarea del hogar'),
        'title_key', t.title_key,
        'task_id', t.id,
        'category', t.category,
        'xp_reward', t.xp_reward,
        'coins_reward', t.coin_reward,
        'approval_status', 'pending_approval',
        'task_status', 'pending_approval'
      ) as data
    from public.tasks t
    left join public.users u on u.id = t.completed_by
    where t.household_id = v_household_id
      and t.status = 'pending_approval'
      and (t.completed_at is null or t.completed_at >= v_activity_since)
    order by t.completed_at desc nulls last
    limit 20
  ),
  combined_activity as (
    select id, type, created_at, creator_id, data from raw_activity
    union all
    select id, type, created_at, creator_id, data from pending_approvals
  ),
  ranked_activity as (
    select
      *,
      case
        when type = 'expense' then 'expense:' || coalesce(data->>'expense_id', id)
        when type in ('task', 'task_pending_approval') then type || ':' || coalesce(data->>'task_id', id)
        else id
      end as dedupe_key,
      (
        case when nullif(trim(coalesce(data->>'title', '')), '') is not null
              and lower(coalesce(data->>'title', '')) not in ('nuevo movimiento', 'gasto del hogar') then 3 else 0 end
        + case when nullif(trim(coalesce(data->>'description', '')), '') is not null then 1 else 0 end
        + case when data ? 'expense_id' or data ? 'task_id' then 1 else 0 end
        + case when data->>'approval_status' = 'pending_approval' then 2 else 0 end
      ) as score
    from combined_activity
  ),
  deduped_activity as (
    select distinct on (dedupe_key)
      id,
      type,
      data,
      created_at,
      creator_id
    from ranked_activity
    order by dedupe_key, score desc, created_at desc
  )
  select coalesce(jsonb_agg(to_jsonb(activity_row) order by activity_row.created_at desc), '[]'::jsonb)
    into v_recent_activity
  from (
    select *
    from deduped_activity
    order by created_at desc
    limit v_activity_limit
  ) activity_row;

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
    'user_balance', v_user_balance,
    'combined_feed', v_combined_feed,
    'recent_activity', v_recent_activity
  );
end;
$function$;

revoke execute on function public.get_home_bootstrap(integer, integer, integer) from public;
revoke execute on function public.get_home_bootstrap(integer, integer, integer) from anon;
grant execute on function public.get_home_bootstrap(integer, integer, integer) to authenticated;
