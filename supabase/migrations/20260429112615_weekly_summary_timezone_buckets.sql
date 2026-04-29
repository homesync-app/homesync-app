-- Modo Padres: bucketear el resumen semanal por timezone del hogar.
--
-- En lugar de disparar todos los resumenes a una hora UTC fija, el cron corre
-- una vez por hora y la funcion solo inserta notifications para hogares cuyo
-- horario local sea domingo 20:00. Esto mantiene el comportamiento actual para
-- Argentina y escala mejor cuando haya hogares en otros paises.

alter table public.households
  add column if not exists timezone text
    not null
    default 'America/Argentina/Buenos_Aires';

create index if not exists idx_households_weekly_summary_timezone
  on public.households(timezone)
  where household_type = 'family'
    and plan_tier <> 'free';

create or replace function public.dispatch_weekly_family_summary_notifications()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_inserted integer := 0;
  v_now timestamptz := now();
begin
  insert into public.notifications (
    household_id,
    user_id,
    created_by_id,
    title,
    body,
    type,
    related_entity_type,
    related_entity_id
  )
  select distinct
    hm.household_id,
    hm.user_id,
    hm.user_id,
    'Tu resumen semanal esta listo',
    'Mira como cerro la semana del hogar: cumplimiento, MVP y gastos.',
    'weekly_summary_ready',
    'household',
    hm.household_id
  from public.household_members hm
  join public.households h on h.id = hm.household_id
  where h.household_type = 'family'
    and h.plan_tier <> 'free'
    and (h.premium_until is null or h.premium_until > v_now)
    and hm.role in ('owner', 'admin')
    and extract(dow from timezone(h.timezone, v_now)) = 0
    and extract(hour from timezone(h.timezone, v_now)) = 20
    and not exists (
      select 1
      from public.notifications n
      where n.household_id = hm.household_id
        and n.user_id = hm.user_id
        and n.type = 'weekly_summary_ready'
        and n.related_entity_type = 'household'
        and n.related_entity_id = hm.household_id
        and n.created_at >= (
          date_trunc('week', timezone(h.timezone, v_now))
          at time zone h.timezone
        )
    );

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$$;

grant execute on function public.dispatch_weekly_family_summary_notifications()
  to service_role;

do $$
begin
  perform cron.unschedule('weekly-family-summary');
exception when others then
  null;
end $$;

select cron.schedule(
  'weekly-family-summary',
  '0 * * * *',
  $cron$select public.dispatch_weekly_family_summary_notifications();$cron$
);

comment on column public.households.timezone is
  'IANA timezone used for household-local scheduled jobs, e.g. weekly family summaries.';

comment on function public.dispatch_weekly_family_summary_notifications() is
  'Modo Padres: corre hourly via pg_cron y crea resumen semanal cuando el hogar llega a domingo 20:00 local.';
