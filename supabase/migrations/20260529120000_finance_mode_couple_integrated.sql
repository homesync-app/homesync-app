-- ============================================
-- Finance mode: enable integrated (shared) economy for couples
-- ============================================
-- Contexto:
--   La columna households.finance_mode quedó con DEFAULT 'shared' (migración
--   20260505000000). Hasta ahora la app solo respetaba 'shared' para hogares
--   'family'; en pareja/convivencia el modo se ignoraba y siempre se dividía.
--
--   A partir de este cambio, las PAREJAS también pueden elegir "economía
--   integrada" (finance_mode = 'shared'): los gastos quedan registrados para
--   el hogar pero no generan deuda ni balances entre los dos.
--
-- Riesgo a mitigar:
--   Hogares no-familiares creados después de 20260505 tienen 'shared' guardado
--   por el default, aunque en la práctica venían operando como 'divided'. Si no
--   se normalizan, al desplegar este cambio "saltarían" de golpe a economía
--   integrada sin que el usuario lo haya elegido. Por eso se hace backfill a
--   'divided' (preserva el comportamiento actual; pueden activar integrada
--   manualmente desde la pantalla de finanzas).
-- ============================================

-- 1) Restaurar default sano de la columna: 'divided'.
--    La creación de hogares setea finance_mode explícitamente (ver punto 3),
--    así que esto solo cubre otros inserts (seeds/clones) que no lo especifican.
alter table public.households
  alter column finance_mode set default 'divided';

-- 2) Backfill: hogares no familiares que quedaron en 'shared' por el default
--    vuelven a 'divided'. Las familias se mantienen en 'shared'.
--    (Se corre sin JWT durante la migración; saltamos el trigger de validación
--     de columnas de households igual que en backfills previos.)
alter table public.households disable trigger user;

update public.households
set finance_mode = 'divided'
where household_type <> 'family'
  and finance_mode = 'shared';

alter table public.households enable trigger user;

-- 3) Recrear ensure_household_for_user para fijar finance_mode explícitamente
--    según el tipo de hogar: family => 'shared', resto => 'divided'.
create or replace function public.ensure_household_for_user(p_household_type text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_household_id uuid;
  v_finance_mode text;
begin
  v_user_id := public.current_app_user_id();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Modo financiero por defecto según el tipo de hogar.
  v_finance_mode := case
    when p_household_type = 'family' then 'shared'
    else 'divided'
  end;

  select household_id into v_household_id
  from public.household_members
  where user_id = v_user_id
  limit 1;

  if v_household_id is not null then
    update public.households
    set household_type = p_household_type
    where id = v_household_id and household_type != p_household_type;
    return v_household_id;
  end if;

  insert into public.households (name, household_type, finance_mode)
  values ('Mi Hogar', p_household_type, v_finance_mode)
  returning id into v_household_id;

  insert into public.household_members (household_id, user_id, role, onboarding_completed)
  values (v_household_id, v_user_id, 'owner', false);

  return v_household_id;
end;
$$;
