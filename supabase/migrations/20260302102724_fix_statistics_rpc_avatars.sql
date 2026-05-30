-- Reconstructed from remote migration history (version 20260302102724).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Update member activity stats to include user_id and avatar_url
CREATE OR REPLACE FUNCTION public.get_member_activity_stats(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_household_id UUID;
  v_result JSONB;
BEGIN
  -- Get household_id for the user
  SELECT household_id INTO v_household_id
  FROM public.household_members
  WHERE user_id = p_user_id
  LIMIT 1;

  IF v_household_id IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  SELECT jsonb_agg(t) INTO v_result
  FROM (
    SELECT 
      u.id as user_id,
      u.email as user_email,
      u.full_name as user_name,
      u.avatar_url,
      COUNT(le_xp.id) as tasks_completed,
      COALESCE(SUM(le_xp.amount), 0) as xp_earned,
      COALESCE(SUM(CASE WHEN le_coins.currency = 'COIN' THEN le_coins.amount ELSE 0 END), 0) as coins_earned
    FROM public.household_members hm
    JOIN public.users u ON hm.user_id = u.id
    LEFT JOIN public.ledger_entries le_xp ON le_xp.user_id = u.id 
      AND le_xp.household_id = v_household_id 
      AND le_xp.currency = 'XP'
    LEFT JOIN public.ledger_entries le_coins ON le_coins.user_id = u.id 
      AND le_coins.household_id = v_household_id 
      AND le_coins.currency = 'COIN'
    WHERE hm.household_id = v_household_id
    GROUP BY u.id, u.email, u.full_name, u.avatar_url
    ORDER BY xp_earned DESC
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- Update weekly ranking to include user_id and avatar_url
CREATE OR REPLACE FUNCTION public.get_weekly_ranking(p_household_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
      COALESCE(SUM(le.amount), 0) as xp_earned
    FROM public.household_members hm
    JOIN public.users u ON hm.user_id = u.id
    LEFT JOIN public.ledger_entries le ON le.user_id = u.id 
      AND le.household_id = p_household_id 
      AND le.currency = 'XP'
      AND le.created_at >= v_week_start
    WHERE hm.household_id = p_household_id
    GROUP BY u.id, u.full_name, u.email, u.avatar_url
    ORDER BY xp_earned DESC
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;
;