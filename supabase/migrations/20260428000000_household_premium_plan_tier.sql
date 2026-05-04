-- Sprint 0 (Modo Padres): premium por hogar.
--
-- Migra el premium de "por usuario" (users.is_premium) a "por hogar"
-- (households.plan_tier) sin romper el flujo existente: el cliente sigue
-- pudiendo leer users.is_premium, y a los hogares con cualquier miembro
-- premium se les setea plan_tier corresponiente para que la nueva capa
-- ya devuelva true desde el primer despliegue.

-- 1. Columnas nuevas en households -------------------------------------------
alter table public.households
  add column if not exists plan_tier text
    not null
    default 'free'
    check (plan_tier in (
      'free',
      'couple_premium',
      'couple_premium_founder',
      'group_premium',
      'group_premium_founder'
    )),
  add column if not exists premium_until timestamptz,
  add column if not exists subscription_owner_user_id uuid
    references public.users(id) on delete set null,
  add column if not exists founder_price_applied boolean
    not null
    default false,
  add column if not exists founder_granted_at timestamptz;

create index if not exists idx_households_plan_tier
  on public.households(plan_tier)
  where plan_tier <> 'free';

-- 2. Backfill desde users.is_premium -----------------------------------------
-- Para cada hogar donde algun miembro tiene is_premium=true, setear el plan_tier
-- segun household_type y guardar al primer miembro premium como subscription_owner.
-- Esto preserva el comportamiento actual: hogares que hoy ven funciones premium
-- las siguen viendo despues de desplegar este cambio.
--
-- Nota: el trigger validate_household_update() requiere usuario autenticado,
-- pero las migraciones corren sin JWT. Usamos session_replication_role para
-- saltarlo durante el backfill (es un cambio operativo, no un edit de usuario).
set local session_replication_role = 'replica';

with premium_members as (
  select
    hm.household_id,
    hm.user_id,
    u.premium_until,
    h.household_type,
    row_number() over (
      partition by hm.household_id
      order by hm.joined_at asc
    ) as rn
  from public.household_members hm
  join public.users u on u.id = hm.user_id
  join public.households h on h.id = hm.household_id
  where coalesce(u.is_premium, false) = true
), first_owner as (
  select household_id, user_id, premium_until, household_type
  from premium_members
  where rn = 1
)
update public.households h set
  plan_tier = case
    when fo.household_type = 'couple' then 'couple_premium'
    else 'group_premium'
  end,
  subscription_owner_user_id = fo.user_id,
  premium_until = fo.premium_until
from first_owner fo
where h.id = fo.household_id
  and h.plan_tier = 'free';

set local session_replication_role = 'origin';

-- 3. Helper: is_household_premium --------------------------------------------
-- Verdad si el hogar tiene plan_tier pago Y la suscripcion no expiro.
-- Sirve como punto unico para gatear features premium del lado servidor.
create or replace function public.is_household_premium(p_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.households h
    where h.id = p_household_id
      and h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
  );
$$;

grant execute on function public.is_household_premium(uuid) to authenticated, anon, service_role;

-- 4. RPC: get_household_premium_status ---------------------------------------
-- Devuelve el estado completo para que el cliente arme la UI de paywall y
-- sepa si tiene que mostrar "ofrecer renovacion" cuando premium_until esta por
-- vencer. Hace su propio check de membresia para no depender solo de RLS.
create or replace function public.get_household_premium_status(p_household_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_row record;
begin
  v_user_id := public.current_app_user_id();
  if v_user_id is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_user_id
  ) then
    raise exception 'Not a member of household %', p_household_id
      using errcode = '42501';
  end if;

  select
    h.id,
    h.plan_tier,
    h.premium_until,
    h.subscription_owner_user_id,
    h.founder_price_applied,
    (h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())) as is_premium
  into v_row
  from public.households h
  where h.id = p_household_id;

  if not found then
    raise exception 'Household % not found', p_household_id
      using errcode = '42704';
  end if;

  return jsonb_build_object(
    'household_id', v_row.id,
    'is_premium', v_row.is_premium,
    'plan_tier', v_row.plan_tier,
    'premium_until', v_row.premium_until,
    'subscription_owner_user_id', v_row.subscription_owner_user_id,
    'founder_price_applied', v_row.founder_price_applied
  );
end;
$$;

grant execute on function public.get_household_premium_status(uuid) to authenticated, service_role;

comment on function public.is_household_premium(uuid) is
  'Sprint 0 Modo Padres: gate unico de premium por hogar. Usar desde RPCs y RLS.';

comment on function public.get_household_premium_status(uuid) is
  'Sprint 0 Modo Padres: devuelve plan_tier, premium_until y owner para que el cliente arme UI/paywall.';

comment on column public.households.plan_tier is
  'free | couple_premium[_founder] | group_premium[_founder]. Setear via flujos de compra/admin.';
comment on column public.households.subscription_owner_user_id is
  'Usuario que gestiona la suscripcion. Los demas miembros heredan acceso premium.';
comment on column public.households.founder_price_applied is
  'true si el hogar tomo el cupo fundador. Se mantiene el precio mientras la suscripcion siga activa.';
