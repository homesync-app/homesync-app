-- Make weekly duel closing use the week that actually closed.
-- Sunday night closes the current Monday-Sunday week; Monday morning still
-- closes the previous week, so users can claim the result after waking up.

create or replace function public.get_weekly_ranking_for_week(
  p_household_id uuid,
  p_week_start_date date
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_result jsonb;
  v_uid uuid;
begin
  v_uid := public.current_app_user_id();

  if v_uid is null or not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_uid
  ) then
    return '[]'::jsonb;
  end if;

  select jsonb_agg(t) into v_result
  from (
    select
      u.id as user_id,
      u.full_name as user_name,
      u.email as user_email,
      u.avatar_url,
      hm.member_type,
      hm.role,
      coalesce(sum(le.amount), 0)::integer as xp_earned,
      (count(le.id) filter (where le.currency = 'XP'))::integer as tasks_completed
    from public.household_members hm
    join public.users u on hm.user_id = u.id
    left join public.ledger_entries le on le.user_id = u.id
      and le.household_id = p_household_id
      and le.currency = 'XP'
      and le.type = 'xp_earned'
      and le.created_at >= p_week_start_date::timestamptz
      and le.created_at < (p_week_start_date::timestamptz + interval '7 days')
    where hm.household_id = p_household_id
    group by u.id, u.full_name, u.email, u.avatar_url, hm.member_type, hm.role
    order by xp_earned desc, tasks_completed desc, user_name asc
  ) t;

  return coalesce(v_result, '[]'::jsonb);
end;
$function$;

create or replace function public.is_week_processed_for_week(
  p_household_id uuid,
  p_week_start_date date
)
returns boolean
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid;
begin
  v_uid := public.current_app_user_id();

  if v_uid is null or not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_uid
  ) then
    return false;
  end if;

  return exists (
    select 1
    from public.weekly_winners ww
    where ww.household_id = p_household_id
      and ww.week_start = p_week_start_date
      and ww.created_at >= (p_week_start_date::timestamptz + interval '6 days')
  );
end;
$function$;

create or replace function public.award_weekly_winner_for_week(
  p_household_id uuid,
  p_week_start_date date
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid;
  v_week_end date;
  v_winner_id uuid;
  v_winner_xp integer;
  v_winner_row_id uuid;
  v_coins_awarded integer := 20;
  v_existing public.weekly_winners%rowtype;
begin
  v_uid := public.current_app_user_id();
  v_week_end := p_week_start_date + 6;

  if v_uid is null or not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_uid
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'No autorizado'
    );
  end if;

  select *
  into v_existing
  from public.weekly_winners ww
  where ww.household_id = p_household_id
    and ww.week_start = p_week_start_date
    and ww.created_at >= (p_week_start_date::timestamptz + interval '6 days')
  limit 1;

  if found then
    if not exists (
      select 1
      from public.ledger_entries le
      where le.household_id = p_household_id
        and le.user_id = v_existing.user_id
        and le.type = 'weekly_winner_bonus'
        and le.currency = 'COIN'
        and le.amount = coalesce(v_existing.coins_awarded, v_coins_awarded)
        and le.reference_type = 'weekly_winner'
        and le.created_at >= p_week_start_date::timestamptz
        and le.created_at < (p_week_start_date::timestamptz + interval '14 days')
    ) then
      insert into public.ledger_entries (
        user_id,
        household_id,
        amount,
        currency,
        type,
        description,
        reference_type,
        reference_id,
        source,
        created_by
      ) values (
        v_existing.user_id,
        p_household_id,
        coalesce(v_existing.coins_awarded, v_coins_awarded),
        'COIN',
        'weekly_winner_bonus',
        'Weekly duel winner bonus',
        'weekly_winner',
        v_existing.id::text,
        'rpc',
        v_uid::text
      );
    end if;

    return jsonb_build_object(
      'success', true,
      'already_processed', true,
      'message', 'Esta semana ya fue procesada',
      'winner_id', v_existing.user_id,
      'xp_earned', v_existing.xp_earned,
      'coins_awarded', coalesce(v_existing.coins_awarded, v_coins_awarded),
      'week_start_date', p_week_start_date
    );
  end if;

  select le.user_id, sum(le.amount)::integer
  into v_winner_id, v_winner_xp
  from public.ledger_entries le
  where le.household_id = p_household_id
    and le.type = 'xp_earned'
    and le.currency = 'XP'
    and le.created_at >= p_week_start_date::timestamptz
    and le.created_at < (p_week_start_date::timestamptz + interval '7 days')
  group by le.user_id
  order by sum(le.amount) desc
  limit 1;

  if v_winner_id is null or coalesce(v_winner_xp, 0) <= 0 then
    return jsonb_build_object(
      'success', false,
      'message', 'No hay actividades esta semana',
      'week_start_date', p_week_start_date
    );
  end if;

  v_winner_row_id := gen_random_uuid();

  insert into public.weekly_winners (
    id,
    household_id,
    user_id,
    week_start,
    week_end,
    xp_earned,
    coins_awarded
  ) values (
    v_winner_row_id,
    p_household_id,
    v_winner_id,
    p_week_start_date,
    v_week_end,
    v_winner_xp,
    v_coins_awarded
  )
  on conflict (household_id, week_start)
  do update set
    user_id = excluded.user_id,
    week_end = excluded.week_end,
    xp_earned = excluded.xp_earned,
    coins_awarded = excluded.coins_awarded,
    created_at = now()
  returning id into v_winner_row_id;

  if not exists (
    select 1
    from public.ledger_entries le
    where le.household_id = p_household_id
      and le.user_id = v_winner_id
      and le.type = 'weekly_winner_bonus'
      and le.currency = 'COIN'
      and le.amount = v_coins_awarded
      and le.reference_type = 'weekly_winner'
      and le.created_at >= p_week_start_date::timestamptz
      and le.created_at < (p_week_start_date::timestamptz + interval '14 days')
  ) then
    insert into public.ledger_entries (
      user_id,
      household_id,
      amount,
      currency,
      type,
      description,
      reference_type,
      reference_id,
      source,
      created_by
    ) values (
      v_winner_id,
      p_household_id,
      v_coins_awarded,
      'COIN',
      'weekly_winner_bonus',
      'Weekly duel winner bonus',
      'weekly_winner',
      v_winner_row_id::text,
      'rpc',
      v_uid::text
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'already_processed', false,
    'message', 'Ganador premiado',
    'winner_id', v_winner_id,
    'xp_earned', v_winner_xp,
    'coins_awarded', v_coins_awarded,
    'week_start_date', p_week_start_date
  );
end;
$function$;

create or replace function public.award_weekly_winner(p_household_id uuid)
returns jsonb
language plpgsql
set search_path = public
as $function$
declare
  v_week_start date;
begin
  v_week_start := date_trunc('week', current_date)::date;

  if extract(isodow from current_date) = 1
     and extract(hour from current_timestamp) < 12 then
    v_week_start := v_week_start - 7;
  end if;

  return public.award_weekly_winner_for_week(p_household_id, v_week_start);
end;
$function$;

create or replace function public.is_week_processed(p_household_id uuid)
returns boolean
language plpgsql
set search_path = public
as $function$
declare
  v_week_start date;
begin
  v_week_start := date_trunc('week', current_date)::date;

  if extract(isodow from current_date) = 1
     and extract(hour from current_timestamp) < 12 then
    v_week_start := v_week_start - 7;
  end if;

  return public.is_week_processed_for_week(p_household_id, v_week_start);
end;
$function$;

grant execute on function public.get_weekly_ranking_for_week(uuid, date)
  to authenticated;
grant execute on function public.is_week_processed_for_week(uuid, date)
  to authenticated;
grant execute on function public.award_weekly_winner_for_week(uuid, date)
  to authenticated;

comment on function public.get_weekly_ranking_for_week(uuid, date) is
  'Returns weekly duel ranking for an explicit Monday week start.';
comment on function public.award_weekly_winner_for_week(uuid, date) is
  'Awards the explicit weekly duel winner once and repairs missing bonus ledger entries.';
