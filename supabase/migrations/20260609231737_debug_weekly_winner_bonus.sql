-- Temporary QA helper: let an admin simulate the weekly winner bonus without
-- changing the production weekly close idempotency.

create or replace function public.debug_award_weekly_winner_bonus(
  p_household_id uuid,
  p_week_start_date date
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid := public.current_app_user_id();
  v_winner_id uuid;
  v_winner_xp integer;
  v_reference_id uuid := gen_random_uuid();
  v_coins_awarded integer := 20;
begin
  if v_uid is null
     or not exists (
       select 1
       from public.users u
       where u.id = v_uid
         and coalesce(u.is_admin, false) = true
     )
     or not exists (
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
    'Premio de prueba por ganar la semana',
    'weekly_winner_debug',
    v_reference_id::text,
    'qa_admin',
    v_uid::text
  );

  return jsonb_build_object(
    'success', true,
    'winner_id', v_winner_id,
    'xp_earned', v_winner_xp,
    'coins_awarded', v_coins_awarded,
    'reference_id', v_reference_id::text,
    'week_start_date', p_week_start_date
  );
end;
$function$;

revoke execute on function public.debug_award_weekly_winner_bonus(uuid, date)
  from anon, public;
grant execute on function public.debug_award_weekly_winner_bonus(uuid, date)
  to authenticated;

comment on function public.debug_award_weekly_winner_bonus(uuid, date) is
  'Temporary admin-only QA helper that awards an extra weekly winner bonus for animation testing.';
