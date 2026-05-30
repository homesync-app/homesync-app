-- Reconstructed from remote migration history (version 20260221155513).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Fix existing tasks with missing completed_at
UPDATE public.tasks 
SET completed_at = COALESCE(last_completed_at, updated_at)
WHERE status IN ('pending_verification', 'verified', 'objected') 
AND completed_at IS NULL;

-- Drop and recreate the function with the fix
DROP FUNCTION IF EXISTS public.complete_task_transaction(TEXT, UUID, UUID, UUID, INTEGER, INTEGER, TEXT);

CREATE OR REPLACE FUNCTION public.complete_task_transaction(
  p_request_id TEXT,
  p_user_id UUID,
  p_task_id UUID,
  p_household_id UUID,
  p_xp_reward INTEGER,
  p_coin_reward INTEGER,
  p_task_title TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_rows_affected INTEGER;
  v_start_time TIMESTAMPTZ := NOW();
  v_result JSONB := '{"success": true, "message": "Task completed"}'::jsonb;
BEGIN
  -- Log start of operation
  INSERT INTO public.system_events (
    request_id,
    user_id,
    event_type,
    entity_type,
    entity_id,
    household_id,
    operation,
    result,
    source,
    metadata
  ) VALUES (
    p_request_id,
    p_user_id,
    'task_completion_start',
    'task',
    p_task_id,
    p_household_id,
    'complete_task_transaction',
    'success',
    'rpc',
    jsonb_build_object(
      'xp_reward', p_xp_reward,
      'coin_reward', p_coin_reward,
      'title', p_task_title
    )
  );

  -- Update task with CONDITIONAL update AND verify rows affected
  UPDATE public.tasks
  SET 
    status = 'pending_verification',
    completed_at = NOW(),
    completed_by = p_user_id,
    last_completed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_task_id
  AND status IN ('assigned', 'active', 'in_progress');

  GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

  -- If 0 rows affected, task was not in completable state
  IF v_rows_affected = 0 THEN
    v_result := jsonb_build_object(
      'success', false,
      'message', 'Task already completed or not in completable state',
      'status', 'skipped'
    );
    
    INSERT INTO public.system_events (
      request_id,
      user_id,
      event_type,
      entity_type,
      entity_id,
      household_id,
      operation,
      result,
      duration_ms,
      source,
      metadata
    ) VALUES (
      p_request_id,
      p_user_id,
      'task_completion_skipped',
      'task',
      p_task_id,
      p_household_id,
      'complete_task_transaction',
      'skipped',
      EXTRACT(MILLISECONDS FROM (NOW() - v_start_time))::INTEGER,
      'rpc',
      jsonb_build_object('reason', 'task_not_in_completable_state')
    );

    RETURN v_result;
  END IF;

  -- Create XP entry (if reward > 0)
  IF p_xp_reward > 0 THEN
    INSERT INTO public.ledger_entries (
      id,
      household_id,
      user_id,
      type,
      amount,
      currency,
      reference_id,
      reference_type,
      description,
      created_at,
      created_by,
      source
    ) VALUES (
      gen_random_uuid(),
      p_household_id,
      p_user_id,
      'xp_earned',
      p_xp_reward,
      'XP',
      p_task_id::TEXT,
      'task_completion',
      'XP earned for task: ' || p_task_title,
      NOW(),
      p_user_id::TEXT,
      'rpc'
    )
    ON CONFLICT (reference_id, type, user_id) DO NOTHING;
  END IF;

  -- Create Coins entry (if reward > 0)
  IF p_coin_reward > 0 THEN
    INSERT INTO public.ledger_entries (
      id,
      household_id,
      user_id,
      type,
      amount,
      currency,
      reference_id,
      reference_type,
      description,
      created_at,
      created_by,
      source
    ) VALUES (
      gen_random_uuid(),
      p_household_id,
      p_user_id,
      'coins_earned',
      p_coin_reward,
      'COIN',
      p_task_id::TEXT,
      'task_completion',
      'Coins earned for task: ' || p_task_title,
      NOW(),
      p_user_id::TEXT,
      'rpc'
    )
    ON CONFLICT (reference_id, type, user_id) DO NOTHING;
  END IF;

  -- Log successful completion
  INSERT INTO public.system_events (
    request_id,
    user_id,
    event_type,
    entity_type,
    entity_id,
    household_id,
    operation,
    result,
    duration_ms,
    source,
    metadata
  ) VALUES (
    p_request_id,
    p_user_id,
    'task_completion_success',
    'task',
    p_task_id,
    p_household_id,
    'complete_task_transaction',
    'success',
    EXTRACT(MILLISECONDS FROM (NOW() - v_start_time))::INTEGER,
    'rpc',
    jsonb_build_object(
      'xp_reward', p_xp_reward,
      'coin_reward', p_coin_reward
    )
  );

  -- Create audit log
  INSERT INTO public.audit_logs (
    request_id,
    user_id,
    household_id,
    action,
    entity_type,
    entity_id,
    new_value,
    reason,
    source
  ) VALUES (
    p_request_id,
    p_user_id,
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object(
      'status', 'pending_verification',
      'xp_reward', p_xp_reward,
      'coin_reward', p_coin_reward
    ),
    'Task completed by user',
    'rpc'
  );

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_task_transaction(TEXT, UUID, UUID, UUID, INTEGER, INTEGER, TEXT) TO authenticated;
;