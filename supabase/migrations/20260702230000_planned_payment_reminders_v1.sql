-- Recordatorios de pagos planificados (feature premium).
--
-- generate_planned_payment_reminders_v1: pensado para correr 1 vez por dia
-- via cron (edge function planned-payment-reminders con service role).
-- Genera notificaciones para hogares PREMIUM:
--   * 'planned_payment_upcoming': el pago vence en exactamente 3 dias.
--   * 'planned_payment_due': el pago vence hoy.
--
-- Destinatarios: payer_default si esta seteado; si no, todos los adultos del
-- hogar (mismo filtro que los splits: parent/guardian/adult — teens y ninos
-- no reciben recordatorios de cuentas).
--
-- Idempotencia: una notificacion por (tipo, planned_expense, usuario) — el
-- NOT EXISTS hace que correr el cron dos veces el mismo dia no duplique.
-- Los planificados recurrentes generan una fila nueva por periodo (unique
-- template_id+due_date), asi que cada vencimiento recuerda una sola vez.
--
-- Copy sin tildes a proposito: sigue la convencion de las notificaciones
-- existentes escritas por RPCs (localizacion cliente pendiente — el `type` +
-- related_entity quedan estructurados para poder mapearlas despues).

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
  with candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join public.households h on h.id = pe.household_id
    where pe.status = 'pending'
      and coalesce(h.is_premium, false) = true
      and (h.premium_until is null or h.premium_until > now())
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

  with candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join public.households h on h.id = pe.household_id
    where pe.status = 'pending'
      and coalesce(h.is_premium, false) = true
      and (h.premium_until is null or h.premium_until > now())
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

-- Solo el cron (service role) puede ejecutarla; no es un RPC de clientes.
revoke execute on function public.generate_planned_payment_reminders_v1()
  from public, anon, authenticated;
grant execute on function public.generate_planned_payment_reminders_v1()
  to service_role;
