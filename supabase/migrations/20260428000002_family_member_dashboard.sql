-- Sprint 2 (Modo Padres): dashboard parental / vista por miembro.
--
-- Una sola RPC consolida lo que padres/admins necesitan ver para cada
-- integrante de la familia en una ventana temporal:
--   - tareas completadas en el periodo
--   - tareas pendientes/atrasadas asignadas
--   - XP / coins ganados (ledger_entries)
--   - coins gastados (ledger_entries)
--   - racha (dias consecutivos con al menos una tarea completada)
--   - top 3 categorias por XP en el periodo
--
-- Ventana: 'week' (default) | 'month'. Para 'week' empezamos en el lunes
-- (ISO), para 'month' en el dia 1. Usamos UTC: el TODO de timezone ya esta
-- documentado en get_weekly_ranking y se resuelve igual en ambos lugares.
--
-- Seguridad: la RPC chequea que el caller sea miembro del hogar — RLS por
-- ledger_entries no aplica desde SECURITY DEFINER. Cualquier miembro puede
-- consultar; el bloqueo a "solo admins" lo aplica el cliente segun
-- parentModeAvailableProvider.

create or replace function public.get_family_member_dashboard(
  p_household_id uuid,
  p_period text default 'week'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_caller uuid;
  v_period_start timestamptz;
  v_result jsonb;
begin
  v_caller := public.current_app_user_id();
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_caller
  ) then
    raise exception 'Not a member of household %', p_household_id
      using errcode = '42501';
  end if;

  if p_period not in ('week', 'month') then
    raise exception 'Invalid period: %', p_period using errcode = '22023';
  end if;

  v_period_start := case
    when p_period = 'week' then date_trunc('week', now())
    else date_trunc('month', now())
  end;

  with members as (
    select hm.user_id, hm.member_type, hm.display_role,
           u.full_name, u.email, u.avatar_url
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    where hm.household_id = p_household_id
  ),
  -- Tareas completadas: una entrada de XP por activity por usuario.
  -- Las tareas en pending_approval no estan aca (no hay ledger entry todavia).
  task_completions as (
    select le.user_id,
           count(*) filter (where le.currency = 'XP') as tasks_done,
           coalesce(sum(le.amount) filter (where le.currency = 'XP'), 0)
             as xp_earned,
           coalesce(sum(le.amount) filter (where le.type = 'coins_earned'), 0)
             as coins_earned,
           coalesce(sum(le.amount) filter (where le.type = 'coins_spent'), 0)
             as coins_spent
    from public.ledger_entries le
    where le.household_id = p_household_id
      and le.created_at >= v_period_start
    group by le.user_id
  ),
  -- Tareas asignadas todavia abiertas (no completadas), por miembro.
  open_tasks as (
    select t.assigned_to as user_id,
           count(*) filter (where t.status in ('assigned', 'objected'))
             as tasks_open,
           count(*) filter (
             where t.status in ('assigned', 'objected')
               and t.due_at is not null
               and t.due_at < now()
           ) as tasks_overdue,
           count(*) filter (where t.status = 'pending_approval')
             as tasks_pending_approval
    from public.tasks t
    where t.household_id = p_household_id
      and t.assigned_to is not null
    group by t.assigned_to
  ),
  -- Racha: dias consecutivos terminando hoy (o ayer) con al menos un
  -- task_completed en activities. Si la racha rompe ayer, igual la mostramos
  -- como "ayer fue el ultimo dia"; si rompio antes, devolvemos 0.
  streak_days as (
    select distinct ha.user_id,
           (ha.created_at at time zone 'UTC')::date as d
    from public.household_activities ha
    where ha.household_id = p_household_id
      and ha.event_type = 'task_completed'
      and ha.created_at >= now() - interval '60 days'
  ),
  streak_ranked as (
    select sd.user_id, sd.d,
           row_number() over (
             partition by sd.user_id order by sd.d desc
           ) - 1 as rn,
           first_value(sd.d) over (
             partition by sd.user_id order by sd.d desc
           ) as latest_d
    from streak_days sd
  ),
  streaks as (
    -- Racha viva: el ultimo dia es hoy o ayer (gap <= 1) y todos los demas
    -- dias contados son consecutivos desde el mas reciente.
    select user_id, count(*) as streak
    from streak_ranked
    where (current_date - latest_d) <= 1
      and (latest_d - d) = rn
    group by user_id
  ),
  -- Top 3 categorias por XP en el periodo.
  top_categories as (
    select tc.user_id, jsonb_agg(
      jsonb_build_object(
        'category', tc.category,
        'xp', tc.xp,
        'count', tc.cnt
      ) order by tc.xp desc
    ) as cats
    from (
      select le.user_id,
             coalesce(ha.metadata->>'category', 'sin_categoria') as category,
             sum(le.amount) as xp,
             count(*) as cnt,
             row_number() over (
               partition by le.user_id
               order by sum(le.amount) desc
             ) as rn
      from public.ledger_entries le
      left join public.household_activities ha
        on ha.id::text = le.reference_id
      where le.household_id = p_household_id
        and le.currency = 'XP'
        and le.created_at >= v_period_start
      group by le.user_id, coalesce(ha.metadata->>'category', 'sin_categoria')
    ) tc
    where tc.rn <= 3
    group by tc.user_id
  )
  select jsonb_build_object(
    'household_id', p_household_id,
    'period', p_period,
    'period_start', v_period_start,
    'generated_at', now(),
    'members', coalesce(jsonb_agg(member_data order by member_data->>'full_name'), '[]'::jsonb)
  )
  into v_result
  from (
    select jsonb_build_object(
      'user_id', m.user_id,
      'full_name', coalesce(m.full_name, m.email, 'Miembro'),
      'avatar_url', m.avatar_url,
      'member_type', m.member_type,
      'display_role', m.display_role,
      'tasks_done', coalesce(tc.tasks_done, 0),
      'tasks_open', coalesce(ot.tasks_open, 0),
      'tasks_overdue', coalesce(ot.tasks_overdue, 0),
      'tasks_pending_approval', coalesce(ot.tasks_pending_approval, 0),
      'xp_earned', coalesce(tc.xp_earned, 0),
      'coins_earned', coalesce(tc.coins_earned, 0),
      'coins_spent', coalesce(tc.coins_spent, 0),
      'streak_days', coalesce(s.streak, 0),
      'top_categories', coalesce(cat.cats, '[]'::jsonb)
    ) as member_data
    from members m
    left join task_completions tc on tc.user_id = m.user_id
    left join open_tasks ot on ot.user_id = m.user_id
    left join streaks s on s.user_id = m.user_id
    left join top_categories cat on cat.user_id = m.user_id
  ) sub;

  return coalesce(v_result, jsonb_build_object(
    'household_id', p_household_id,
    'period', p_period,
    'period_start', v_period_start,
    'generated_at', now(),
    'members', '[]'::jsonb
  ));
end;
$$;

grant execute on function public.get_family_member_dashboard(uuid, text)
  to authenticated, service_role;

comment on function public.get_family_member_dashboard(uuid, text) is
  'Sprint 2 Modo Padres: dashboard parental con tareas/coins/streak por miembro en una ventana (week|month).';
