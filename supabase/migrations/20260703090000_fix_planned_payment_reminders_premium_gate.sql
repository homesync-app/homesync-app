-- Fix del gate premium en generate_planned_payment_reminders_v1.
--
-- La version anterior filtraba por households.is_premium, columna que NO
-- existe (plpgsql no valida columnas al crear la funcion; habria fallado en
-- runtime en la primera corrida del cron). La semantica real de premium
-- (espejo de get_effective_premium_status) es:
--   * households.plan_tier <> 'free' con premium_until vigente, O
--   * algun miembro con users.is_premium vigente (premium personal cubre al
--     hogar, igual que en el resto de la app).

create or replace function public.generate_planned_payment_reminders_v1()
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_upcoming integer := 0;
  v_due integer := 0;
begin
  with premium_households as (
    select h.id
    from public.households h
    where h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
    union
    select hm.household_id
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    where coalesce(u.is_premium, false) = true
      and (u.premium_until is null or u.premium_until > now())
  ),
  candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join premium_households ph on ph.id = pe.household_id
    where pe.status = 'pending'
      and pe.due_date = current_date + 3
  ),
  recipients as (
    select c.id, c.household_id, c.title, c.amount, c.due_date, hm.user_id
    from candidates c
    join public.household_members hm on hm.household_id = c.household_id
    where coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
      and (c.payer_default is null or hm.user_id = c.payer_default)
  ),
  inserted as (
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id
    )
    select
      r.household_id,
      r.user_id,
      'Pago proximo: ' || r.title,
      'Vence el ' || to_char(r.due_date, 'DD/MM')
        || ' - $' || to_char(r.amount, 'FM999999990'),
      'planned_payment_upcoming',
      'planned_expense',
      r.id
    from recipients r
    where not exists (
      select 1
      from public.notifications n
      where n.type = 'planned_payment_upcoming'
        and n.related_entity_id = r.id
        and n.user_id = r.user_id
    )
    returning 1
  )
  select count(*) into v_upcoming from inserted;

  with premium_households as (
    select h.id
    from public.households h
    where h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
    union
    select hm.household_id
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    where coalesce(u.is_premium, false) = true
      and (u.premium_until is null or u.premium_until > now())
  ),
  candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join premium_households ph on ph.id = pe.household_id
    where pe.status = 'pending'
      and pe.due_date = current_date
  ),
  recipients as (
    select c.id, c.household_id, c.title, c.amount, c.due_date, hm.user_id
    from candidates c
    join public.household_members hm on hm.household_id = c.household_id
    where coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
      and (c.payer_default is null or hm.user_id = c.payer_default)
  ),
  inserted as (
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id
    )
    select
      r.household_id,
      r.user_id,
      'Vence hoy: ' || r.title,
      'Registralo desde Finanzas cuando lo pagues - $'
        || to_char(r.amount, 'FM999999990'),
      'planned_payment_due',
      'planned_expense',
      r.id
    from recipients r
    where not exists (
      select 1
      from public.notifications n
      where n.type = 'planned_payment_due'
        and n.related_entity_id = r.id
        and n.user_id = r.user_id
    )
    returning 1
  )
  select count(*) into v_due from inserted;

  return jsonb_build_object(
    'success', true,
    'upcoming', v_upcoming,
    'due_today', v_due,
    'run_date', current_date
  );
end;
$function$;
