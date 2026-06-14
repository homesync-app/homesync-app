create or replace function public.get_solo_progress_snapshot(
  p_user_id uuid,
  p_household_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := public.current_app_user_id();
  v_household_type text;
  v_week_start timestamptz := date_trunc('week', now());
  v_previous_week_start timestamptz := date_trunc('week', now()) - interval '7 days';
  v_next_week_start timestamptz := date_trunc('week', now()) + interval '7 days';
  v_month_start timestamptz := date_trunc('month', now());
  v_xp integer := 0;
  v_weekly_xp integer := 0;
  v_previous_week_xp integer := 0;
  v_tasks_completed integer := 0;
  v_weekly_tasks_completed integer := 0;
  v_previous_week_tasks_completed integer := 0;
  v_current_streak_days integer := 0;
  v_active_days_14 integer := 0;
  v_recent_activity_count integer := 0;
  v_monthly_expense numeric := 0;
  v_monthly_income numeric := 0;
  v_finance jsonb := '{}'::jsonb;
  v_top_task_category text;
  v_top_expense_category text;
  v_first_activity_at timestamptz;
begin
  if v_uid is null or v_uid <> p_user_id then
    return jsonb_build_object(
      'authorized', false,
      'reason', 'unauthorized',
      'xp', 0,
      'weekly_xp', 0,
      'previous_week_xp', 0,
      'weekly_xp_delta', 0,
      'tasks_completed', 0,
      'weekly_tasks_completed', 0,
      'previous_week_tasks_completed', 0,
      'tasks_completed_delta', 0,
      'current_streak_days', 0,
      'active_days_14', 0,
      'monthly_expense', 0,
      'monthly_income', 0,
      'recent_activity_count', 0
    );
  end if;

  select h.household_type
    into v_household_type
  from public.households h
  join public.household_members hm on hm.household_id = h.id
  where h.id = p_household_id
    and hm.user_id = v_uid
  limit 1;

  if v_household_type is null then
    return jsonb_build_object(
      'authorized', false,
      'reason', 'not_household_member',
      'xp', 0,
      'weekly_xp', 0,
      'previous_week_xp', 0,
      'weekly_xp_delta', 0,
      'tasks_completed', 0,
      'weekly_tasks_completed', 0,
      'previous_week_tasks_completed', 0,
      'tasks_completed_delta', 0,
      'current_streak_days', 0,
      'active_days_14', 0,
      'monthly_expense', 0,
      'monthly_income', 0,
      'recent_activity_count', 0
    );
  end if;

  select coalesce(sum(le.amount), 0)::integer
    into v_xp
  from public.ledger_entries le
  where le.household_id = p_household_id
    and le.user_id = p_user_id
    and upper(coalesce(le.currency, '')) = 'XP';

  select coalesce(sum(le.amount), 0)::integer
    into v_weekly_xp
  from public.ledger_entries le
  where le.household_id = p_household_id
    and le.user_id = p_user_id
    and upper(coalesce(le.currency, '')) = 'XP'
    and le.created_at >= v_week_start
    and le.created_at < v_next_week_start;

  select coalesce(sum(le.amount), 0)::integer
    into v_previous_week_xp
  from public.ledger_entries le
  where le.household_id = p_household_id
    and le.user_id = p_user_id
    and upper(coalesce(le.currency, '')) = 'XP'
    and le.created_at >= v_previous_week_start
    and le.created_at < v_week_start;

  select count(*)::integer
    into v_tasks_completed
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.user_id = p_user_id
    and ha.event_type = 'task_completed';

  select count(*)::integer
    into v_weekly_tasks_completed
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.user_id = p_user_id
    and ha.event_type = 'task_completed'
    and ha.created_at >= v_week_start
    and ha.created_at < v_next_week_start;

  select count(*)::integer
    into v_previous_week_tasks_completed
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.user_id = p_user_id
    and ha.event_type = 'task_completed'
    and ha.created_at >= v_previous_week_start
    and ha.created_at < v_week_start;

  with active_days as (
    select distinct ha.created_at::date as day
    from public.household_activities ha
    where ha.household_id = p_household_id
      and ha.user_id = p_user_id
      and ha.created_at <= now()
      and ha.event_type in (
        'task_completed',
        'expense_added',
        'shopping_item_added',
        'shopping_item_purchased',
        'reward_redeemed'
      )
  ),
  anchor_day as (
    select max(day) as day from active_days
  ),
  streak_series as (
    select (ad.day - g.day_offset)::date as day,
           g.day_offset + 1 as position
    from anchor_day ad
    cross join generate_series(0, 60) as g(day_offset)
    where ad.day is not null
  ),
  streak_flags as (
    select ss.day,
           ss.position,
           exists(select 1 from active_days a where a.day = ss.day) as is_active
    from streak_series ss
  ),
  first_gap as (
    select min(position) as position
    from streak_flags
    where not is_active
  )
  select count(*)::integer
    into v_current_streak_days
  from streak_flags
  where is_active
    and position < coalesce((select position from first_gap), 62);

  select count(distinct ha.created_at::date)::integer
    into v_active_days_14
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.user_id = p_user_id
    and ha.created_at >= current_date - interval '13 days';

  select count(*)::integer
    into v_recent_activity_count
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.user_id = p_user_id
    and ha.created_at >= now() - interval '7 days';

  select min(ha.created_at)
    into v_first_activity_at
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.user_id = p_user_id;

  v_finance := public.get_personal_finance_summary(p_user_id, p_household_id);
  v_monthly_expense := coalesce((v_finance ->> 'expense')::numeric, 0);
  v_monthly_income := coalesce((v_finance ->> 'income')::numeric, 0);

  select nullif(coalesce(ha.metadata ->> 'category', ha.metadata ->> 'task_category'), '')
    into v_top_task_category
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.user_id = p_user_id
    and ha.event_type = 'task_completed'
    and ha.created_at >= v_month_start
    and nullif(coalesce(ha.metadata ->> 'category', ha.metadata ->> 'task_category'), '') is not null
  group by 1
  order by count(*) desc, max(ha.created_at) desc
  limit 1;

  select nullif(e.category, '')
    into v_top_expense_category
  from public.expenses e
  where e.household_id = p_household_id
    and e.paid_by = p_user_id
    and e.type = 'expense'
    and e.paid_at >= v_month_start
    and nullif(e.category, '') is not null
  group by 1
  order by sum(e.amount) desc, max(e.paid_at) desc
  limit 1;

  return jsonb_build_object(
    'authorized', true,
    'user_id', p_user_id,
    'household_id', p_household_id,
    'household_type', v_household_type,
    'generated_at', now(),
    'week_start', v_week_start,
    'xp', v_xp,
    'weekly_xp', v_weekly_xp,
    'previous_week_xp', v_previous_week_xp,
    'weekly_xp_delta', v_weekly_xp - v_previous_week_xp,
    'tasks_completed', v_tasks_completed,
    'weekly_tasks_completed', v_weekly_tasks_completed,
    'previous_week_tasks_completed', v_previous_week_tasks_completed,
    'tasks_completed_delta', v_weekly_tasks_completed - v_previous_week_tasks_completed,
    'current_streak_days', coalesce(v_current_streak_days, 0),
    'active_days_14', coalesce(v_active_days_14, 0),
    'monthly_expense', v_monthly_expense,
    'monthly_income', v_monthly_income,
    'top_task_category', v_top_task_category,
    'top_expense_category', v_top_expense_category,
    'recent_activity_count', v_recent_activity_count,
    'first_activity_at', v_first_activity_at
  );
end;
$function$;

revoke execute on function public.get_solo_progress_snapshot(uuid, uuid) from public;
revoke execute on function public.get_solo_progress_snapshot(uuid, uuid) from anon;
grant execute on function public.get_solo_progress_snapshot(uuid, uuid) to authenticated;

comment on function public.get_solo_progress_snapshot(uuid, uuid)
  is 'Solo mode progress snapshot: XP, weekly deltas, task completions, streaks, and personal finance signals for the authenticated household member.';
