-- B1: roles familiares con genero en el onboarding.
--
-- Antes la lista ofrecia 'Tutor/a' y 'Hijo/a' (genericos), forzando un
-- display_role sin genero. Ahora ofrece las variantes con genero (Tutor/Tutora,
-- Hijo/Hija) para que coincidan con el picker unificado (FamilyRoleOption) y con
-- las etiquetas con genero del ranking/header. Padre/Madre se siguen deduplicando
-- (un unico Padre y una unica Madre por hogar); el resto puede repetirse.

CREATE OR REPLACE FUNCTION public.get_available_family_roles(p_household_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := public.current_app_user_id();
  v_taken jsonb;
  v_all_roles text[] := array['Padre', 'Madre', 'Tutor', 'Tutora', 'Adolescente', 'Hijo', 'Hija'];
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
    if v_role in ('Tutor', 'Tutora', 'Adolescente', 'Hijo', 'Hija') then
      v_result := v_result || to_jsonb(v_role);
    elsif v_role not in (select value from jsonb_array_elements_text(coalesce(v_taken, '[]'::jsonb)) as value) then
      v_result := v_result || to_jsonb(v_role);
    end if;
  end loop;

  return v_result;
end;
$function$;
