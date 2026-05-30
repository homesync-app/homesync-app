-- Reconstructed from remote migration history (version 20260302144147).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Recreate award_weekly_winner with SECURITY DEFINER to bypass RLS
CREATE OR REPLACE FUNCTION public.award_weekly_winner(p_household_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_week_start DATE;
  v_week_end DATE;
  v_winner_id UUID;
  v_winner_xp INTEGER;
  v_existing_count INTEGER;
BEGIN
  v_week_start := DATE_TRUNC('week', CURRENT_DATE);
  v_week_end := v_week_start + INTERVAL '6 days';
  
  -- Verificar si ya se procesâ”œâ”‚ esta semana
  SELECT COUNT(*) INTO v_existing_count
  FROM weekly_winners
  WHERE household_id = p_household_id
    AND week_start = v_week_start;
    
  IF v_existing_count > 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Esta semana ya fue procesada'
    );
  END IF;
  
  -- Obtener el ganador (mâ”œÃ­s XP de la semana)
  SELECT wx.user_id, wx.total_xp::INTEGER INTO v_winner_id, v_winner_xp
  FROM (
    SELECT 
      le.user_id,
      SUM(le.amount) as total_xp
    FROM ledger_entries le
    WHERE le.household_id = p_household_id
      AND le.type = 'xp_earned'
      AND le.created_at >= v_week_start
      AND le.created_at < v_week_start + INTERVAL '7 days'
    GROUP BY le.user_id
    ORDER BY total_xp DESC
    LIMIT 1
  ) wx;
  
  -- Si no hay ganador (nadie hizo tareas), retornar
  IF v_winner_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'No hay actividades esta semana'
    );
  END IF;
  
  -- Otorgar 20 coins al ganador
  INSERT INTO ledger_entries (
    user_id,
    household_id,
    amount,
    currency,
    type,
    description,
    reference_type,
    reference_id
  ) VALUES (
    v_winner_id,
    p_household_id,
    20,
    'coins',
    'weekly_winner_bonus',
    'â”¬Ã­Premio por ganar la semana!',
    'weekly_winner',
    gen_random_uuid()::TEXT
  );
  
  -- Registrar el ganador
  INSERT INTO weekly_winners (
    household_id,
    user_id,
    week_start,
    week_end,
    xp_earned,
    coins_awarded
  ) VALUES (
    p_household_id,
    v_winner_id,
    v_week_start,
    v_week_end,
    v_winner_xp,
    20
  );
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Ganador premiados',
    'winner_id', v_winner_id,
    'xp_earned', v_winner_xp,
    'coins_awarded', 20
  );
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION public.award_weekly_winner TO authenticated;
