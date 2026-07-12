-- Server-side seeding for the family rewards catalog.
--
-- Until now the Flutter client inserted the family default rewards directly
-- into public.rewards, which had two problems:
--   1) No existence guard: two parents opening the app at the same time on an
--      empty store both seeded, duplicating the whole catalog.
--   2) The manual "load initial catalog" button fell back to
--      clone_reward_templates(), which clones the COUPLE boutique regardless
--      of household type.
-- This RPC mirrors qa_admin_seed_default_rewards' family branch for regular
-- users: membership check, advisory lock + EXISTS guard (idempotent), and the
-- same 12 defaults. Titles/descriptions match the client constants so the
-- set_reward_localization_keys trigger resolves their translation keys.

create or replace function public.seed_family_default_rewards_v1(
  p_household_id uuid
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller uuid;
  v_count integer := 0;
begin
  v_caller := public.current_app_user_id();
  if v_caller is null then
    raise exception 'not_authenticated';
  end if;

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_caller
  ) then
    raise exception 'forbidden';
  end if;

  -- Serialize concurrent seeding attempts for the same household.
  perform pg_advisory_xact_lock(
    hashtext('seed_rewards:' || p_household_id::text)
  );

  if exists (
    select 1 from public.rewards where household_id = p_household_id
  ) then
    return 0;
  end if;

  insert into public.rewards (
    household_id, title, description, cost, icon,
    is_active, created_by, is_approved, category, target_type
  )
  values
    (p_household_id, 'Postre especial', 'Elegir un postre favorito para despues de cenar.', 25, '🍨', true, v_caller, true, 'familia', 'child'),
    (p_household_id, 'Elegir la cena', 'Decidir el menu de una noche en casa.', 40, '🍕', true, v_caller, true, 'familia', 'child'),
    (p_household_id, '15 minutos extra de pantalla', 'Un ratito mas para jugar o mirar algo.', 35, '📱', true, v_caller, true, 'familia', 'child'),
    (p_household_id, 'Juguete o premio pequeno', 'Canje por algo simple elegido con un adulto.', 90, '🧩', true, v_caller, true, 'familia', 'child'),
    (p_household_id, 'Cafe o mate preparado', 'Un mimo simple tomado del modo pareja.', 30, '☕', true, v_caller, true, 'familia', 'adult'),
    (p_household_id, '15 minutos de masajes', 'Un premio corto para bajar un cambio.', 60, '💆', true, v_caller, true, 'familia', 'adult'),
    (p_household_id, 'Vale por elegir la peli', 'Elegis que ver sin negociar esa noche.', 55, '🎬', true, v_caller, true, 'familia', 'adult'),
    (p_household_id, 'Cena casera especial', 'Una noche distinta con algo rico hecho en casa.', 95, '🍽️', true, v_caller, true, 'familia', 'adult'),
    (p_household_id, 'Noche de peli', 'Plan simple para disfrutar todos juntos.', 80, '🎥', true, v_caller, true, 'familia', 'all'),
    (p_household_id, 'Helado para todos', 'Salida o pedido de helado familiar.', 110, '🍦', true, v_caller, true, 'familia', 'all'),
    (p_household_id, 'Pedir comida', 'Una noche sin cocinar para toda la familia.', 180, '🥡', true, v_caller, true, 'familia', 'all'),
    (p_household_id, 'Plan del fin de semana', 'Elegir una salida o actividad para hacer juntos.', 160, '🌟', true, v_caller, true, 'familia', 'all');

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke execute on function public.seed_family_default_rewards_v1(uuid) from anon;
