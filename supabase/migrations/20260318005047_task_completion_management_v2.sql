-- Reconstructed from remote migration history (version 20260318005047).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Create undo_task_completion RPC
CREATE OR REPLACE FUNCTION undo_task_completion(
  p_activity_id UUID,
  p_user_id UUID -- The user requesting the undo (must be the one who completed it)
) RETURNS JSONB AS $$
DECLARE
  v_task_id UUID;
  v_household_id UUID;
  v_xp_reward INTEGER;
  v_coin_reward INTEGER;
BEGIN
  -- Find the activity and verify it's a task completion by this user
  SELECT 
    household_id, 
    (metadata->>'task_id')::UUID,
    (metadata->>'xp_per_user')::INTEGER,
    (metadata->>'coins_per_user')::INTEGER
  INTO v_household_id, v_task_id, v_xp_reward, v_coin_reward
  FROM public.household_activities
  WHERE id = p_activity_id AND user_id = p_user_id AND event_type = 'task_completed';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Activity not found or unauthorized');
  END IF;

  -- Update task status back to active
  UPDATE public.tasks
  SET 
    status = 'active',
    completed_at = NULL,
    completed_by = NULL,
    objection_reason = NULL,
    objected_by = NULL,
    objected_at = NULL,
    updated_at = NOW()
  WHERE id = v_task_id;

  -- Delete ledger entries associated with this activity (XP and Coins)
  DELETE FROM public.ledger_entries
  WHERE reference_id = p_activity_id::TEXT AND reference_type = 'activity';

  -- Delete the activity itself
  DELETE FROM public.household_activities
  WHERE id = p_activity_id;

  RETURN jsonb_build_object('success', true, 'message', 'Task completion undone successfully');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 2. Enhance object_task RPC
-- This version allows objecting pending tasks too and handles rewards correctly
CREATE OR REPLACE FUNCTION object_task_v2(
  p_task_id UUID,
  p_user_id UUID, -- The person objecting (partner)
  p_reason TEXT,
  p_activity_id UUID DEFAULT NULL -- Optional: if objecting from a specific activity
) RETURNS JSONB AS $$
DECLARE
  v_task RECORD;
BEGIN
  SELECT * INTO v_task FROM public.tasks WHERE id = p_task_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Tarea no encontrada');
  END IF;
  
  -- Allow objecting if it's completed (pending or verified)
  IF v_task.status NOT IN ('pending_verification', 'verified') THEN
    RETURN jsonb_build_object('success', false, 'message', 'La tarea no se puede objetar en su estado actual');
  END IF;
  
  -- Update task to objected status
  UPDATE public.tasks SET
    status = 'objected',
    objection_reason = p_reason,
    objected_by = p_user_id,
    objected_at = NOW(),
    updated_at = NOW()
  WHERE id = p_task_id;
  
  -- If there's an activity record, we should ideally revert the rewards associated with it.
  -- If no activity_id provided, we try to find the latest 'task_completed' activity for this task.
  IF p_activity_id IS NULL THEN
    SELECT id INTO p_activity_id 
    FROM public.household_activities 
    WHERE (metadata->>'task_id')::UUID = p_task_id 
    ORDER BY created_at DESC LIMIT 1;
  END IF;

  -- If we found an activity, delete the ledger entries rewarded for it.
  -- This effectively "suspends" the rewards until the task is verified/resolved.
  IF p_activity_id IS NOT NULL THEN
    DELETE FROM public.ledger_entries
    WHERE reference_id = p_activity_id::TEXT AND reference_type = 'activity';
    
    -- We can also update the activity to show it was objected
    UPDATE public.household_activities 
    SET description = COALESCE(description, '') || ' (OBJETADA: ' || p_reason || ')'
    WHERE id = p_activity_id;
  END IF;

  RETURN jsonb_build_object('success', true, 'message', 'Tarea objetada y recompensas revertidas');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
;