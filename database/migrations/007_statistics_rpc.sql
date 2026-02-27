-- ============================================
-- MISSING STATISTICS RPC FUNCTIONS
-- ============================================

-- Function to get task stats by category
CREATE OR REPLACE FUNCTION public.get_task_stats_by_category(p_user_id UUID)
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
      category,
      COUNT(*) as completed_count,
      SUM(xp_reward) as total_xp
    FROM public.tasks
    WHERE household_id = v_household_id
    AND status = 'verified'
    GROUP BY category
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- Function to get member activity stats (historical ranking)
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
      u.email as user_email,
      u.full_name as user_name,
      COUNT(le_xp.id) as tasks_completed,
      COALESCE(SUM(le_xp.amount), 0) as xp_earned
    FROM public.household_members hm
    JOIN public.users u ON hm.user_id = u.id
    LEFT JOIN public.ledger_entries le_xp ON le_xp.user_id = u.id 
      AND le_xp.household_id = v_household_id 
      AND le_xp.currency = 'XP'
    WHERE hm.household_id = v_household_id
    GROUP BY u.id, u.email, u.full_name
    ORDER BY xp_earned DESC
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- Function to get weekly ranking
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
      u.full_name as user_name,
      u.email as user_email,
      COALESCE(SUM(le.amount), 0) as xp_earned
    FROM public.household_members hm
    JOIN public.users u ON hm.user_id = u.id
    LEFT JOIN public.ledger_entries le ON le.user_id = u.id 
      AND le.household_id = p_household_id 
      AND le.currency = 'XP'
      AND le.created_at >= v_week_start
    WHERE hm.household_id = p_household_id
    GROUP BY u.id, u.full_name, u.email
    ORDER BY xp_earned DESC
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- Grants
GRANT EXECUTE ON FUNCTION public.get_task_stats_by_category(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_member_activity_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_weekly_ranking(UUID) TO authenticated;
