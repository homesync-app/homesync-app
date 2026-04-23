-- Add 'teen' as valid member_type and update RPC

alter table public.household_members
  drop constraint if exists household_members_member_type_check;

alter table public.household_members
  add constraint household_members_member_type_check
  check (member_type in ('adult', 'teen', 'child'));

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
