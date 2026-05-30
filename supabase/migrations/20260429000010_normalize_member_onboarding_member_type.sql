-- Normalize legacy onboarding member_type values to the current enum.
-- Adult members are represented as parent/guardian in app permissions.

update public.household_members
set member_type = 'parent'
where member_type = 'adult';

alter table public.household_members
  alter column member_type set default 'parent';

alter table public.household_members
  drop constraint if exists household_members_member_type_check;

alter table public.household_members
  add constraint household_members_member_type_check
  check (member_type in ('parent', 'guardian', 'teen', 'child'));

create or replace function public.complete_member_onboarding(
  p_member_type text default 'parent',
  p_display_role text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
  v_member_type text;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'error', 'Not authenticated');
  end if;

  v_member_type := case coalesce(nullif(trim(p_member_type), ''), 'parent')
    when 'adult' then 'parent'
    else coalesce(nullif(trim(p_member_type), ''), 'parent')
  end;

  if v_member_type not in ('parent', 'guardian', 'teen', 'child') then
    return jsonb_build_object('ok', false, 'error', 'Tipo de miembro invalido.');
  end if;

  begin
    update public.household_members
    set
      onboarding_completed = true,
      member_type = v_member_type,
      display_role = coalesce(p_display_role,
        case v_member_type
          when 'guardian' then 'Tutor/a'
          when 'teen' then 'Adolescente'
          when 'child' then 'Hijo/a'
          else 'Adulto'
        end)
    where user_id = v_uid
      and onboarding_completed = false;

    if found then
      return jsonb_build_object('ok', true);
    else
      return jsonb_build_object('ok', false, 'error', 'No se encontro un miembro con onboarding pendiente.');
    end if;
  exception when unique_violation then
    return jsonb_build_object(
      'ok', false,
      'error', 'Ya existe un miembro con el rol "' || coalesce(p_display_role, 'Adulto') || '" en este hogar.'
    );
  end;
end;
$$;

comment on function public.complete_member_onboarding(text, text) is
  'Marks the current user onboarding as completed. Normalizes legacy adult member_type to parent.';
