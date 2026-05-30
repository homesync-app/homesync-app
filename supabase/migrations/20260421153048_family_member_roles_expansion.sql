-- Reconstructed from remote migration history (version 20260421153048).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Expand household_members.member_type to support four family roles:
--   parent, guardian (both are "adults" with approval power)
--   teen, child (both must submit work for adult approval)
--
-- Legacy 'adult' rows are migrated to 'parent'.

do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'household_members_member_type_check'
  ) then
    alter table public.household_members
      drop constraint household_members_member_type_check;
  end if;
end $$;

update public.household_members
set member_type = 'parent'
where member_type = 'adult';

alter table public.household_members
  alter column member_type set default 'parent';

alter table public.household_members
  add constraint household_members_member_type_check
  check (member_type in ('parent', 'guardian', 'teen', 'child'));
