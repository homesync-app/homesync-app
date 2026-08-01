-- Reconstructed from remote migration history (version 20260417190234).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.ensure_household_for_user(
  p_household_type text DEFAULT 'couple'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
declare
  v_user_id uuid;
  v_household_id uuid;
begin
  v_user_id := public.current_app_user_id();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- If user already belongs to a household, return it
  select household_id into v_household_id
  from public.household_members
  where user_id = v_user_id
  limit 1;

  if v_household_id is not null then
    -- Also update the type in case it was created with wrong default
    update public.households
    set household_type = p_household_type
    where id = v_household_id and household_type != p_household_type;
    return v_household_id;
  end if;

  insert into public.households (name, household_type)
  values ('Mi Hogar', p_household_type)
  returning id into v_household_id;

  insert into public.household_members (household_id, user_id, role)
  values (v_household_id, v_user_id, 'owner');

  return v_household_id;
end;
$$;
