-- Sprint 4 (Modo Padres): resumen familiar semanal.
--
-- RPC consolidada `get_weekly_family_summary(household_id, week_start)`.
-- Si week_start es null, usamos el lunes de la semana actual (UTC). El
-- formato de respuesta esta pensado para alimentar una pantalla tipo
-- "story" con cards: totales, MVP, slacker, tarea olvidada, gastos.
--
-- Comparativas:
--   - vs_last_week en cumplimiento y gasto.
--
-- Auditoria de seguridad:
--   - SECURITY DEFINER + check de membresia. Cualquier miembro puede leer.

create or replace function public.get_weekly_family_summary(
  p_household_id uuid,
  p_week_start timestamptz default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_caller uuid;
  v_week_start timestamptz;
  v_week_end timestamptz;
  v_prev_start timestamptz;
  v_prev_end timestamptz;
  v_tasks_done integer;
  v_tasks_planned integer;
  v_completion_rate numeric;
  v_prev_done integer;
  v_prev_rate numeric;
  v_mvp jsonb;
  v_slacker jsonb;
  v_forgotten jsonb;
  v_spending_total numeric;
  v_prev_spending numeric;
  v_top_category jsonb;
begin
  v_caller := public.current_app_user_id();
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if not exists (
    select 1 from public.household_members hm
    where hm.household_id = p_household_id and hm.user_id = v_caller
  ) then
    raise exception 'Not a member of household %', p_household_id
      using errcode = '42501';
  end if;

  v_week_start := coalesce(p_week_start, date_trunc('week', now()));
  v_week_end := v_week_start + interval '7 days';
  v_prev_start := v_week_start - interval '7 days';
  v_prev_end := v_week_start;

  -- Tareas completadas en la semana = una activity task_completed por
  -- miembro / cycle. Las pending_approval no estan aca.
  select count(*) into v_tasks_done
  from public.household_activities
  where household_id = p_household_id
    and event_type = 'task_completed'
    and created_at >= v_week_start
    and created_at < v_week_end;

  -- Tareas planeadas: completadas + abiertas/atrasadas + pending_approval
  -- de la semana. Es una aproximacion (no contamos las cerradas/borradas
  -- previo a la semana) pero alcanza para la tasa de cumplimiento percibida.
  select count(*) into v_tasks_planned
  from public.tasks
  where household_id = p_household_id
    and (
      (due_at >= v_week_start and due_at < v_week_end)
      or (last_completed_at::timestamptz >= v_week_start
          and last_completed_at::timestamptz < v_week_end)
    );

  v_tasks_planned := greatest(v_tasks_planned, v_tasks_done);
  v_completion_rate := case
    when v_tasks_planned = 0 then 1
    else round(v_tasks_done::numeric / v_tasks_planned, 4)
  end;

  -- Misma metrica para la semana anterior (solo done, lo usamos para
  -- el delta. Tasa previa la calculamos sobre planned previo aproximado).
  select count(*) into v_prev_done
  from public.household_activities
  where household_id = p_household_id
    and event_type = 'task_completed'
    and created_at >= v_prev_start
    and created_at < v_prev_end;

  v_prev_rate := case
    when v_prev_done = 0 and v_tasks_done = 0 then 1
    when v_prev_done = 0 then 0
    else null  -- no comparamos tasa, solo done counts
  end;

  -- MVP: miembro con mas tareas completadas en la semana.
  select to_jsonb(t) into v_mvp
  from (
    select ha.user_id,
           coalesce(u.full_name, u.email, 'Miembro') as full_name,
           u.avatar_url,
           count(*) as tasks_done
    from public.household_activities ha
    join public.users u on u.id = ha.user_id
    where ha.household_id = p_household_id
      and ha.event_type = 'task_completed'
      and ha.created_at >= v_week_start
      and ha.created_at < v_week_end
    group by ha.user_id, u.full_name, u.email, u.avatar_url
    order by count(*) desc
    limit 1
  ) t;

  -- Slacker: miembro con mas tareas atrasadas (status assigned + due_at
  -- vencido). Sin tono negativo en el copy del cliente.
  select to_jsonb(t) into v_slacker
  from (
    select hm.user_id,
           coalesce(u.full_name, u.email, 'Miembro') as full_name,
           u.avatar_url,
           count(*) as overdue_count
    from public.tasks t
    join public.household_members hm on hm.user_id = t.assigned_to
      and hm.household_id = t.household_id
    join public.users u on u.id = hm.user_id
    where t.household_id = p_household_id
      and t.status in ('assigned', 'objected')
      and t.due_at is not null
      and t.due_at < now()
    group by hm.user_id, u.full_name, u.email, u.avatar_url
    having count(*) > 0
    order by count(*) desc
    limit 1
  ) t;

  -- Tarea mas olvidada: tarea recurrente que tenia que pasar esta semana
  -- (due_at en la ventana) y NO se completo. Tomamos la mas atrasada.
  select to_jsonb(t) into v_forgotten
  from (
    select tk.id, tk.title, tk.category,
           tk.due_at,
           extract(epoch from (now() - tk.due_at))::integer as overdue_seconds
    from public.tasks tk
    where tk.household_id = p_household_id
      and tk.type = 'recurring'
      and tk.status in ('assigned', 'objected')
      and tk.due_at is not null
      and tk.due_at < now()
      and tk.due_at >= v_week_start
    order by tk.due_at asc
    limit 1
  ) t;

  -- Gastos compartidos de la semana (excluye 'gift' y 'personal').
  select coalesce(sum(amount), 0) into v_spending_total
  from public.expenses
  where household_id = p_household_id
    and is_shared = true
    and type = 'expense'
    and paid_at >= v_week_start
    and paid_at < v_week_end;

  select coalesce(sum(amount), 0) into v_prev_spending
  from public.expenses
  where household_id = p_household_id
    and is_shared = true
    and type = 'expense'
    and paid_at >= v_prev_start
    and paid_at < v_prev_end;

  -- Top categoria de gasto de la semana.
  select to_jsonb(t) into v_top_category
  from (
    select coalesce(category, 'sin_categoria') as category,
           sum(amount) as total,
           count(*) as count
    from public.expenses
    where household_id = p_household_id
      and is_shared = true
      and type = 'expense'
      and paid_at >= v_week_start
      and paid_at < v_week_end
    group by coalesce(category, 'sin_categoria')
    order by sum(amount) desc
    limit 1
  ) t;

  return jsonb_build_object(
    'household_id', p_household_id,
    'week_start', v_week_start,
    'week_end', v_week_end,
    'generated_at', now(),
    'tasks_done', coalesce(v_tasks_done, 0),
    'tasks_planned', coalesce(v_tasks_planned, 0),
    'completion_rate', v_completion_rate,
    'tasks_done_last_week', coalesce(v_prev_done, 0),
    'tasks_done_delta', coalesce(v_tasks_done, 0) - coalesce(v_prev_done, 0),
    'mvp', v_mvp,
    'slacker', v_slacker,
    'forgotten_task', v_forgotten,
    'spending_total', v_spending_total,
    'spending_last_week', v_prev_spending,
    'spending_delta', v_spending_total - v_prev_spending,
    'top_category', v_top_category
  );
end;
$$;

grant execute on function public.get_weekly_family_summary(uuid, timestamptz)
  to authenticated, service_role;

comment on function public.get_weekly_family_summary(uuid, timestamptz) is
  'Sprint 4 Modo Padres: resumen semanal con totales, MVP, slacker, tarea olvidada y gastos vs semana anterior.';
