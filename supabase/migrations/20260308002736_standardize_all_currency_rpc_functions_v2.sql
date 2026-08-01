-- Reconstructed from remote migration history (version 20260308002736).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.get_coin_history(p_user_id uuid)
 RETURNS TABLE(id uuid, type text, amount integer, description text, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    le.id,
    le.type,
    le.amount,
    le.description,
    le.created_at
  FROM ledger_entries le
  WHERE le.user_id = p_user_id
    AND le.currency = 'COIN'
  ORDER BY le.created_at DESC
  LIMIT 50;
END;
$function$;

CREATE OR REPLACE FUNCTION public.award_weekly_winner(p_household_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
      AND le.currency = 'XP'
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
    'COIN',
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
    'message', 'Ganador premiado',
    'winner_id', v_winner_id,
    'xp_earned', v_winner_xp,
    'coins_awarded', 20
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.object_task(p_task_id uuid, p_user_id uuid, p_reason text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_task RECORD;
BEGIN
  SELECT * INTO v_task FROM tasks WHERE id = p_task_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Tarea no encontrada');
  END IF;
  
  IF v_task.status != 'verified' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Solo tareas verificadas');
  END IF;
  
  UPDATE tasks SET
    status = 'objected',
    objection_reason = p_reason,
    objected_by = p_user_id,
    objected_at = NOW(),
    updated_at = NOW()
  WHERE id = p_task_id;
  
  INSERT INTO ledger_entries (user_id, household_id, amount, currency, type, description, reference_type, reference_id)
  VALUES (v_task.completed_by, v_task.household_id, -v_task.coin_reward, 'COIN', 'coins_removed', 'Tarea objetada', 'task', p_task_id);
  
  RETURN jsonb_build_object('success', true, 'message', 'Coins removidos');
END;
$function$;

CREATE OR REPLACE FUNCTION public.restore_task_coins(p_task_id uuid, p_user_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_task RECORD;
BEGIN
  SELECT * INTO v_task FROM tasks WHERE id = p_task_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Tarea no encontrada');
  END IF;
  
  IF v_task.status != 'objected' THEN
    RETURN jsonb_build_object('success', false, 'message', 'La tarea no estâ”œÃ­ objetada');
  END IF;
  
  UPDATE tasks SET
    status = 'verified',
    objection_reason = NULL,
    objected_by = NULL,
    objected_at = NULL,
    updated_at = NOW()
  WHERE id = p_task_id;
  
  INSERT INTO ledger_entries (user_id, household_id, amount, currency, type, description, reference_type, reference_id)
  VALUES (v_task.completed_by, v_task.household_id, v_task.coin_reward, 'COIN', 'coins_restored', 'Coins restaurados', 'task', p_task_id);
  
  RETURN jsonb_build_object('success', true, 'message', 'Coins restaurados');
END;
$function$;
