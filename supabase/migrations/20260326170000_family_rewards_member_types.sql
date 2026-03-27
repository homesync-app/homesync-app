alter table public.rewards
  add column if not exists target_type text not null default 'all';

alter table public.household_members
  add column if not exists member_type text not null default 'adult';

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'rewards_target_type_check'
  ) then
    alter table public.rewards
      add constraint rewards_target_type_check
      check (target_type in ('adult', 'child', 'all'));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'household_members_member_type_check'
  ) then
    alter table public.household_members
      add constraint household_members_member_type_check
      check (member_type in ('adult', 'child'));
  end if;
end $$;

update public.household_members
set member_type = 'child'
where lower(coalesce(display_role, '')) similar to '%(hijo|hija|niñ|nin)%';

update public.household_members
set member_type = 'adult'
where member_type is null;
