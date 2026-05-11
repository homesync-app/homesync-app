-- Security hardening: close client-side premium/admin/member escalation paths.
--
-- The Data API can update rows directly when RLS allows it. These triggers keep
-- user-editable fields narrow even if a client sends extra columns in PATCH.

create or replace function public.reject_user_sensitive_updates()
returns trigger
language plpgsql
volatile
set search_path = public
as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then
    return NEW;
  end if;

  if public.current_app_user_id() is distinct from OLD.id
     or NEW.id is distinct from OLD.id then
    raise exception 'Not allowed to update this profile' using errcode = '42501';
  end if;

  if (to_jsonb(NEW) - 'full_name' - 'avatar_url' - 'mercadopago_alias' - 'updated_at')
     is distinct from
     (to_jsonb(OLD) - 'full_name' - 'avatar_url' - 'mercadopago_alias' - 'updated_at') then
    raise exception 'Only profile fields can be updated directly'
      using errcode = '42501';
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_reject_user_sensitive_updates on public.users;

create trigger trg_reject_user_sensitive_updates
  before update on public.users
  for each row
  execute function public.reject_user_sensitive_updates();

comment on function public.reject_user_sensitive_updates() is
  'Blocks direct client updates to sensitive users columns such as is_admin, is_premium, premium_until, email and firebase_uid.';

drop policy if exists "Users can update own profile" on public.users;

create policy "Users can update own profile"
on public.users
for update
to authenticated
using (public.current_app_user_id() = id)
with check (public.current_app_user_id() = id);

create or replace function public.reject_member_sensitive_updates()
returns trigger
language plpgsql
volatile
set search_path = public
as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then
    return NEW;
  end if;

  if public.current_app_user_id() is distinct from OLD.user_id
     or NEW.user_id is distinct from OLD.user_id
     or NEW.household_id is distinct from OLD.household_id then
    raise exception 'Not allowed to update this membership' using errcode = '42501';
  end if;

  if (to_jsonb(NEW) - 'member_type' - 'display_role' - 'onboarding_completed' - 'updated_at')
     is distinct from
     (to_jsonb(OLD) - 'member_type' - 'display_role' - 'onboarding_completed' - 'updated_at') then
    raise exception 'Only onboarding profile fields can be updated directly'
      using errcode = '42501';
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_reject_member_sensitive_updates on public.household_members;

create trigger trg_reject_member_sensitive_updates
  before update on public.household_members
  for each row
  execute function public.reject_member_sensitive_updates();

comment on function public.reject_member_sensitive_updates() is
  'Blocks direct client updates to sensitive membership columns such as role, household_id, user_id and requires_task_approval.';

drop policy if exists "Users can update own membership" on public.household_members;

create policy "Users can update own membership"
on public.household_members
for update
to authenticated
using (user_id = public.current_app_user_id())
with check (
  user_id = public.current_app_user_id()
);

create or replace function public.validate_household_update()
returns trigger
language plpgsql
volatile
set search_path = public
as $$
declare
  v_user_id uuid;
  v_is_owner boolean;
  v_old_public jsonb;
  v_new_public jsonb;
  v_old_owner jsonb;
  v_new_owner jsonb;
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then
    return NEW;
  end if;

  v_user_id := public.current_app_user_id();
  if v_user_id is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if NEW.id is distinct from OLD.id then
    raise exception 'Household id cannot be changed' using errcode = '42501';
  end if;

  select exists (
    select 1
    from public.household_members
    where household_id = NEW.id
      and user_id = v_user_id
      and role = 'owner'
  ) into v_is_owner;

  v_old_public := to_jsonb(OLD) - 'tasks_enabled' - 'updated_at';
  v_new_public := to_jsonb(NEW) - 'tasks_enabled' - 'updated_at';

  if not v_is_owner then
    if v_new_public is distinct from v_old_public then
      raise exception 'Only owners can update household settings'
        using errcode = '42501';
    end if;
    return NEW;
  end if;

  v_old_owner := v_old_public
    - 'name'
    - 'household_type'
    - 'default_split_ratio'
    - 'finance_mode'
    - 'task_approval_mode'
    - 'timezone';
  v_new_owner := v_new_public
    - 'name'
    - 'household_type'
    - 'default_split_ratio'
    - 'finance_mode'
    - 'task_approval_mode'
    - 'timezone';

  if v_new_owner is distinct from v_old_owner then
    raise exception 'Premium and subscription fields must be updated by trusted server code'
      using errcode = '42501';
  end if;

  return NEW;
end;
$$;

comment on function public.validate_household_update() is
  'Allows direct household edits only for safe settings; premium/subscription fields require trusted server code.';

drop policy if exists "Members can update households" on public.households;
drop policy if exists "Owners can update households" on public.households;

create policy "Members can update households"
on public.households
for update
to authenticated
using (public.is_current_household_member(id))
with check (public.is_current_household_member(id));

revoke execute on function public.set_premium_status(boolean, timestamptz) from public;
revoke execute on function public.toggle_premium_mock() from public;
revoke execute on function public.set_premium_status(boolean, timestamptz) from anon;
revoke execute on function public.toggle_premium_mock() from anon;

-- Premium is still a product-wide mock/free toggle. Keep it available to
-- authenticated users until billing/server-side purchase verification exists.
grant execute on function public.set_premium_status(boolean, timestamptz)
  to authenticated, service_role;
grant execute on function public.toggle_premium_mock()
  to authenticated, service_role;
