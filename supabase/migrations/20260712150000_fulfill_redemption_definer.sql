-- Habilitar el flujo de cumplimiento de canjes (bandeja "por entregar").
--
-- fulfill_redemption existía desde 20260219212802 pero ningún cliente lo
-- consumía, y su forma original era inutilizable desde la app:
--   1) SECURITY INVOKER + reward_redemptions sin política UPDATE ⇒ el UPDATE
--      final moría contra RLS incluso para un caller legítimo.
--   2) Exigía role = 'owner'; entregar un premio es cosa de cualquier adulto
--      del hogar (en pareja ambos miembros son adultos, en familia también
--      pueden cumplir los tutores).
--   3) Confiaba en el p_user_id provisto por el caller (el mismo agujero que
--      redeem_reward tenía antes de 20260712120000).
--
-- Se recrea en la misma línea que redeem_reward: SECURITY DEFINER, deriva el
-- caller de current_app_user_id() y valida p_user_id contra la sesión (los
-- clientes siguen mandando su propio id). El SELECT ... FOR UPDATE serializa
-- dos adultos marcando el mismo canje a la vez: el segundo ve status ya
-- 'fulfilled' y recibe un fallo de negocio en vez de pisar fulfilled_by.
-- Ninguna tabla necesita política UPDATE nueva: el cliente nunca escribe
-- reward_redemptions directo (ver 20260712120000).

create or replace function public.fulfill_redemption(
  p_redemption_id uuid,
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller uuid;
  v_redemption record;
begin
  v_caller := public.current_app_user_id();
  if v_caller is null then
    return jsonb_build_object(
      'success', false,
      'code', 'not_authenticated',
      'message', 'Sesion no valida'
    );
  end if;

  if p_user_id is not null and p_user_id <> v_caller then
    return jsonb_build_object(
      'success', false,
      'code', 'forbidden',
      'message', 'No podes marcar canjes en nombre de otra persona'
    );
  end if;

  select * into v_redemption
  from public.reward_redemptions
  where id = p_redemption_id
  for update;

  if not found or v_redemption.status <> 'pending' then
    return jsonb_build_object(
      'success', false,
      'code', 'not_found',
      'message', 'Canje no encontrado o ya procesado'
    );
  end if;

  if v_redemption.user_id = v_caller then
    return jsonb_build_object(
      'success', false,
      'code', 'own_redemption',
      'message', 'El canje lo marca quien entrega el premio, no quien lo pidio'
    );
  end if;

  -- Adulto del hogar del canje. member_type usa NOT IN por si quedara alguna
  -- fila legada con 'adult' (hoy el check permite parent/guardian/teen/child).
  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_redemption.household_id
      and hm.user_id = v_caller
      and hm.member_type not in ('child', 'teen')
  ) then
    return jsonb_build_object(
      'success', false,
      'code', 'forbidden',
      'message', 'Solo un adulto del hogar puede marcar canjes como entregados'
    );
  end if;

  update public.reward_redemptions
  set status = 'fulfilled',
      fulfilled_by = v_caller,
      fulfilled_at = now()
  where id = p_redemption_id;

  return jsonb_build_object(
    'success', true,
    'message', 'Recompensa entregada'
  );
end;
$$;

revoke execute on function public.fulfill_redemption(uuid, uuid) from anon;

-- Realtime para la bandeja de canjes: el otro miembro ve aparecer/desaparecer
-- canjes en vivo (mismo patrón que la tabla rewards). Idempotente por si la
-- tabla ya estuviera publicada desde el dashboard.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'reward_redemptions'
  ) then
    alter publication supabase_realtime add table public.reward_redemptions;
  end if;
end $$;
