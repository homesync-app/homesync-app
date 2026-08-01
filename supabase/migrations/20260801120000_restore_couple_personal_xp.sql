-- Couple mode keeps personal XP; only the coin economy is retired.
--
-- 20260726120000_couple_connection_space blocked both XP and COIN for couple
-- households. That went further than the design it implements: coins were the
-- toxic part because they were convertible into the other person's behaviour.
-- XP is self-referential progress -- it buys nothing from anybody -- so it
-- stays, under the constraint that it is never shown comparatively.
--
-- This migration narrows every couple guard from "no gamification" to "no
-- coins", and restores the task XP that the previous backfill zeroed.

-- 1. Ledger: drop COIN rows for couples, let XP through.
create or replace function public.prevent_couple_gamification_ledger()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if new.currency = 'COIN'
    and exists (
      select 1
      from public.households h
      where h.id = new.household_id
        and h.household_type = 'couple'
    )
  then
    return null;
  end if;

  return new;
end;
$function$;

comment on function public.prevent_couple_gamification_ledger() is
  'Couple households have no coin economy. XP is personal progress and is allowed.';

-- 2. Task rewards: couples get the same bounded XP as every other mode, but
--    their coin reward stays pinned to zero.
create or replace function public.normalize_task_rewards_v1()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  new.xp_reward := least(greatest(coalesce(new.xp_reward, 0), 0), 50);

  if exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    new.coin_reward := 0;
  else
    new.coin_reward := least(greatest(coalesce(new.coin_reward, 0), 0), 5);
  end if;

  return new;
end;
$function$;

-- 3. Activity metadata: strip the coin keys, keep the XP ones so the feed can
--    still say what a completion was worth to the person who did it.
create or replace function public.strip_couple_activity_rewards()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    new.metadata := coalesce(new.metadata, '{}'::jsonb)
      - 'coins_reward'
      - 'coins_per_user'
      - 'coins'
      - 'reward_cost';
  end if;

  return new;
end;
$function$;

-- 4. Restore the XP the previous backfill zeroed. The difficulty -> XP mapping
--    is read from what every non-couple household already stores, so couples
--    land on exactly the same scale rather than an invented one:
--    small/easy = 5, medium = 10, normal = 15, big = 35, heavy = 50.
update public.tasks t
set xp_reward = case lower(coalesce(t.difficulty, 'normal'))
      when 'small' then 5
      when 'easy' then 5
      when 'medium' then 10
      when 'normal' then 15
      when 'big' then 35
      when 'heavy' then 50
      else 15
    end,
    updated_at = now()
from public.households h
where h.id = t.household_id
  and h.household_type = 'couple'
  and coalesce(t.xp_reward, 0) = 0;

-- Re-run the approval normalizer so pending rows pick the restored task XP up.
update public.task_approvals
set xp_reward = xp_reward
where status = 'pending';

notify pgrst, 'reload schema';
