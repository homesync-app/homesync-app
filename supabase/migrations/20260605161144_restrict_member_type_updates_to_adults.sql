-- Functional family roles are permissions, not self-service profile labels.
-- Adult household admins may change child/teen roles; minors may not
-- self-promote by editing household_members directly.

create schema if not exists private;

create or replace function private.is_adult_household_admin(
  p_household_id uuid,
  p_target_user_id uuid default null
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.household_members actor
    where actor.household_id = p_household_id
      and actor.user_id = public.current_app_user_id()
      and actor.role in ('owner', 'admin')
      and coalesce(actor.member_type, 'parent') in ('parent', 'guardian')
      and (
        p_target_user_id is null
        or actor.user_id <> p_target_user_id
      )
  );
$$;

revoke all on function private.is_adult_household_admin(uuid, uuid)
  from public, anon;
grant usage on schema private to authenticated, service_role;
grant execute on function private.is_adult_household_admin(uuid, uuid)
  to authenticated, service_role;

create or replace function public.reject_member_sensitive_updates()
returns trigger
language plpgsql
volatile
set search_path = public
as $$
declare
  v_household_type text;
  v_only_profile_fields boolean;
  v_only_role_fields boolean;
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then
    return NEW;
  end if;

  if NEW.user_id is distinct from OLD.user_id
     or NEW.household_id is distinct from OLD.household_id then
    raise exception 'Not allowed to update this membership' using errcode = '42501';
  end if;

  v_only_profile_fields :=
    (to_jsonb(NEW) - 'member_type' - 'display_role' - 'onboarding_completed' - 'updated_at')
    is not distinct from
    (to_jsonb(OLD) - 'member_type' - 'display_role' - 'onboarding_completed' - 'updated_at');

  v_only_role_fields :=
    (to_jsonb(NEW) - 'member_type' - 'display_role' - 'updated_at')
    is not distinct from
    (to_jsonb(OLD) - 'member_type' - 'display_role' - 'updated_at');

  if not v_only_profile_fields and not v_only_role_fields then
    raise exception 'Only onboarding profile fields can be updated directly'
      using errcode = '42501';
  end if;

  select type
    into v_household_type
  from public.households
  where id = OLD.household_id;

  if public.current_app_user_id() is distinct from OLD.user_id then
    if not private.is_adult_household_admin(OLD.household_id, OLD.user_id)
       or not v_only_role_fields then
      raise exception 'Only adult household admins can update member roles'
        using errcode = '42501';
    end if;

    return NEW;
  end if;

  if NEW.member_type is distinct from OLD.member_type then
    raise exception 'Member type can only be changed by an adult household admin'
      using errcode = '42501';
  end if;

  if coalesce(v_household_type, '') = 'family'
     and coalesce(OLD.member_type, 'parent') in ('child', 'teen')
     and NEW.display_role is distinct from OLD.display_role then
    raise exception 'Family minor roles can only be changed by an adult household admin'
      using errcode = '42501';
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_reject_member_sensitive_updates
  on public.household_members;

create trigger trg_reject_member_sensitive_updates
  before update on public.household_members
  for each row
  execute function public.reject_member_sensitive_updates();

drop policy if exists "Adult admins can update household member roles"
  on public.household_members;

create policy "Adult admins can update household member roles"
on public.household_members
for update
to authenticated
using (
  private.is_adult_household_admin(
    household_members.household_id,
    household_members.user_id
  )
)
with check (
  private.is_adult_household_admin(
    household_members.household_id,
    household_members.user_id
  )
);

comment on function public.reject_member_sensitive_updates() is
  'Blocks direct client updates to sensitive membership columns; family member_type/display_role changes are restricted to adult household admins.';

comment on function private.is_adult_household_admin(uuid, uuid) is
  'RLS helper: true when the current app user is an adult owner/admin of the household and is not the target member.';
