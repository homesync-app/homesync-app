-- Fix the family role update guard introduced in the previous migration.
-- The households table column is household_type, not type.

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

  select household_type
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

comment on function public.reject_member_sensitive_updates() is
  'Blocks direct client updates to sensitive membership columns; family member_type/display_role changes are restricted to adult household admins.';
