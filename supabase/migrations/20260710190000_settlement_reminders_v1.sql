-- Recordatorio semanal de liquidación (premium, economía dividida).
--
-- Para hogares premium con finance_mode <> 'shared' (en integrada no hay
-- deudas): calcula el balance neto por miembro con la MISMA semántica que
-- get_expense_balance (solo gastos + liquidaciones, solo compartidos) y le
-- recuerda al DEUDOR que tiene cuentas por saldar. Suave a propósito:
--   * solo deudas >= $1000 (por debajo es ruido, no vale una notificación);
--   * solo adultos (teens/niños no comparten cuentas);
--   * máximo una por usuario por semana (NOT EXISTS sobre 6 días).
--
-- Copy sin tildes a propósito (convención de notificaciones server-side);
-- params estructurados para localización cliente futura.

create or replace function public.generate_settlement_reminders_v1()
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_count integer := 0;
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
  divided as (
    select h.id
    from public.households h
    join premium_households ph on ph.id = h.id
    where coalesce(h.finance_mode, 'divided') <> 'shared'
  ),
  paid as (
    select e.household_id, e.paid_by as user_id, sum(e.amount) as amt
    from public.expenses e
    where e.household_id in (select id from divided)
      and e.type::text in ('expense', 'settlement')
      and coalesce(
        e.is_shared,
        case
          when lower(coalesce(e.split_type, 'equal')) in ('personal', 'gift')
            then false
          else true
        end
      ) = true
    group by 1, 2
  ),
  owed as (
    select e.household_id, es.user_id, sum(es.amount) as amt
    from public.expense_splits es
    join public.expenses e on e.id = es.expense_id
    where e.household_id in (select id from divided)
      and e.type::text in ('expense', 'settlement')
      and coalesce(
        e.is_shared,
        case
          when lower(coalesce(e.split_type, 'equal')) in ('personal', 'gift')
            then false
          else true
        end
      ) = true
    group by 1, 2
  ),
  net as (
    select
      coalesce(p.household_id, o.household_id) as household_id,
      coalesce(p.user_id, o.user_id) as user_id,
      coalesce(p.amt, 0) - coalesce(o.amt, 0) as balance
    from paid p
    full join owed o
      on o.household_id = p.household_id and o.user_id = p.user_id
  ),
  debtors as (
    select n.household_id, n.user_id, -n.balance as debt
    from net n
    join public.household_members hm
      on hm.household_id = n.household_id and hm.user_id = n.user_id
    where n.balance <= -1000
      and coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
  ),
  inserted as (
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id, params
    )
    select
      d.household_id,
      d.user_id,
      'Cuentas pendientes',
      'Tenes $' || to_char(round(d.debt), 'FM999999990')
        || ' por saldar en tu hogar. Equilibralo desde Inicio.',
      'settlement_reminder',
      'household',
      d.household_id,
      jsonb_build_object('amount', round(d.debt))
    from debtors d
    where not exists (
      select 1
      from public.notifications n
      where n.type = 'settlement_reminder'
        and n.user_id = d.user_id
        and n.household_id = d.household_id
        and n.created_at > now() - interval '6 days'
    )
    returning 1
  )
  select count(*) into v_count from inserted;

  return jsonb_build_object(
    'success', true,
    'reminders', v_count,
    'run_date', current_date
  );
end;
$function$;

-- Solo el cron (service role) puede ejecutarla; no es un RPC de clientes.
revoke execute on function public.generate_settlement_reminders_v1()
  from public, anon, authenticated;
grant execute on function public.generate_settlement_reminders_v1()
  to service_role;

-- Lunes 12:00 UTC (9:00 AR): arranque de semana, momento natural de ponerse
-- al día. cron.schedule con jobname es idempotente (re-agenda si ya existe).
select cron.schedule(
  'settlement-reminders-weekly',
  '0 12 * * 1',
  'select public.generate_settlement_reminders_v1();'
);
