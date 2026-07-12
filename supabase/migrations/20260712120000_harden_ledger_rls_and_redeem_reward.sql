-- Harden the coin/XP ledger and reward redemption.
--
-- 1) The INSERT/UPDATE policies from 20260302144031 never referenced the
--    caller's identity: they only required the row's user_id to be a member of
--    the row's household, so ANY authenticated user could insert or rewrite
--    ledger_entries for any member of any household (coin/XP forgery).
--    Every legitimate ledger writer is a SECURITY DEFINER RPC by now
--    (complete_task_transaction, award_weekly_winner,
--    complete_couple_challenge_v1, admin QA bridges) and the Flutter client
--    never writes ledger_entries directly, so the client-facing INSERT/UPDATE
--    policies can be dropped outright. SELECT policies (rewritten by the
--    Firebase identity bridge phase 2) stay as they are.
--
-- 2) redeem_reward was the last SECURITY INVOKER writer and trusted a
--    caller-supplied p_user_id (one member could spend the other's coins).
--    It becomes SECURITY DEFINER, derives the user from the session via
--    current_app_user_id(), and keeps its (p_reward_id, p_user_id) signature
--    so queued offline replays from existing clients keep working — but
--    p_user_id is now validated against the session instead of trusted.
--    It also serializes concurrent redemptions per user+household so two
--    devices can't both pass the balance check before either debit lands.

drop policy if exists "Users can insert own ledger" on public.ledger_entries;
drop policy if exists "Users can update own ledger" on public.ledger_entries;

create or replace function public.redeem_reward(
  p_reward_id uuid,
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller uuid;
  v_reward record;
  v_user_balance integer;
  v_redemption_id uuid;
begin
  v_caller := public.current_app_user_id();
  if v_caller is null then
    return jsonb_build_object(
      'success', false,
      'code', 'not_authenticated',
      'message', 'Sesion no valida'
    );
  end if;

  -- Existing clients pass their own id; reject mismatches instead of
  -- trusting the parameter.
  if p_user_id is not null and p_user_id <> v_caller then
    return jsonb_build_object(
      'success', false,
      'code', 'forbidden',
      'message', 'No podes canjear premios en nombre de otra persona'
    );
  end if;

  select r.* into v_reward
  from public.rewards r
  where r.id = p_reward_id
    and r.is_active = true;

  if not found or not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_reward.household_id
      and hm.user_id = v_caller
  ) then
    return jsonb_build_object(
      'success', false,
      'code', 'not_found',
      'message', 'Recompensa no encontrada'
    );
  end if;

  perform pg_advisory_xact_lock(
    hashtext(v_caller::text || ':' || v_reward.household_id::text)
  );

  select coalesce(sum(amount), 0) into v_user_balance
  from public.ledger_entries
  where user_id = v_caller
    and household_id = v_reward.household_id
    and currency = 'COIN';

  if v_user_balance < v_reward.cost then
    return jsonb_build_object(
      'success', false,
      'code', 'insufficient_coins',
      'message', 'No tienes suficientes coins',
      'balance', v_user_balance,
      'cost', v_reward.cost
    );
  end if;

  insert into public.ledger_entries (
    household_id, user_id, type, amount, currency,
    reference_type, description
  ) values (
    v_reward.household_id, v_caller, 'reward_redemption', -v_reward.cost,
    'COIN', 'reward', 'Canje: ' || v_reward.title
  );

  insert into public.reward_redemptions (
    reward_id, user_id, household_id, cost, status
  ) values (
    p_reward_id, v_caller, v_reward.household_id, v_reward.cost, 'pending'
  ) returning id into v_redemption_id;

  return jsonb_build_object(
    'success', true,
    'message', 'Recompensa canjeada',
    'redemption_id', v_redemption_id,
    'new_balance', v_user_balance - v_reward.cost
  );
end;
$$;

revoke execute on function public.redeem_reward(uuid, uuid) from anon;
