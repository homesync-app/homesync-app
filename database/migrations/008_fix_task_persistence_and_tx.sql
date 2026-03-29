-- Fix Task Persistence and Complete Task Tx

-- 1. Create task with full recurrence info
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
  p_due_at TIMESTAMPTZ DEFAULT NULL,
  p_recurrence_type TEXT DEFAULT NULL,
  p_recurrence_interval INTEGER DEFAULT 1,
  p_recurrence_end_at TIMESTAMPTZ DEFAULT NULL,
  p_recurrence_weekdays INTEGER[] DEFAULT '{}',
  p_recurrence_month_days INTEGER[] DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task_id UUID;
  v_household_id UUID;
BEGIN
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
    status,
    recurrence_type,
    recurrence_interval,
    recurrence_end_at,
    recurrence_weekdays,
    recurrence_month_days
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
    'active',
    p_recurrence_type,
    p_recurrence_interval,
    p_recurrence_end_at,
    p_recurrence_weekdays,
    p_recurrence_month_days
  )
  RETURNING id INTO v_task_id;

  RETURN v_task_id;
END;
$$;


-- 2. Complete single task tx
CREATE OR REPLACE FUNCTION public.complete_task_transaction(
  p_request_id TEXT,
  p_user_ids UUID[],
  p_task_id UUID,
  p_household_id UUID,
  p_xp_reward INTEGER,
  p_coin_reward INTEGER,
  p_task_title TEXT,
  p_completed_at TIMESTAMPTZ DEFAULT NULL
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
  v_eff_completed_at TIMESTAMPTZ;
BEGIN
  v_eff_completed_at := COALESCE(p_completed_at, NOW());

  SELECT description, category INTO v_task_desc, v_task_cat
  FROM public.tasks 
  WHERE id = p_task_id AND household_id = p_household_id
  AND status IN ('assigned', 'active', 'in_progress', 'objected')
  FOR UPDATE;

  IF NOT FOUND THEN
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

  INSERT INTO public.household_activities (
    household_id, 
    user_id, 
    event_type, 
    title, 
    description, 
    metadata
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
    )
  ) RETURNING id INTO v_activity_id;

  UPDATE public.tasks
  SET 
    status = 'pending_verification',
    completed_at = v_eff_completed_at,
    completed_by = p_user_ids[1],
    last_completed_at = v_eff_completed_at,
    updated_at = NOW()
  WHERE id = p_task_id;

  FOREACH v_user_id IN ARRAY p_user_ids
  LOOP
    IF p_xp_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned', p_xp_reward, 'XP', v_activity_id::TEXT, 'activity', 'XP: ' || p_task_title, 'rpc', v_user_id::TEXT
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;

    IF p_coin_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned', p_coin_reward, 'COIN', v_activity_id::TEXT, 'activity', 'Coins: ' || p_task_title, 'rpc', v_user_id::TEXT
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;
  END LOOP;

  INSERT INTO public.audit_logs (request_id, user_id, household_id, action, entity_type, entity_id, new_value, reason, source)
  VALUES (p_request_id, p_user_ids[1], p_household_id, 'complete_task', 'task', p_task_id, jsonb_build_object('status', 'pending_verification', 'activity_id', v_activity_id, 'performers', p_user_ids, 'completed_at', v_eff_completed_at), 'Completed', 'rpc');

  RETURN v_result;
END;
$$;


-- 3. Complete multiple tasks in batch
CREATE OR REPLACE FUNCTION public.complete_tasks_batch(
  p_request_id TEXT,
  p_user_ids UUID[],
  p_task_ids UUID[],
  p_household_id UUID,
  p_completed_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task_id UUID;
  v_xp_reward INTEGER;
  v_coin_reward INTEGER;
  v_task_title TEXT;
  v_task_desc TEXT;
  v_task_cat TEXT;
  v_activity_id UUID;
  v_user_id UUID;
  v_eff_completed_at TIMESTAMPTZ;
  v_count INTEGER := 0;
BEGIN
  v_eff_completed_at := COALESCE(p_completed_at, NOW());

  FOREACH v_task_id IN ARRAY p_task_ids
  LOOP
    SELECT title, description, category, xp_reward, coin_reward
    INTO v_task_title, v_task_desc, v_task_cat, v_xp_reward, v_coin_reward
    FROM public.tasks 
    WHERE id = v_task_id AND household_id = p_household_id
    AND status IN ('assigned', 'active', 'in_progress', 'objected')
    FOR UPDATE;

    IF FOUND THEN
      -- Create individual activity per task for clear tracking
      INSERT INTO public.household_activities (
        household_id, user_id, event_type, title, description, metadata
      ) VALUES (
        p_household_id, p_user_ids[1], 'task_completed', v_task_title, v_task_desc,
        jsonb_build_object('task_id', v_task_id, 'batch_request_id', p_request_id, 'xp_per_user', v_xp_reward, 'coins_per_user', v_coin_reward, 'performers', p_user_ids, 'category', v_task_cat)
      ) RETURNING id INTO v_activity_id;

      -- Mark completed
      UPDATE public.tasks
      SET 
        status = 'pending_verification',
        completed_at = v_eff_completed_at,
        completed_by = p_user_ids[1],
        last_completed_at = v_eff_completed_at,
        updated_at = NOW()
      WHERE id = v_task_id;

      -- Award
      FOREACH v_user_id IN ARRAY p_user_ids
      LOOP
        IF v_xp_reward > 0 THEN
          INSERT INTO public.ledger_entries (id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by) 
          VALUES (gen_random_uuid(), p_household_id, v_user_id, 'xp_earned', v_xp_reward, 'XP', v_activity_id::TEXT, 'activity', 'XP: ' || v_task_title, 'rpc_batch', v_user_id::TEXT) 
          ON CONFLICT (user_id, type, reference_id) DO NOTHING;
        END IF;

        IF v_coin_reward > 0 THEN
          INSERT INTO public.ledger_entries (id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by) 
          VALUES (gen_random_uuid(), p_household_id, v_user_id, 'coins_earned', v_coin_reward, 'COIN', v_activity_id::TEXT, 'activity', 'Coins: ' || v_task_title, 'rpc_batch', v_user_id::TEXT) 
          ON CONFLICT (user_id, type, reference_id) DO NOTHING;
        END IF;
      END LOOP;

      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'message', v_count::TEXT || ' tasks completed in batch',
    'completed_count', v_count
  );
END;
$$;


GRANT EXECUTE ON FUNCTION public.create_task TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_task_transaction TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_tasks_batch TO authenticated;
