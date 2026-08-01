-- Reconstructed from remote migration history (version 20260417183403).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


create or replace function public.ensure_household_for_user()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_household_id uuid;
begin
  v_user_id := public.current_app_user_id();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select household_id into v_household_id
  from public.household_members
  where user_id = v_user_id
  limit 1;

  if v_household_id is not null then
    return v_household_id;
  end if;

  insert into public.households (name, household_type)
  values ('Mi Hogar', 'couple')
  returning id into v_household_id;

  insert into public.household_members (household_id, user_id, role)
  values (v_household_id, v_user_id, 'owner');

  return v_household_id;
end;
$$;

comment on function public.ensure_household_for_user() is
  'Creates a household and owner membership for the current user if none exists. SECURITY DEFINER bypasses RLS.';
;