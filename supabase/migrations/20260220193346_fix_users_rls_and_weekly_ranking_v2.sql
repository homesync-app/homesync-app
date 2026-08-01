-- Reconstructed from remote migration history (version 20260220193346).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ Fix 1: Allow users to view profiles of household members Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
DROP POLICY IF EXISTS "Users can view own profile" ON users;

CREATE POLICY "Users can view household member profiles" ON users
  FOR SELECT
  USING (
    auth.uid() = id
    OR
    id IN (
      SELECT hm2.user_id
      FROM household_members hm1
      JOIN household_members hm2 ON hm1.household_id = hm2.household_id
      WHERE hm1.user_id = auth.uid()
    )
  );

-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ Fix 2: Fix get_weekly_ranking Ã”Ã‡Ã¶ drop and recreate with correct types Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
DROP FUNCTION IF EXISTS public.get_weekly_ranking(uuid);

CREATE FUNCTION public.get_weekly_ranking(p_household_id uuid)
RETURNS TABLE(user_id uuid, user_name text, xp_earned bigint, rank bigint)
LANGUAGE plpgsql
AS $$
DECLARE
  v_week_start DATE;
BEGIN
  v_week_start := DATE_TRUNC('week', CURRENT_DATE);
  
  RETURN QUERY
  WITH weekly_xp AS (
    SELECT 
      le.user_id,
      SUM(le.amount) as total_xp
    FROM ledger_entries le
    WHERE le.household_id = p_household_id
      AND le.type = 'xp_earned'
      AND le.created_at >= v_week_start
      AND le.created_at < v_week_start + INTERVAL '7 days'
    GROUP BY le.user_id
  )
  SELECT 
    hm.user_id,
    COALESCE(u.full_name, u.email) as user_name,
    COALESCE(wx.total_xp, 0) as xp_earned,
    RANK() OVER (ORDER BY COALESCE(wx.total_xp, 0) DESC) as rank
  FROM household_members hm
  JOIN users u ON u.id = hm.user_id
  LEFT JOIN weekly_xp wx ON wx.user_id = hm.user_id
  WHERE hm.household_id = p_household_id
  ORDER BY xp_earned DESC;
END;
$$;
;