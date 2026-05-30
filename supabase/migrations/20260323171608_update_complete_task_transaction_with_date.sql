-- Reconstructed from remote migration history (version 20260323171608).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.complete_task_transaction(
  p_request_id UUID,
  p_user_ids UUID[],
  p_task_id UUID,
  p_household_id UUID,
  p_xp_reward INTEGER,
  p_coin_reward INTEGER,
  p_task_title TEXT,
  p_completed_at TIMESTAMPTZ DEFAULT NOW()
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_activity_id UUID;
  v_task_desc TEXT;
  v_task_cat TEXT;
  v_result JSONB := '{"success": true, "message": "Task completed"}'::jsonb;
BEGIN
  -- 1. Lock and fetch task info
  SELECT description, category
    INTO v_task_desc, v_task_cat
  FROM public.tasks
  WHERE id = p_task_id
    AND household_id = p_household_id
    AND status IN (
      'assigned',
      'active',
      'in_progress',
      'objected',
      'pending_approval',
      'pending_verification',
      'verified'
    )
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Task not found or not in completable state',
      'status', 'skipped'
    );
  END IF;

  -- 2. Create activity record
  INSERT INTO public.household_activities (
    household_id,
    user_id,
    event_type,
    title,
    description,
    metadata,
    created_at
  ) VALUES (
    p_household_id,
    p_user_ids[1],
    'task_completed',
    p_task_title,
    v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', p_xp_reward,
      'coins_per_user', p_coin_reward,
      'performers', p_user_ids,
      'category', v_task_cat
    ),
    p_completed_at
  ) RETURNING id INTO v_activity_id;

  -- 3. Update task status and completion info
  UPDATE public.tasks
  SET
    status = 'active',
    completed_at = p_completed_at,
    completed_by = p_user_ids[1],
    last_completed_at = p_completed_at,
    last_verified_by = NULL,
    updated_at = NOW()
  WHERE id = p_task_id;

  -- 4. Create ledger entries for rewards
  FOREACH v_user_id IN ARRAY p_user_ids
  LOOP
    IF p_xp_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by, created_at
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned', p_xp_reward, 'XP', v_activity_id::TEXT, 'activity', 'XP: ' || p_task_title, 'rpc', v_user_id::TEXT, p_completed_at
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;

    IF p_coin_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by, created_at
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned', p_coin_reward, 'COIN', v_activity_id::TEXT, 'activity', 'Coins: ' || p_task_title, 'rpc', v_user_id::TEXT, p_completed_at
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;
  END LOOP;

  -- 5. Log the action
  INSERT INTO public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id, new_value, reason, source, created_at
  )
  VALUES (
    p_request_id,
    p_user_ids[1],
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object('status', 'active', 'activity_id', v_activity_id, 'performers', p_user_ids),
    'Completed',
    'rpc',
    p_completed_at
  );

  RETURN v_result || jsonb_build_object(
    'activity_id', v_activity_id,
    'task_status', 'active',
    'xp_earned', p_xp_reward,
    'coins_earned', p_coin_reward
  );
END;
$$;
;