-- Reconstructed from remote migration history (version 20260309125847).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- DROP both old versions (single and array)
DROP FUNCTION IF EXISTS public.complete_task_transaction(p_request_id text, p_user_id uuid, p_task_id uuid, p_household_id uuid, p_xp_reward integer, p_coin_reward integer, p_task_title text);
DROP FUNCTION IF EXISTS public.complete_task_transaction(p_request_id text, p_user_ids uuid[], p_task_id uuid, p_household_id uuid, p_xp_reward integer, p_coin_reward integer, p_task_title text);

-- CREATE robust unified version
CREATE OR REPLACE FUNCTION public.complete_task_transaction(
  p_request_id TEXT,
  p_user_ids UUID[],
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
  v_user_id UUID;
  v_activity_id UUID;
  v_start_time TIMESTAMPTZ := NOW();
  v_result JSONB := '{"success": true, "message": "Task completed"}'::jsonb;
  v_task_desc TEXT;
  v_task_cat TEXT;
BEGIN
  -- 1. Verify task existence and state
  SELECT description, category INTO v_task_desc, v_task_cat
  FROM public.tasks 
  WHERE id = p_task_id AND household_id = p_household_id
  AND status IN ('assigned', 'active', 'in_progress', 'objected')
  FOR UPDATE;

  IF NOT FOUND THEN
    -- Check if already pending_verification (maybe simultaneous update)
    IF EXISTS (SELECT 1 FROM public.tasks WHERE id = p_task_id AND status = 'pending_verification') THEN
       RETURN jsonb_build_object(
        'success', true,
        'message', 'Task already marked as completed',
        'status', 'skipped'
      );
    END IF;

    RETURN jsonb_build_object(
      'success', false,
      'message', 'Task not found or not in completable state',
      'status', 'skipped'
    );
  END IF;

  -- 2. CREATE PERMANENT ACTIVITY RECORD (This identifies this specific completion)
  INSERT INTO public.household_activities (
    household_id, 
    user_id, 
    event_type, 
    title, 
    description, 
    metadata
  ) VALUES (
    p_household_id, 
    p_user_ids[1], -- Primary performer
    'task_completed', 
    p_task_title, 
    v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', p_xp_reward,
      'coins_per_user', p_coin_reward,
      'performers', p_user_ids,
      'category', v_task_cat
    )
  ) RETURNING id INTO v_activity_id;

  -- 3. Update task status
  UPDATE public.tasks
  SET 
    status = 'pending_verification',
    completed_at = NOW(),
    completed_by = p_user_ids[1],
    last_completed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_task_id;

  -- 4. AWARD REWARDS using Activity ID as reference (avoiding ID conflicts on recurring tasks)
  FOREACH v_user_id IN ARRAY p_user_ids
  LOOP
    -- Award XP
    IF p_xp_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned', p_xp_reward, 'XP', v_activity_id::TEXT, 'activity', 'XP: ' || p_task_title, 'rpc', v_user_id::TEXT
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;

    -- Award Coins
    IF p_coin_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned', p_coin_reward, 'COIN', v_activity_id::TEXT, 'activity', 'Coins: ' || p_task_title, 'rpc', v_user_id::TEXT
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;
  END LOOP;

  -- 5. Audit Logging
  INSERT INTO public.audit_logs (request_id, user_id, household_id, action, entity_type, entity_id, new_value, reason, source)
  VALUES (p_request_id, p_user_ids[1], p_household_id, 'complete_task', 'task', p_task_id, jsonb_build_object('status', 'pending_verification', 'activity_id', v_activity_id, 'performers', p_user_ids), 'Completed', 'rpc');

  RETURN v_result;
END;
$$;
;