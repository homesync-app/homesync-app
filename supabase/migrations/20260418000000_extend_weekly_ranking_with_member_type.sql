CREATE OR REPLACE FUNCTION public.get_weekly_ranking(p_household_id uuid)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_result JSONB;
  -- TODO: timezone. Currently uses UTC via date_trunc('week', NOW()).
  -- For Argentina (UTC-3) the week boundary shifts 3h on Sunday nights.
  -- Consider adding p_timezone parameter or using AT TIME ZONE when needed.
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
      COALESCE(SUM(le.amount), 0) as xp_earned,
      COUNT(le.id) FILTER (WHERE le.currency = 'XP') as tasks_completed
    FROM public.household_members hm
    JOIN public.users u ON hm.user_id = u.id
    LEFT JOIN public.ledger_entries le ON le.user_id = u.id 
      AND le.household_id = p_household_id 
      AND le.currency = 'XP'
      AND le.created_at >= v_week_start
    WHERE hm.household_id = p_household_id
    GROUP BY u.id, u.full_name, u.email, u.avatar_url, hm.member_type
    ORDER BY xp_earned DESC
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$function$;
