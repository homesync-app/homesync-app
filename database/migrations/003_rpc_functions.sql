-- ============================================
-- RPC FUNCTIONS FOR HOMESYNC
-- ============================================
-- Transactional functions for task operations
-- ============================================

-- ============================================
-- COMPLETE TASK TRANSACTION
-- ============================================

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
$$ SECURITY DEFINER;

-- ============================================
-- VERIFY TASK TRANSACTION
-- ============================================

CREATE OR REPLACE FUNCTION public.verify_task_transaction(
  p_request_id TEXT,
  p_user_id UUID,
  p_task_id UUID,
  p_verified_by UUID,
  p_next_due_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_rows_affected INTEGER;
  v_start_time TIMESTAMPTZ := NOW();
  v_result JSONB := '{"success": true, "message": "Task verified"}'::jsonb;
BEGIN
  -- Log start
  INSERT INTO public.system_events (
    request_id,
    user_id,
    event_type,
    entity_type,
    entity_id,
    operation,
    result,
    source,
    metadata
  ) VALUES (
    p_request_id,
    p_user_id,
    'task_verification_start',
    'task',
    p_task_id,
    NULL,
    'verify_task_transaction',
    'success',
    'rpc',
    jsonb_build_object(
      'next_due_at', p_next_due_at
    )
  );

  -- Update task
  UPDATE public.tasks
  SET 
    status = 'verified',
    last_verified_by = p_verified_by,
    next_due_at = p_next_due_at,
    updated_at = NOW()
  WHERE id = p_task_id
  AND status IN ('pending_verification', 'in_review');

  GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

  -- If 0 rows affected
  IF v_rows_affected = 0 THEN
    v_result := jsonb_build_object(
      'success', false,
      'message', 'Task already verified or not pending verification',
      'status', 'skipped'
    );

    INSERT INTO public.system_events (
      request_id,
      user_id,
      event_type,
      entity_type,
      entity_id,
      operation,
      result,
      duration_ms,
      source,
      metadata
    ) VALUES (
      p_request_id,
      p_user_id,
      'task_verification_skipped',
      'task',
      p_task_id,
      NULL,
      'verify_task_transaction',
      'skipped',
      EXTRACT(MILLISECONDS FROM (NOW() - v_start_time))::INTEGER,
      'rpc',
      jsonb_build_object('reason', 'task_not_verifiable')
    );

    RETURN v_result;
  END IF;

  -- Log success
  INSERT INTO public.system_events (
    request_id,
    user_id,
    event_type,
    entity_type,
    entity_id,
    operation,
    result,
    duration_ms,
    source,
    metadata
  ) VALUES (
    p_request_id,
    p_user_id,
    'task_verification_success',
    'task',
    p_task_id,
    NULL,
    'verify_task_transaction',
    'success',
    EXTRACT(MILLISECONDS FROM (NOW() - v_start_time))::INTEGER,
    'rpc',
    jsonb_build_object('next_due_at', p_next_due_at)
  );

  -- Audit log
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
    NULL,
    'verify_task',
    'task',
    p_task_id,
    jsonb_build_object(
      'status', 'verified',
      'verified_by', p_verified_by,
      'next_due_at', p_next_due_at
    ),
    'Task verified',
    'rpc'
  );

  RETURN v_result;
END;
$$ SECURITY DEFINER;

-- ============================================
-- CREATE TASK FUNCTION (Auto-creates household)
-- ============================================

CREATE OR REPLACE FUNCTION public.create_task(
  p_user_id UUID,
  p_title TEXT,
  p_category TEXT DEFAULT NULL,
  p_assigned_to UUID DEFAULT NULL,
  p_type TEXT DEFAULT 'one_time',
  p_difficulty TEXT DEFAULT 'medium',
  p_xp_reward INTEGER DEFAULT 0,
  p_coin_reward INTEGER DEFAULT 0,
  p_priority TEXT DEFAULT 'medium',
  p_due_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task_id UUID;
  v_household_id UUID;
BEGIN
  -- Get or create household for user
  SELECT household_id INTO v_household_id
  FROM public.household_members
  WHERE user_id = p_user_id
  LIMIT 1;

  IF v_household_id IS NULL THEN
    INSERT INTO public.households (name)
    VALUES ('Mi Hogar')
    RETURNING id INTO v_household_id;

    INSERT INTO public.household_members (
      household_id,
      user_id,
      role
    ) VALUES (
      v_household_id,
      p_user_id,
      'owner'
    );
  END IF;

  -- Create task
  INSERT INTO public.tasks (
    id,
    household_id,
    assigned_to,
    created_by_id,
    title,
    description,
    category,
    type,
    difficulty,
    xp_reward,
    coin_reward,
    priority,
    due_at,
    status
  ) VALUES (
    gen_random_uuid(),
    v_household_id,
    p_assigned_to,
    p_user_id,
    p_title,
    NULL,
    p_category,
    p_type,
    p_difficulty,
    p_xp_reward,
    p_coin_reward,
    p_priority,
    p_due_at,
    'active'
  )
  RETURNING id INTO v_task_id;

  RETURN v_task_id;
END;
$$;

-- ============================================
-- GET BALANCE FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION public.get_user_balance(
  p_user_id UUID,
  p_household_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_xp INTEGER := 0;
  v_coins INTEGER := 0;
BEGIN
  -- Calculate XP balance
  SELECT COALESCE(SUM(amount), 0)
  INTO v_xp
  FROM public.ledger_entries
  WHERE user_id = p_user_id
  AND household_id = p_household_id
  AND currency = 'XP';

  -- Calculate Coins balance
  SELECT COALESCE(SUM(amount), 0)
  INTO v_coins
  FROM public.ledger_entries
  WHERE user_id = p_user_id
  AND household_id = p_household_id
  AND currency = 'COIN';

  RETURN jsonb_build_object(
    'user_id', p_user_id,
    'household_id', p_household_id,
    'xp', v_xp,
    'coins', v_coins
  );
END;
$$ SECURITY DEFINER;

-- ============================================
-- GRANTS
-- ============================================

GRANT EXECUTE ON FUNCTION public.complete_task_transaction(
  TEXT, UUID, UUID, UUID, INTEGER, INTEGER, TEXT
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.verify_task_transaction(
  TEXT, UUID, UUID, UUID, TIMESTAMPTZ
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.create_task(
  UUID, TEXT, TEXT, UUID, TEXT, TEXT, INTEGER, INTEGER, TEXT, TIMESTAMPTZ
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.get_user_balance(
  UUID, UUID
) TO authenticated;
