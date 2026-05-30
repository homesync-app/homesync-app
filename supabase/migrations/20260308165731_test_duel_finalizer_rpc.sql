-- Reconstructed from remote migration history (version 20260308165731).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.test_finalize_weekly_duel(p_household_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_winner_id UUID;
  v_winner_name TEXT;
  v_winner_xp INTEGER;
  v_loser_id UUID;
  v_loser_name TEXT;
  v_loser_xp INTEGER;
  v_coins_reward INTEGER := 20;
BEGIN
  -- Get the winner and loser of the current week
  WITH ranking AS (
    SELECT 
      u.id as user_id,
      u.full_name,
      COALESCE(SUM(le.amount), 0) as xp
    FROM public.household_members hm
    JOIN public.users u ON hm.user_id = u.id
    LEFT JOIN public.ledger_entries le ON le.user_id = u.id 
      AND le.household_id = p_household_id 
      AND le.currency = 'XP'
      AND le.created_at >= date_trunc('week', NOW())
    WHERE hm.household_id = p_household_id
    GROUP BY u.id, u.full_name
    ORDER BY xp DESC
  )
  SELECT 
    (SELECT user_id FROM ranking ORDER BY xp DESC LIMIT 1),
    (SELECT full_name FROM ranking ORDER BY xp DESC LIMIT 1),
    (SELECT xp FROM ranking ORDER BY xp DESC LIMIT 1),
    (SELECT user_id FROM ranking ORDER BY xp ASC LIMIT 1),
    (SELECT full_name FROM ranking ORDER BY xp ASC LIMIT 1),
    (SELECT xp FROM ranking ORDER BY xp ASC LIMIT 1)
  INTO v_winner_id, v_winner_name, v_winner_xp, v_loser_id, v_loser_name, v_loser_xp;

  -- 1. Insert into history
  INSERT INTO public.weekly_duel_history (
    household_id, week_start_date, winner_user_id, winner_name, winner_xp, 
    loser_user_id, loser_name, loser_xp
  ) VALUES (
    p_household_id, date_trunc('week', NOW()), v_winner_id, v_winner_name, v_winner_xp,
    v_loser_id, v_loser_name, v_loser_xp
  );

  -- 2. Award coins to winner
  INSERT INTO public.ledger_entries (
    household_id, user_id, type, amount, currency, description
  ) VALUES (
    p_household_id, v_winner_id, 'coins_earned', v_coins_reward, 'COIN', 'Premio Duelo Semanal (Test)'
  );

  RETURN jsonb_build_object(
    'success', true,
    'winner_name', v_winner_name,
    'winner_xp', v_winner_xp,
    'award', v_coins_reward
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.test_finalize_weekly_duel(UUID) TO authenticated;
