-- Reconstructed from remote migration history (version 20260419175328).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Drop old check constraint and add new one with 'teen'
alter table public.household_members
  drop constraint if exists household_members_member_type_check;

alter table public.household_members
  add constraint household_members_member_type_check
  check (member_type in ('adult', 'teen', 'child'));

-- Update complete_member_onboarding to handle 'teen'
create or replace function public.complete_member_onboarding(
  p_member_type text default 'adult',
  p_display_role text default null
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  update public.household_members
  set
    onboarding_completed = true,
    member_type = p_member_type,
    display_role = coalesce(p_display_role,
      case p_member_type
        when 'teen' then 'Adolescente'
        when 'child' then 'Hijo/a'
        else 'Adulto'
      end)
  where user_id = v_uid
    and onboarding_completed = false;

  return found;
end;
$$;
;