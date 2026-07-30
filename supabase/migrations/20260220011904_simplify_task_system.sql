-- Reconstructed from remote migration history (version 20260220011904).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- ============================================
-- SIMPLIFICAR SISTEMA: Completar = ganar directo
-- Objetar = solo desde historial
-- ============================================

-- Add objection columns to tasks
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS completed_by UUID REFERENCES users(id);
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS objection_reason TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS objected_by UUID REFERENCES users(id);
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS objected_at TIMESTAMPTZ;

-- Update complete_task to give rewards immediately
CREATE OR REPLACE FUNCTION complete_task_transaction(
  p_request_id TEXT,
  p_user_id UUID,
  p_task_id UUID,
  p_household_id UUID,
  p_xp_reward INTEGER DEFAULT 0,
  p_coin_reward INTEGER DEFAULT 0,
  p_task_title TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task RECORD;
BEGIN
  SELECT * INTO v_task FROM tasks WHERE id = p_task_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Tarea no encontrada');
  END IF;
  
  IF v_task.status NOT IN ('active', 'assigned') THEN
    RETURN jsonb_build_object('success', false, 'message', 'No se puede completar');
  END IF;
  
  UPDATE tasks SET
    status = 'verified',
    completed_at = NOW(),
    completed_by = p_user_id,
    updated_at = NOW()
  WHERE id = p_task_id;
  
  INSERT INTO ledger_entries (user_id, household_id, amount, currency, type, description, reference_type, reference_id)
  VALUES 
    (p_user_id, p_household_id, p_xp_reward, 'xp', 'xp_earned', COALESCE(p_task_title, v_task.title), 'task', p_task_id),
    (p_user_id, p_household_id, p_coin_reward, 'coins', 'coins_earned', COALESCE(p_task_title, v_task.title), 'task', p_task_id);
  
  RETURN jsonb_build_object(
    'success', true, 
    'message', 'Tarea completada',
    'xp_earned', p_xp_reward,
    'coins_earned', p_coin_reward
  );
END;
$$;

-- Function to object a task (remove coins, keep XP)
CREATE OR REPLACE FUNCTION object_task(
  p_task_id UUID,
  p_user_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task RECORD;
BEGIN
  SELECT * INTO v_task FROM tasks WHERE id = p_task_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Tarea no encontrada');
  END IF;
  
  IF v_task.status != 'verified' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Solo tareas completadas');
  END IF;
  
  UPDATE tasks SET
    status = 'objected',
    objection_reason = p_reason,
    objected_by = p_user_id,
    objected_at = NOW(),
    updated_at = NOW()
  WHERE id = p_task_id;
  
  INSERT INTO ledger_entries (user_id, household_id, amount, currency, type, description, reference_type, reference_id)
  VALUES (v_task.completed_by, v_task.household_id, -v_task.coin_reward, 'coins', 'coins_removed', 'Tarea objetada', 'task', p_task_id);
  
  RETURN jsonb_build_object('success', true, 'message', 'Coins removidos');
END;
$$;

-- Function to restore coins
CREATE OR REPLACE FUNCTION restore_task_coins(
  p_task_id UUID,
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task RECORD;
BEGIN
  SELECT * INTO v_task FROM tasks WHERE id = p_task_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Tarea no encontrada');
  END IF;
  
  IF v_task.status != 'objected' THEN
    RETURN jsonb_build_object('success', false, 'message', 'No esta objetada');
  END IF;
  
  UPDATE tasks SET
    status = 'verified',
    objection_reason = NULL,
    objected_by = NULL,
    objected_at = NULL,
    updated_at = NOW()
  WHERE id = p_task_id;
  
  INSERT INTO ledger_entries (user_id, household_id, amount, currency, type, description, reference_type, reference_id)
  VALUES (v_task.completed_by, v_task.household_id, v_task.coin_reward, 'coins', 'coins_restored', 'Coins restaurados', 'task', p_task_id);
  
  RETURN jsonb_build_object('success', true, 'message', 'Coins restaurados');
END;
$$;

-- Get task history for objections
CREATE OR REPLACE FUNCTION get_task_history(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
  id UUID,
  title TEXT,
  status TEXT,
  category TEXT,
  xp_reward INTEGER,
  coin_reward INTEGER,
  completed_at TIMESTAMPTZ,
  completed_by_name TEXT,
  objection_reason TEXT,
  objected_by_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_household_id UUID;
BEGIN
  SELECT household_id INTO v_household_id
  FROM household_members WHERE user_id = p_user_id LIMIT 1;
  
  RETURN QUERY
  SELECT 
    t.id,
    t.title,
    t.status,
    t.category,
    t.xp_reward,
    t.coin_reward,
    t.completed_at,
    u.full_name as completed_by_name,
    t.objection_reason,
    u2.full_name as objected_by_name
  FROM tasks t
  LEFT JOIN users u ON t.completed_by = u.id
  LEFT JOIN users u2 ON t.objected_by = u2.id
  WHERE t.household_id = v_household_id
    AND t.status IN ('verified', 'objected')
  ORDER BY t.completed_at DESC
  LIMIT p_limit;
END;
$$;
