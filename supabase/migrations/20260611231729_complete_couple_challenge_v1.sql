-- Completar el desafío semanal de pareja en UNA sola transacción atómica.
-- Reemplaza las 3 llamadas encadenadas desde el cliente (create_task ->
-- complete_task_v1 -> upsert couple_challenge_completions) que dejaban estado
-- a medias si la app moría en el medio, y que además creaban una tarea
-- fantasma en la lista. Acredita XP+coins a cada miembro vía ledger y deja la
-- actividad en el feed, sin task de respaldo.
--
-- Idempotente por dos vías:
--   - PK (household_id, week_index): una completación por hogar por semana.
--   - request_id en household_activities + (user_id,type,reference_id) en
--     ledger: reintentos de red no duplican coins.
create or replace function public.complete_couple_challenge_v1(
  p_request_id text,
  p_household_id uuid,
  p_week_index integer,
  p_challenge_id text,
  p_user_ids uuid[],
  p_xp_reward integer,
  p_coin_reward integer,
  p_title text,
  p_description text default null,
  p_completed_by uuid default null
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_user_id uuid;
  v_activity_id uuid;
  v_completer uuid := coalesce(p_completed_by, p_user_ids[1]);
  v_activity_request_id text;
begin
  if p_user_ids is null or coalesce(array_length(p_user_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', false,
      'status', 'invalid',
      'message', 'At least one performer is required'
    );
  end if;

  -- Guardia de unicidad: si ya estaba registrada esta semana, NO re-acreditar.
  insert into public.couple_challenge_completions (
    household_id, week_index, challenge_id, completed_by
  ) values (
    p_household_id, p_week_index, p_challenge_id, v_completer
  )
  on conflict (household_id, week_index) do nothing;

  if not found then
    return jsonb_build_object(
      'success', true,
      'status', 'already_completed',
      'message', 'Challenge already completed this week',
      'duplicate', true
    );
  end if;

  -- Actividad en el feed (idempotente por request_id).
  v_activity_request_id :=
    'challenge:' || coalesce(p_request_id, gen_random_uuid()::text);

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata, request_id
  ) values (
    p_household_id, v_completer, 'task_completed', p_title, p_description,
    jsonb_build_object(
      'challenge_id', p_challenge_id,
      'week_index', p_week_index,
      'xp_per_user', p_xp_reward,
      'coins_per_user', p_coin_reward,
      'performers', p_user_ids,
      'is_couple_challenge', true
    ),
    v_activity_request_id
  )
  on conflict (request_id) where request_id is not null do nothing
  returning id into v_activity_id;

  if v_activity_id is null then
    select id into v_activity_id
    from public.household_activities
    where request_id = v_activity_request_id;
  end if;

  -- Acreditar XP y coins a cada miembro (idempotente por reference_id).
  foreach v_user_id in array p_user_ids loop
    if p_xp_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned',
        p_xp_reward, 'XP', v_activity_id::text, 'activity',
        'XP: ' || p_title, 'rpc', v_user_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;

    if p_coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned',
        p_coin_reward, 'COIN', v_activity_id::text, 'activity',
        'Coins: ' || p_title, 'rpc', v_user_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;
  end loop;

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id, v_completer, p_household_id, 'complete_couple_challenge',
    'couple_challenge', v_activity_id,
    jsonb_build_object(
      'challenge_id', p_challenge_id,
      'week_index', p_week_index,
      'performers', p_user_ids,
      'activity_id', v_activity_id
    ),
    'Couple challenge completed', 'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'status', 'completed',
    'activity_id', v_activity_id,
    'xp_earned', p_xp_reward,
    'coins_earned', p_coin_reward
  );
end;
$function$;

revoke execute on function public.complete_couple_challenge_v1(
  text, uuid, integer, text, uuid[], integer, integer, text, text, uuid
) from public;
grant execute on function public.complete_couple_challenge_v1(
  text, uuid, integer, text, uuid[], integer, integer, text, text, uuid
) to authenticated;
