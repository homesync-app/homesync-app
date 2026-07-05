-- Weekly ranking: exponer display_role para etiquetas de rol con genero.
--
-- El cliente (FamilyRankingSection) ahora muestra Padre/Madre, Tutor/Tutora,
-- Hijo/Hija segun el genero real elegido en el onboarding (display_role), y
-- Papa/Mama en la vista de un nino/teen. Hasta ahora estas RPC solo devolvian
-- member_type, asi que el ranking caia al generico "Padre/Madre". Agregamos
-- hm.display_role al SELECT (y al GROUP BY).

CREATE OR REPLACE FUNCTION public.get_weekly_ranking(p_household_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_result JSONB;
  v_week_start TIMESTAMPTZ := date_trunc('week', NOW());
BEGIN
  SELECT jsonb_agg(t) INTO v_result
  FROM (
    SELECT
      u.id as user_id,
      u.full_name as user_name,
      u.email as user_email,
      u.avatar_url,
      hm.member_type,
      hm.display_role,
      hm.role,
      COALESCE(SUM(le.amount), 0) as xp_earned,
      COUNT(le.id) FILTER (WHERE le.currency = 'XP') as tasks_completed
    FROM public.household_members hm
    JOIN public.users u ON hm.user_id = u.id
    LEFT JOIN public.ledger_entries le ON le.user_id = u.id
      AND le.household_id = p_household_id
      AND le.currency = 'XP'
      AND le.created_at >= v_week_start
    WHERE hm.household_id = p_household_id
    GROUP BY u.id, u.full_name, u.email, u.avatar_url, hm.member_type, hm.display_role, hm.role
    ORDER BY xp_earned DESC
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_weekly_ranking_for_week(p_household_id uuid, p_week_start_date date)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_result jsonb;
  v_uid uuid;
begin
  v_uid := public.current_app_user_id();

  if v_uid is null or not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_uid
  ) then
    return '[]'::jsonb;
  end if;

  select jsonb_agg(t) into v_result
  from (
    select
      u.id as user_id,
      u.full_name as user_name,
      u.email as user_email,
      u.avatar_url,
      hm.member_type,
      hm.display_role,
      hm.role,
      coalesce(sum(le.amount), 0)::integer as xp_earned,
      (count(le.id) filter (where le.currency = 'XP'))::integer as tasks_completed
    from public.household_members hm
    join public.users u on hm.user_id = u.id
    left join public.ledger_entries le on le.user_id = u.id
      and le.household_id = p_household_id
      and le.currency = 'XP'
      and le.type = 'xp_earned'
      and le.created_at >= p_week_start_date::timestamptz
      and le.created_at < (p_week_start_date::timestamptz + interval '7 days')
    where hm.household_id = p_household_id
    group by u.id, u.full_name, u.email, u.avatar_url, hm.member_type, hm.display_role, hm.role
    order by xp_earned desc, tasks_completed desc, user_name asc
  ) t;

  return coalesce(v_result, '[]'::jsonb);
end;
$function$;
