-- Reconstructed from remote migration history (version 20260420122459).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

drop function if exists public.complete_member_onboarding(text, text);

create or replace function public.complete_member_onboarding(
  p_member_type text default 'adult',
  p_display_role text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
  v_household_id uuid;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'error', 'Not authenticated');
  end if;

  select hm.household_id into v_household_id
  from public.household_members hm
  where hm.user_id = v_uid
  limit 1;

  begin
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

create or replace function public.get_available_family_roles(p_household_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
  v_taken jsonb;
  v_all_roles text[] := array['Padre', 'Madre', 'Tutor/a', 'Adolescente', 'Hijo/a'];
  v_result jsonb := '[]'::jsonb;
  v_role text;
begin
  if v_uid is null then
    return '[]'::jsonb;
  end if;

  if not exists (
    select 1 from public.household_members
    where household_id = p_household_id and user_id = v_uid
  ) then
    return '[]'::jsonb;
  end if;

  select jsonb_agg(hm.display_role) into v_taken
  from public.household_members hm
  where hm.household_id = p_household_id
    and hm.display_role in ('Padre', 'Madre');

  foreach v_role in array v_all_roles loop
    if v_role in ('Tutor/a', 'Adolescente', 'Hijo/a') then
      v_result := v_result || to_jsonb(v_role);
    elsif v_role not in (select value from jsonb_array_elements_text(coalesce(v_taken, '[]'::jsonb)) as value) then
      v_result := v_result || to_jsonb(v_role);
    end if;
  end loop;

  return v_result;
end;
$$;
