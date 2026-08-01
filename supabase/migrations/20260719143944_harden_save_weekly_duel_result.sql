-- Endurece save_weekly_duel_result: antes era SECURITY DEFINER sin validacion
-- (cualquier authenticated podia escribir el historial de duelos de cualquier
-- hogar con XP/nombres arbitrarios). Misma firma para no romper clientes
-- desplegados; el payload del cliente pasa a ser solo informativo:
-- - exige membresia del hogar (patron award_weekly_winner_for_week)
-- - solo semanas ISO validas: la actual o las 2 previas
-- - recalcula ganador/perdedor/XP del ledger (misma fuente y mismo orden que
--   get_weekly_ranking_for_week) y persiste ESO, no lo que mando el cliente
-- Smoke SQL 2026-07-19 (rollback): payload falso ignorado (persiste ranking
-- real), no-miembro => 'No autorizado', semana vieja => 'Semana fuera de
-- rango', dia no-lunes => 'Semana invalida'.
-- Aplicada a prod via MCP el 2026-07-19.
create or replace function public.save_weekly_duel_result(
  p_household_id uuid,
  p_week_start_date date,
  p_winner_user_id uuid,
  p_winner_name text,
  p_loser_user_id uuid,
  p_loser_name text,
  p_winner_xp integer,
  p_loser_xp integer
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid;
  v_current_week date;
  r_winner record;
  r_loser record;
begin
  v_uid := public.current_app_user_id();
  if v_uid is null or not exists (
    select 1 from public.household_members hm
    where hm.household_id = p_household_id and hm.user_id = v_uid
  ) then
    return jsonb_build_object('success', false, 'message', 'No autorizado');
  end if;

  if p_week_start_date <> date_trunc('week', p_week_start_date::timestamp)::date then
    return jsonb_build_object('success', false, 'message', 'Semana invalida');
  end if;

  v_current_week := date_trunc('week', current_date)::date;
  if p_week_start_date > v_current_week
     or p_week_start_date < v_current_week - 14 then
    return jsonb_build_object('success', false, 'message', 'Semana fuera de rango');
  end if;

  select * into r_winner from (
    select u.id as user_id, u.full_name as user_name,
           coalesce(sum(le.amount), 0)::integer as xp_earned,
           (count(le.id) filter (where le.currency = 'XP'))::integer as tasks_completed
    from public.household_members hm
    join public.users u on hm.user_id = u.id
    left join public.ledger_entries le on le.user_id = u.id
      and le.household_id = p_household_id and le.currency = 'XP'
      and le.type = 'xp_earned'
      and le.created_at >= p_week_start_date::timestamptz
      and le.created_at < (p_week_start_date::timestamptz + interval '7 days')
    where hm.household_id = p_household_id
    group by u.id, u.full_name
    order by xp_earned desc, tasks_completed desc, user_name asc
  ) t limit 1;

  select * into r_loser from (
    select u.id as user_id, u.full_name as user_name,
           coalesce(sum(le.amount), 0)::integer as xp_earned,
           (count(le.id) filter (where le.currency = 'XP'))::integer as tasks_completed
    from public.household_members hm
    join public.users u on hm.user_id = u.id
    left join public.ledger_entries le on le.user_id = u.id
      and le.household_id = p_household_id and le.currency = 'XP'
      and le.type = 'xp_earned'
      and le.created_at >= p_week_start_date::timestamptz
      and le.created_at < (p_week_start_date::timestamptz + interval '7 days')
    where hm.household_id = p_household_id
    group by u.id, u.full_name
    order by xp_earned desc, tasks_completed desc, user_name asc
  ) t offset 1 limit 1;

  if r_winner.user_id is null or r_loser.user_id is null then
    return jsonb_build_object('success', false, 'message', 'Se necesitan dos miembros para el duelo');
  end if;

  insert into public.weekly_duel_history (
    household_id, week_start_date,
    winner_user_id, winner_name,
    loser_user_id, loser_name,
    winner_xp, loser_xp
  ) values (
    p_household_id, p_week_start_date,
    r_winner.user_id, coalesce(r_winner.user_name, 'Ganador'),
    r_loser.user_id, coalesce(r_loser.user_name, 'Perdedor'),
    r_winner.xp_earned, r_loser.xp_earned
  )
  on conflict (household_id, week_start_date)
  do update set
    winner_user_id = excluded.winner_user_id,
    winner_name = excluded.winner_name,
    loser_user_id = excluded.loser_user_id,
    loser_name = excluded.loser_name,
    winner_xp = excluded.winner_xp,
    loser_xp = excluded.loser_xp,
    created_at = now();

  return jsonb_build_object('success', true, 'message', 'Duelo guardado correctamente');
end;
$function$;
