-- Premium familiar: sincroniza el toggle/mock con el plan del hogar.
--
-- El cliente historicamente leia users.is_premium. Para hogares familiares,
-- el producto correcto es por hogar: si un adulto activa Premium, todos los
-- miembros heredan el acceso mediante households.plan_tier.

create or replace function public.get_effective_premium_status()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where hm.user_id = public.current_app_user_id()
      and h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
  )
  or exists (
    select 1
    from public.users u
    where u.id = public.current_app_user_id()
      and coalesce(u.is_premium, false) = true
      and (u.premium_until is null or u.premium_until > now())
  );
$$;

create or replace function public.set_premium_status(
  p_is_premium boolean,
  p_premium_until timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller uuid := public.current_app_user_id();
  v_until timestamptz;
begin
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  v_until := case when p_is_premium then p_premium_until else null end;

  update public.users
  set
    is_premium = p_is_premium,
    premium_until = v_until
  where id in (
    select hm_all.user_id
    from public.household_members hm_self
    join public.household_members hm_all
      on hm_all.household_id = hm_self.household_id
    where hm_self.user_id = v_caller
  )
  or id = v_caller;

  update public.households h
  set
    plan_tier = case
      when p_is_premium and h.household_type = 'couple' then 'couple_premium'
      when p_is_premium then 'group_premium'
      else 'free'
    end,
    premium_until = v_until,
    subscription_owner_user_id = case when p_is_premium then v_caller else null end
  where exists (
    select 1
    from public.household_members hm
    where hm.household_id = h.id
      and hm.user_id = v_caller
  );

  return jsonb_build_object(
    'success', true,
    'is_premium', p_is_premium,
    'premium_until', v_until
  );
end;
$$;

create or replace function public.toggle_premium_mock()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_next boolean;
begin
  v_next := not public.get_effective_premium_status();
  return public.set_premium_status(
    v_next,
    case when v_next then now() + interval '30 days' else null end
  );
end;
$$;

revoke execute on function public.get_effective_premium_status() from public;
revoke execute on function public.set_premium_status(boolean, timestamptz) from public;
revoke execute on function public.toggle_premium_mock() from public;
revoke execute on function public.get_effective_premium_status() from anon;
revoke execute on function public.set_premium_status(boolean, timestamptz) from anon;
revoke execute on function public.toggle_premium_mock() from anon;

grant execute on function public.get_effective_premium_status()
  to authenticated, service_role;
grant execute on function public.set_premium_status(boolean, timestamptz)
  to authenticated, service_role;
grant execute on function public.toggle_premium_mock()
  to authenticated, service_role;

comment on function public.get_effective_premium_status() is
  'Premium efectivo para UI: true si el usuario o cualquiera de sus hogares tiene premium vigente.';
comment on function public.set_premium_status(boolean, timestamptz) is
  'Activa o desactiva Premium en el usuario y los hogares del usuario, para que el plan familiar se herede a todos los miembros.';
comment on function public.toggle_premium_mock() is
  'Testing/paywall mock: alterna Premium usando set_premium_status.';
