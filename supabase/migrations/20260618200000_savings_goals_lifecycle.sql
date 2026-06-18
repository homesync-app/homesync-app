-- Savings goals lifecycle: target date, completion, archival and authorship.
--
-- Adds the columns the client now reads/writes (target_date, completed_at,
-- archived_at, created_by) and teaches the contribution trigger to stamp
-- completed_at when a goal reaches its target (and clear it if a deletion
-- drops it back below). Archived goals are filtered out of the active list
-- client-side via `archived_at is null`.

alter table public.savings_goals
  add column if not exists target_date timestamptz,
  add column if not exists completed_at timestamptz,
  add column if not exists archived_at timestamptz,
  add column if not exists created_by uuid references auth.users(id) on delete set null;

-- Active-goal lookups always filter household_id + archived_at is null.
create index if not exists idx_savings_goals_active
  on public.savings_goals (household_id)
  where archived_at is null;

-- Keep current_amount in sync AND maintain completed_at as a derived stamp.
create or replace function public.update_goal_current_amount()
returns trigger as $$
declare
  v_goal_id uuid;
begin
  if (TG_OP = 'INSERT') then
    v_goal_id := NEW.goal_id;
    update public.savings_goals
    set current_amount = current_amount + NEW.amount,
        updated_at = now()
    where id = v_goal_id;
  elsif (TG_OP = 'DELETE') then
    v_goal_id := OLD.goal_id;
    update public.savings_goals
    set current_amount = current_amount - OLD.amount,
        updated_at = now()
    where id = v_goal_id;
  end if;

  -- Stamp completion the first time the target is met; clear it if a later
  -- deletion of a contribution drops the goal back under target.
  update public.savings_goals
  set completed_at = case
        when current_amount >= target_amount and completed_at is null then now()
        when current_amount < target_amount then null
        else completed_at
      end
  where id = v_goal_id;

  return null;
end;
$$ language plpgsql;

-- Trigger definition is unchanged but re-created defensively in case it was
-- dropped between schema resets.
drop trigger if exists tr_update_goal_amount on public.savings_contributions;

create trigger tr_update_goal_amount
after insert or delete on public.savings_contributions
for each row execute function public.update_goal_current_amount();

-- Drop the orphaned add_savings_contribution RPC. The client never calls it
-- (contributions go through a direct insert + a matching ledger expense), so
-- its parallel ledger_entries/household_activities writes were dead code that
-- risked double-counting if ever wired up. Safe to remove (no references in
-- the app, edge functions, or other migrations).
drop function if exists public.add_savings_contribution(uuid, uuid, numeric, text);
