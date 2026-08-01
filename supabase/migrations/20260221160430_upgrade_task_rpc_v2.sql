-- Reconstructed from remote migration history (version 20260221160430).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- UPGRADE TASK COMPLETION TO PROFESSIONAL EVENT-BASED LOGIC
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
  v_task_record RECORD;
  v_activity_id UUID;
  v_start_time TIMESTAMPTZ := NOW();
  v_next_due TIMESTAMPTZ;
  v_result JSONB;
BEGIN
  -- 1. Get task details and verify state
  SELECT * INTO v_task_record 
  FROM public.tasks 
  WHERE id = p_task_id AND household_id = p_household_id
  FOR UPDATE; -- Lock row for consistency

  IF v_task_record IS NULL OR v_task_record.status NOT IN ('assigned', 'active', 'in_progress') THEN
    RETURN jsonb_build_object('success', false, 'message', 'Task not found or already completed');
  END IF;

  -- 2. CREATE PERMANENT ACTIVITY RECORD (The "Professional" History)
  INSERT INTO public.household_activities (
    household_id, user_id, event_type, title, description, metadata
  ) VALUES (
    p_household_id, p_user_id, 'task_completed', p_task_title, v_task_record.description,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp', p_xp_reward,
      'coins', p_coin_reward,
      'category', v_task_record.category,
      'recurrence', v_task_record.recurrence_type
    )
  ) RETURNING id INTO v_activity_id;

  -- 3. AWARD REWARDS (Referencing Activity ID to allow multiple rewards for recurring tasks)
  IF p_xp_reward > 0 THEN
    INSERT INTO public.ledger_entries (household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by)
    VALUES (p_household_id, p_user_id, 'xp_earned', p_xp_reward, 'XP', v_activity_id::TEXT, 'activity', 'XP for completing: ' || p_task_title, 'rpc', p_user_id::TEXT);
  END IF;

  IF p_coin_reward > 0 THEN
    INSERT INTO public.ledger_entries (household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by)
    VALUES (p_household_id, p_user_id, 'coins_earned', p_coin_reward, 'COIN', v_activity_id::TEXT, 'activity', 'Coins for completing: ' || p_task_title, 'rpc', p_user_id::TEXT);
  END IF;

  -- 4. UPDATE TASK STATE
  IF v_task_record.recurrence_type IS NOT NULL THEN
    -- It is a recurring task: Calculate next due date
    v_next_due := CASE 
      WHEN v_task_record.recurrence_type = 'daily' THEN NOW() + INTERVAL '1 day'
      WHEN v_task_record.recurrence_type = 'weekly' THEN NOW() + INTERVAL '7 days'
      WHEN v_task_record.recurrence_type = 'monthly' THEN NOW() + INTERVAL '1 month'
      ELSE NOW() + INTERVAL '1 day'
    END;

    UPDATE public.tasks SET
      status = 'active', -- Stays active for next time
      last_completed_at = NOW(),
      completed_at = NOW(),
      completed_by = p_user_id,
      due_at = v_next_due,
      updated_at = NOW()
    WHERE id = p_task_id;
  ELSE
    -- One-time task: Move to verification
    UPDATE public.tasks SET
      status = 'pending_verification',
      completed_at = NOW(),
      completed_by = p_user_id,
      last_completed_at = NOW(),
      updated_at = NOW()
    WHERE id = p_task_id;
  END IF;

  -- 5. AUDIT LOGS & EVENTS (Professional logging)
  INSERT INTO public.system_events (request_id, user_id, event_type, entity_type, entity_id, household_id, result, duration_ms, source)
  VALUES (p_request_id, p_user_id, 'task_completion_success', 'task', p_task_id, p_household_id, 'success', EXTRACT(MILLISECONDS FROM (NOW() - v_start_time))::INTEGER, 'rpc');

  RETURN jsonb_build_object(
    'success', true, 
    'activity_id', v_activity_id, 
    'xp_earned', p_xp_reward, 
    'coins_earned', p_coin_reward,
    'next_due', v_next_due
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_task_transaction(TEXT, UUID, UUID, UUID, INTEGER, INTEGER, TEXT) TO authenticated;
;