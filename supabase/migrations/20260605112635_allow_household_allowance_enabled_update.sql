-- Allow owners to toggle Parent Mode allowance transfers.
--
-- `allowance_enabled` was added after the household update hardening trigger.
-- Without adding it to the safe owner-editable list, direct household updates
-- are rejected as if they attempted to mutate premium/subscription fields.

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
    - 'timezone'
    - 'allowance_enabled';
  v_new_owner := v_new_public
    - 'name'
    - 'household_type'
    - 'default_split_ratio'
    - 'finance_mode'
    - 'task_approval_mode'
    - 'timezone'
    - 'allowance_enabled';

  if v_new_owner is distinct from v_old_owner then
    raise exception 'Premium and subscription fields must be updated by trusted server code'
      using errcode = '42501';
  end if;

  return NEW;
end;
$$;

comment on function public.validate_household_update() is
  'Allows direct household edits only for safe settings; premium/subscription fields require trusted server code.';
