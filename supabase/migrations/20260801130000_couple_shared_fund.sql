-- The couple shared fund: the constructive half of the couple redesign.
--
-- Implements docs/couple-shared-fund-plan.md section 6 (schema) and the
-- two-key unlock ritual of section 2. Household effort feeds one shared pot
-- with a single active goal; nobody can spend it alone.
--
-- Decisions this migration takes on the open questions of section 10, so the
-- behaviour is not left to whoever reads the code next:
--
--   * A member leaves while a goal is ready -> confirmations cascade with the
--     membership row and the unlock re-evaluates against the members that are
--     left. No goal gets stuck waiting for a key nobody can turn.
--   * The household changes type with an accumulated fund -> nothing is
--     destroyed. Accrual simply stops, because only couple households feed the
--     pot. The history stays readable.
--   * Someone withdraws a confirmation after giving it -> allowed, as long as
--     the goal has not been unlocked yet. Deleting the row is the whole
--     mechanism, which is why confirmations are a table and not an array.
--   * A goal sits ready and nobody wants to unlock it -> changing the goal
--     cancels it without spending a single coin. Reaching a goal never forces
--     anybody to cash it in.
--   * More than two members in a couple household -> the unlock needs every
--     current member, not a hardcoded two. A misconfigured household degrades
--     into "everyone has to agree", which is the same rule with more people.
--
-- Nothing here touches family: coins, the rewards store and the ranking stay
-- exactly as they are.

-- ---------------------------------------------------------------------------
-- 1. Tables
-- ---------------------------------------------------------------------------

-- The fund ledger, deliberately separate from ledger_entries. Section 6 of the
-- plan documents why the balance cannot be derived from the personal ledger:
-- one row per performer double counts, redemptions use a different type, and
-- the idempotency key is personal.
create table if not exists public.household_fund_entries (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  amount integer not null check (amount <> 0),
  entry_type text not null check (entry_type in ('earned', 'spent')),
  source_type text not null check (source_type in ('task', 'goal_unlock')),
  source_id text not null,
  created_at timestamptz not null default now(),
  -- One task feeds the household once, no matter how many people completed it.
  constraint household_fund_entries_source_unique
    unique (household_id, source_type, source_id),
  constraint household_fund_entries_sign_matches_type check (
    (entry_type = 'earned' and amount > 0)
    or (entry_type = 'spent' and amount < 0)
  )
);

create index if not exists idx_household_fund_entries_household_created
  on public.household_fund_entries (household_id, created_at desc);

-- The active goal and the unlocked history.
create table if not exists public.household_fund_goals (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  catalog_key text,
  title text not null
    check (char_length(btrim(title)) between 3 and 120),
  icon text not null default '🎯'
    check (char_length(icon) between 1 and 8),
  cost integer not null check (cost between 50 and 2000),
  status text not null default 'active'
    check (status in ('active', 'ready', 'unlocked', 'cancelled')),
  created_by uuid references public.users(id) on delete set null,
  unlocked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Covers 'ready' too, on purpose: with `where status = 'active'` a goal waiting
-- for confirmations would let a second goal be opened in parallel.
create unique index if not exists idx_household_fund_goals_one_open
  on public.household_fund_goals (household_id)
  where status in ('active', 'ready');

create index if not exists idx_household_fund_goals_household_status
  on public.household_fund_goals (household_id, status, created_at desc);

-- The keys of the unlock ritual. A table rather than confirmed_by uuid[]:
-- a confirmation is a relation between a person and a goal, so it gets
-- referential integrity, a timestamp per person, and withdrawal by deletion.
create table if not exists public.household_fund_goal_confirmations (
  goal_id uuid not null
    references public.household_fund_goals(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  confirmed_at timestamptz not null default now(),
  primary key (goal_id, user_id)
);

-- Where a proposal came from, so the couple space can frame a fund
-- celebration differently from a wish someone typed in.
alter table public.couple_proposals
  add column if not exists origin text not null default 'member';

alter table public.couple_proposals
  add column if not exists origin_goal_id uuid
    references public.household_fund_goals(id) on delete set null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'couple_proposals_origin_check'
  ) then
    alter table public.couple_proposals
      add constraint couple_proposals_origin_check
      check (origin in ('member', 'fund_goal'));
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 2. RLS -- readable by the household, mutable only through the RPCs below
-- ---------------------------------------------------------------------------

alter table public.household_fund_entries enable row level security;
alter table public.household_fund_goals enable row level security;
alter table public.household_fund_goal_confirmations enable row level security;

drop policy if exists restrict_to_valid_jwt_household_fund_entries
  on public.household_fund_entries;
create policy restrict_to_valid_jwt_household_fund_entries
  on public.household_fund_entries
  as restrictive for all
  using ((select public.is_supabase_or_firebase_project_jwt()) is true)
  with check ((select public.is_supabase_or_firebase_project_jwt()) is true);

drop policy if exists "Household members can view fund entries"
  on public.household_fund_entries;
create policy "Household members can view fund entries"
  on public.household_fund_entries for select
  using (public.is_current_household_member(household_id));

drop policy if exists restrict_to_valid_jwt_household_fund_goals
  on public.household_fund_goals;
create policy restrict_to_valid_jwt_household_fund_goals
  on public.household_fund_goals
  as restrictive for all
  using ((select public.is_supabase_or_firebase_project_jwt()) is true)
  with check ((select public.is_supabase_or_firebase_project_jwt()) is true);

drop policy if exists "Household members can view fund goals"
  on public.household_fund_goals;
create policy "Household members can view fund goals"
  on public.household_fund_goals for select
  using (public.is_current_household_member(household_id));

drop policy if exists restrict_to_valid_jwt_household_fund_goal_confirmations
  on public.household_fund_goal_confirmations;
create policy restrict_to_valid_jwt_household_fund_goal_confirmations
  on public.household_fund_goal_confirmations
  as restrictive for all
  using ((select public.is_supabase_or_firebase_project_jwt()) is true)
  with check ((select public.is_supabase_or_firebase_project_jwt()) is true);

drop policy if exists "Household members can view fund confirmations"
  on public.household_fund_goal_confirmations;
create policy "Household members can view fund confirmations"
  on public.household_fund_goal_confirmations for select
  using (
    exists (
      select 1
      from public.household_fund_goals g
      where g.id = goal_id
        and public.is_current_household_member(g.household_id)
    )
  );

-- Realtime so both partners watch the same number move.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
  then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public' and tablename = 'household_fund_entries'
    ) then
      alter publication supabase_realtime
        add table public.household_fund_entries;
    end if;

    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public' and tablename = 'household_fund_goals'
    ) then
      alter publication supabase_realtime
        add table public.household_fund_goals;
    end if;
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Accrual -- inside the completion transaction, never a public RPC
-- ---------------------------------------------------------------------------

-- Section 6 is explicit that there must be no callable add_to_household_fund:
-- that would be the same hole as trusting client-sent rewards. Hanging the
-- accrual off the activity row keeps it inside complete_task_v1's transaction
-- while staying unreachable from the API, and the amount is read from the task
-- row rather than from anything the caller sent.
create or replace function public.accrue_couple_fund_on_activity()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_task_id uuid;
  v_amount integer;
begin
  if new.event_type is distinct from 'task_completed' then
    return new;
  end if;

  if not exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    return new;
  end if;

  begin
    v_task_id := nullif(new.metadata ->> 'task_id', '')::uuid;
  exception
    when invalid_text_representation then
      return new;
  end;

  if v_task_id is null then
    return new;
  end if;

  select least(greatest(coalesce(t.xp_reward, 0), 0), 50)
    into v_amount
  from public.tasks t
  where t.id = v_task_id
    and t.household_id = new.household_id;

  if coalesce(v_amount, 0) <= 0 then
    return new;
  end if;

  insert into public.household_fund_entries (
    household_id, amount, entry_type, source_type, source_id
  ) values (
    new.household_id, v_amount, 'earned', 'task', new.id::text
  )
  on conflict (household_id, source_type, source_id) do nothing;

  perform public.refresh_couple_fund_goal_state(new.household_id);

  return new;
end;
$function$;

drop trigger if exists accrue_couple_fund_on_activity_trigger
  on public.household_activities;
create trigger accrue_couple_fund_on_activity_trigger
after insert on public.household_activities
for each row execute function public.accrue_couple_fund_on_activity();

-- Flips the open goal to 'ready' once the pot covers it. Kept as its own
-- function so every write path lands on the same rule.
create or replace function public.refresh_couple_fund_goal_state(
  p_household_id uuid
) returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_balance integer;
begin
  select coalesce(sum(amount), 0)
    into v_balance
  from public.household_fund_entries
  where household_id = p_household_id;

  update public.household_fund_goals g
  set status = 'ready',
      updated_at = now()
  where g.household_id = p_household_id
    and g.status = 'active'
    and v_balance >= g.cost;
end;
$function$;

-- ---------------------------------------------------------------------------
-- 4. RPCs
-- ---------------------------------------------------------------------------

-- Replaces the open goal, cancelling whatever was there without spending the
-- fund. Reaching a goal never obliges anybody to cash it in.
create or replace function public.set_active_fund_goal_v1(
  p_household_id uuid,
  p_title text,
  p_cost integer,
  p_icon text default '🎯',
  p_catalog_key text default null
) returns public.household_fund_goals
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_goal public.household_fund_goals;
begin
  if v_actor is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if not public.is_current_household_member(p_household_id) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.households h
    where h.id = p_household_id and h.household_type = 'couple'
  ) then
    raise exception 'The shared fund is a couple-mode feature'
      using errcode = '22023';
  end if;

  update public.household_fund_goals g
  set status = 'cancelled',
      updated_at = now()
  where g.household_id = p_household_id
    and g.status in ('active', 'ready');

  insert into public.household_fund_goals (
    household_id, catalog_key, title, icon, cost, created_by
  ) values (
    p_household_id,
    nullif(btrim(coalesce(p_catalog_key, '')), ''),
    btrim(p_title),
    coalesce(nullif(btrim(p_icon), ''), '🎯'),
    p_cost,
    v_actor
  )
  returning * into v_goal;

  perform public.refresh_couple_fund_goal_state(p_household_id);

  select * into v_goal
  from public.household_fund_goals
  where id = v_goal.id;

  return v_goal;
end;
$function$;

-- One key. When the last one turns, the unlock runs in the same transaction:
-- the negative entry is idempotent through the source unique, so two
-- simultaneous confirmations cannot spend the pot twice.
create or replace function public.confirm_fund_goal_v1(
  p_goal_id uuid
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_goal public.household_fund_goals;
  v_balance integer;
  v_members integer;
  v_confirmations integer;
  v_proposal_id uuid;
  v_unlocked boolean := false;
begin
  if v_actor is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select * into v_goal
  from public.household_fund_goals
  where id = p_goal_id
  for update;

  if not found then
    raise exception 'Goal not found' using errcode = '23503';
  end if;

  if not public.is_current_household_member(v_goal.household_id) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  if v_goal.status <> 'ready' then
    raise exception 'Only a goal that reached its target can be confirmed'
      using errcode = '22023';
  end if;

  insert into public.household_fund_goal_confirmations (goal_id, user_id)
  values (p_goal_id, v_actor)
  on conflict (goal_id, user_id) do nothing;

  select count(*) into v_members
  from public.household_members hm
  where hm.household_id = v_goal.household_id;

  select count(*) into v_confirmations
  from public.household_fund_goal_confirmations c
  join public.household_members hm
    on hm.user_id = c.user_id
   and hm.household_id = v_goal.household_id
  where c.goal_id = p_goal_id;

  if v_confirmations >= greatest(v_members, 1) then
    select coalesce(sum(amount), 0) into v_balance
    from public.household_fund_entries
    where household_id = v_goal.household_id;

    if v_balance < v_goal.cost then
      raise exception 'The fund no longer covers this goal'
        using errcode = '22023';
    end if;

    insert into public.household_fund_entries (
      household_id, amount, entry_type, source_type, source_id
    ) values (
      v_goal.household_id, -v_goal.cost, 'spent', 'goal_unlock',
      v_goal.id::text
    )
    on conflict (household_id, source_type, source_id) do nothing;

    update public.household_fund_goals g
    set status = 'unlocked',
        unlocked_at = now(),
        updated_at = now()
    where g.id = p_goal_id
    returning * into v_goal;

    -- Reaching the goal does not buy the plan; it opens the conversation.
    -- The couple agrees, moves or postpones it like any other proposal.
    insert into public.couple_proposals (
      household_id, created_by, title, category, status,
      origin, origin_goal_id
    ) values (
      v_goal.household_id, v_actor, v_goal.title, 'plan', 'pending',
      'fund_goal', v_goal.id
    )
    returning id into v_proposal_id;

    v_unlocked := true;
  end if;

  return jsonb_build_object(
    'goal_id', v_goal.id,
    'status', v_goal.status,
    'confirmations', v_confirmations,
    'members', v_members,
    'unlocked', v_unlocked,
    'proposal_id', v_proposal_id
  );
end;
$function$;

create or replace function public.withdraw_fund_goal_confirmation_v1(
  p_goal_id uuid
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_goal public.household_fund_goals;
  v_confirmations integer;
begin
  if v_actor is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select * into v_goal
  from public.household_fund_goals
  where id = p_goal_id
  for update;

  if not found then
    raise exception 'Goal not found' using errcode = '23503';
  end if;

  if not public.is_current_household_member(v_goal.household_id) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  -- Withdrawing is only meaningful before the pot is actually spent.
  if v_goal.status <> 'ready' then
    raise exception 'This goal can no longer be changed'
      using errcode = '22023';
  end if;

  delete from public.household_fund_goal_confirmations
  where goal_id = p_goal_id and user_id = v_actor;

  select count(*) into v_confirmations
  from public.household_fund_goal_confirmations
  where goal_id = p_goal_id;

  return jsonb_build_object(
    'goal_id', p_goal_id,
    'status', v_goal.status,
    'confirmations', v_confirmations
  );
end;
$function$;

-- The whole couple-fund block in one round trip: balance, what the week added,
-- the open goal with its keys, and the rhythm. No per-person breakdown -- that
-- conversation belongs to the contribution view, in tasks and time.
create or replace function public.get_household_fund_v1(
  p_household_id uuid
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_balance integer;
  v_week_earned integer;
  v_week_start timestamptz;
  v_goal public.household_fund_goals;
  v_confirmations jsonb := '[]'::jsonb;
  v_members integer;
  v_rhythm integer;
begin
  if not public.is_current_household_member(p_household_id) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  v_week_start := date_trunc('week', now());

  select coalesce(sum(amount), 0) into v_balance
  from public.household_fund_entries
  where household_id = p_household_id;

  select coalesce(sum(amount), 0) into v_week_earned
  from public.household_fund_entries
  where household_id = p_household_id
    and entry_type = 'earned'
    and created_at >= v_week_start;

  select count(*) into v_members
  from public.household_members
  where household_id = p_household_id;

  select * into v_goal
  from public.household_fund_goals
  where household_id = p_household_id
    and status in ('active', 'ready')
  limit 1;

  if v_goal.id is not null then
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'user_id', c.user_id,
          'name', coalesce(u.full_name, u.email, ''),
          'confirmed_at', c.confirmed_at
        )
        order by c.confirmed_at
      ),
      '[]'::jsonb
    ) into v_confirmations
    from public.household_fund_goal_confirmations c
    join public.household_members hm
      on hm.user_id = c.user_id and hm.household_id = p_household_id
    left join public.users u on u.id = c.user_id
    where c.goal_id = v_goal.id;
  end if;

  -- Rhythm, not streak: active weeks within the last four. It does not need
  -- consecutive weeks, recovers on its own, and a quiet week lowers it without
  -- breaking anything.
  select count(distinct date_trunc('week', ha.created_at))
    into v_rhythm
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.event_type = 'task_completed'
    and ha.created_at >= v_week_start - interval '3 weeks';

  return jsonb_build_object(
    'household_id', p_household_id,
    'balance', v_balance,
    'week_earned', v_week_earned,
    'week_start', v_week_start,
    'members', v_members,
    'rhythm_weeks', coalesce(v_rhythm, 0),
    'rhythm_window', 4,
    'goal', case
      when v_goal.id is null then null
      else jsonb_build_object(
        'id', v_goal.id,
        'catalog_key', v_goal.catalog_key,
        'title', v_goal.title,
        'icon', v_goal.icon,
        'cost', v_goal.cost,
        'status', v_goal.status,
        'created_at', v_goal.created_at,
        'confirmations', v_confirmations
      )
    end
  );
end;
$function$;

-- ---------------------------------------------------------------------------
-- 5. Grants -- authenticated app clients only, never anon
-- ---------------------------------------------------------------------------

revoke execute on function public.accrue_couple_fund_on_activity()
  from public, anon, authenticated;
revoke execute on function public.refresh_couple_fund_goal_state(uuid)
  from public, anon, authenticated;

revoke execute on function public.set_active_fund_goal_v1(
  uuid, text, integer, text, text) from public, anon;
revoke execute on function public.confirm_fund_goal_v1(uuid)
  from public, anon;
revoke execute on function public.withdraw_fund_goal_confirmation_v1(uuid)
  from public, anon;
revoke execute on function public.get_household_fund_v1(uuid)
  from public, anon;

grant execute on function public.set_active_fund_goal_v1(
  uuid, text, integer, text, text) to authenticated;
grant execute on function public.confirm_fund_goal_v1(uuid) to authenticated;
grant execute on function public.withdraw_fund_goal_confirmation_v1(uuid)
  to authenticated;
grant execute on function public.get_household_fund_v1(uuid) to authenticated;

notify pgrst, 'reload schema';
