-- Modo Padres: cron para disparar el resumen semanal cada domingo.
--
-- Comportamiento V1:
--   Cada domingo a las 23:00 UTC (~20:00 ART), insertamos una notification
--   in-app por cada owner/admin de hogares family con premium activo. La
--   notificacion deep-linkea al resumen via type=weekly_summary_ready.
--
-- Limitacion conocida: timezone unico (UTC). Hogares en UTC+ verian el
-- "domingo a la noche" del lunes a la madrugada. Si esto importa en el
-- futuro, agregar households.timezone y bucketear el cron por offset.
--
-- No persiste el resumen — sigue siendo on-demand via get_weekly_family_summary.

create extension if not exists pg_cron;

create or replace function public.dispatch_weekly_family_summary_notifications()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_inserted integer := 0;
  v_row record;
begin
  for v_row in
    select distinct hm.user_id, hm.household_id
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where h.household_type = 'family'
      and h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
      and hm.role in ('owner', 'admin')
  loop
    insert into public.notifications (
      household_id, user_id, created_by_id,
      title, body, type, related_entity_type, related_entity_id
    ) values (
      v_row.household_id, v_row.user_id, v_row.user_id,
      'Tu resumen semanal esta listo',
      'Mira como cerro la semana del hogar: cumplimiento, MVP y gastos.',
      'weekly_summary_ready',
      'household',
      v_row.household_id
    );
    v_inserted := v_inserted + 1;
  end loop;
  return v_inserted;
end;
$$;

grant execute on function public.dispatch_weekly_family_summary_notifications()
  to service_role;

-- Idempotente: si ya existe la entrada de cron, la reemplazamos.
do $$
begin
  perform cron.unschedule('weekly-family-summary');
exception when others then
  -- no existia, ok
  null;
end $$;

select cron.schedule(
  'weekly-family-summary',
  '0 23 * * 0',
  $cron$select public.dispatch_weekly_family_summary_notifications();$cron$
);

comment on function public.dispatch_weekly_family_summary_notifications() is
  'Modo Padres: corre semanalmente via pg_cron y crea una notification por cada owner/admin de family premium.';
