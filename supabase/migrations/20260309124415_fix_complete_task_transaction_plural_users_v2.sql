-- Reconstructed from remote migration history (version 20260309124415).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Update complete_task_transaction to support multiple users (p_user_ids array)
-- This fixes the bug where completing a task with multiple performers would fail.

CREATE OR REPLACE FUNCTION public.complete_task_transaction(
  p_request_id TEXT,
  p_user_ids UUID[], -- Changed from p_user_id UUID
  p_task_id UUID,
  p_household_id UUID,
  p_xp_reward INTEGER,
  p_coin_reward INTEGER,
  p_task_title TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_rows_affected INTEGER;
  v_user_id UUID;
  v_start_time TIMESTAMPTZ := NOW();
  v_result JSONB := '{"success": true, "message": "Task completed"}'::jsonb;
BEGIN
  -- We use the first user in the array for the system_events logging
  v_user_id := p_user_ids[1];

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
    v_user_id,
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
      'title', p_task_title,
      'user_ids', p_user_ids
    )
  );

  -- Update task with CONDITIONAL update AND verify rows affected
  UPDATE public.tasks
  SET 
    status = 'pending_verification',
    completed_at = NOW(),
    completed_by = v_user_id, -- Main performer
    last_completed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_task_id
  AND status IN ('assigned', 'active', 'in_progress');

  GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

  -- If 0 rows affected, task was not in completable state
  IF v_rows_affected = 0 THEN
    -- Optimization: Check if it's already pending_verification (maybe another user completed it simultaneously)
    IF EXISTS (SELECT 1 FROM public.tasks WHERE id = p_task_id AND status = 'pending_verification') THEN
       RETURN jsonb_build_object(
        'success', true,
        'message', 'Task already marked as completed',
        'status', 'skipped'
      );
    END IF;

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
      v_user_id,
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

  -- Loop through all users to award XP and Coins
  FOREACH v_user_id IN ARRAY p_user_ids
  LOOP
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
        v_user_id,
        'xp_earned',
        p_xp_reward,
        'XP',
        p_task_id::TEXT,
        'task_completion',
        'XP earned for task: ' || p_task_title,
        NOW(),
        v_user_id::TEXT,
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
        v_user_id,
        'coins_earned',
        p_coin_reward,
        'COIN',
        p_task_id::TEXT,
        'task_completion',
        'Coins earned for task: ' || p_task_title,
        NOW(),
        v_user_id::TEXT,
        'rpc'
      )
      ON CONFLICT (reference_id, type, user_id) DO NOTHING;
    END IF;
  END LOOP;

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
    p_user_ids[1],
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
      'coin_reward', p_coin_reward,
      'users_count', array_length(p_user_ids, 1)
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
    p_user_ids[1],
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object(
      'status', 'pending_verification',
      'xp_reward', p_xp_reward,
      'coin_reward', p_coin_reward,
      'performers', p_user_ids
    ),
    'Task completed by ' || array_length(p_user_ids, 1) || ' users',
    'rpc'
  );

  RETURN v_result;
END;
$$ SECURITY DEFINER;
;