-- Shared, voluntary plans. Cosmetic stamps only: no XP, coins, approvals,
-- notifications or weekly streak. Preserve the legacy challenge history.
create table public.couple_plan_progress (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  plan_id text not null check (plan_id in ('movies','cooking','picnic','coffee','walk')),
  saved boolean not null default false,
  completed_at timestamptz,
  completed_by uuid references public.users(id) on delete set null,
  unique (household_id, plan_id)
);
create index couple_plan_progress_completed_by_idx
  on public.couple_plan_progress(completed_by) where completed_by is not null;

alter table public.couple_plan_progress enable row level security;
create policy couple_plan_valid_jwt on public.couple_plan_progress
  as restrictive for all to authenticated
  using ((select public.is_supabase_or_firebase_project_jwt()) is true);
create policy couple_plan_member_read on public.couple_plan_progress
  for select to authenticated
  using (public.is_current_household_member(household_id));

revoke all on public.couple_plan_progress from anon, authenticated;
grant select on public.couple_plan_progress to authenticated;
grant all on public.couple_plan_progress to service_role;

-- Keep the definer outside the exposed schema; every entry path checks both
-- Firebase identity and household membership. No global grant changes.
create function private.couple_plan_action_v1(
  p_household_id uuid, p_plan_id text, p_action text
) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_actor uuid := public.current_app_user_id();
  v_row public.couple_plan_progress;
begin
  if v_actor is null or public.is_supabase_or_firebase_project_jwt() is not true
     or not public.is_current_household_member(p_household_id) then
    raise exception using errcode='42501', message='Household membership required';
  end if;
  if not exists (select 1 from public.households where id=p_household_id and household_type='couple') then
    raise exception using errcode='42501', message='Couple household required';
  end if;
  if p_plan_id is null or p_plan_id not in ('movies','cooking','picnic','coffee','walk')
     or p_action is null or p_action not in ('save','unsave','complete','undo') then
    raise exception using errcode='22023', message='Unknown plan or action';
  end if;

  insert into public.couple_plan_progress as existing
    (household_id,plan_id,saved,completed_at,completed_by)
  values (p_household_id,p_plan_id,p_action='save',
    case when p_action='complete' then now() end,
    case when p_action='complete' then v_actor end)
  on conflict (household_id,plan_id) do update set
    saved=case when p_action='save' then true when p_action='unsave' then false else existing.saved end,
    completed_at=case when p_action='complete' then coalesce(existing.completed_at,now())
      when p_action='undo' then null else existing.completed_at end,
    completed_by=case when p_action='complete' then coalesce(existing.completed_by,v_actor)
      when p_action='undo' then null else existing.completed_by end
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

create function public.couple_plan_action_v1(
  p_household_id uuid, p_plan_id text, p_action text
) returns jsonb
language sql security invoker set search_path = '' as $$
  select private.couple_plan_action_v1(p_household_id,p_plan_id,p_action);
$$;

revoke all on function private.couple_plan_action_v1(uuid,text,text) from public,anon;
revoke all on function public.couple_plan_action_v1(uuid,text,text) from public,anon;
-- authenticated already has USAGE on private from the existing RPC boundary.
-- Avoid widening schema privileges as part of this feature.
grant execute on function private.couple_plan_action_v1(uuid,text,text) to authenticated;
grant execute on function public.couple_plan_action_v1(uuid,text,text) to authenticated;

-- Map only equivalent old activities; the original table remains intact.
insert into public.couple_plan_progress (household_id,plan_id,completed_at,completed_by)
select distinct on (c.household_id, mapped.plan_id)
  c.household_id,mapped.plan_id,c.completed_at,c.completed_by
from public.couple_challenge_completions c
join (values ('weekly_challenge_6','movies'),('weekly_challenge_8','picnic'),
  ('weekly_challenge_49','cooking')) as mapped(challenge_id,plan_id)
  on mapped.challenge_id=c.challenge_id
join public.households h on h.id=c.household_id and h.household_type='couple'
order by c.household_id,mapped.plan_id,c.completed_at
on conflict (household_id,plan_id) do nothing;

alter publication supabase_realtime add table public.couple_plan_progress;
notify pgrst, 'reload schema';
