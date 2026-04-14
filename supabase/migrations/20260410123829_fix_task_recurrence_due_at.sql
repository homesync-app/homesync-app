-- Migration to fix task recurrence rescheduling
-- Adds a helper function and updates completion RPCs

CREATE OR REPLACE FUNCTION public.calculate_next_task_due_at(
  p_current_due_at TIMESTAMPTZ,
  p_recurrence_type TEXT,
  p_recurrence_interval INTEGER DEFAULT 1
)
RETURNS TIMESTAMPTZ
LANGUAGE plpgsql
AS $$
DECLARE
  v_next_due_at TIMESTAMPTZ;
  v_base_date TIMESTAMPTZ;
BEGIN
  -- If not recurring, no next due date
  IF p_recurrence_type IS NULL OR p_recurrence_type = 'none' THEN
    RETURN NULL;
  END IF;

  -- Base calculation on the GREATEST of current due date and NOW
  -- This ensures we don't schedule tasks in the past if they were very overdue
  v_base_date := GREATEST(p_current_due_at, NOW());

  IF p_recurrence_type = 'daily' THEN
    v_next_due_at := v_base_date + (COALESCE(p_recurrence_interval, 1) || ' days')::INTERVAL;
  ELSIF p_recurrence_type = 'weekly' THEN
    v_next_due_at := v_base_date + (COALESCE(p_recurrence_interval, 1) || ' weeks')::INTERVAL;
  ELSIF p_recurrence_type = 'monthly' THEN
    v_next_due_at := v_base_date + (COALESCE(p_recurrence_interval, 1) || ' months')::INTERVAL;
  ELSE
    -- Default fallback
    v_next_due_at := v_base_date + INTERVAL '1 day';
  END IF;

  -- Normalize to start of day (00:00:00) to match the app's behavior for daily tasks
  RETURN DATE_TRUNC('day', v_next_due_at);
END;
$$;

-- Update complete_task_transaction
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
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_activity_id UUID;
  v_task_desc TEXT;
  v_task_cat TEXT;
  v_due_at TIMESTAMPTZ;
  v_rec_type TEXT;
  v_rec_interval INTEGER;
  v_next_due_at TIMESTAMPTZ;
  v_result JSONB := '{"success": true, "message": "Task completed"}'::jsonb;
BEGIN
  SELECT description, category, due_at, recurrence_type, recurrence_interval
    INTO v_task_desc, v_task_cat, v_due_at, v_rec_type, v_rec_interval
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

  -- Calculate next due date if recurring
  v_next_due_at := public.calculate_next_task_due_at(v_due_at, v_rec_type, v_rec_interval);

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
    status = 'active',
    due_at = COALESCE(v_next_due_at, due_at), -- Update to next cycle if recurring
    completed_at = NOW(),
    completed_by = p_user_ids[1],
    last_completed_at = NOW(),
    last_verified_by = NULL,
    verified_by = NULL,
    verified_at = NULL,
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

  INSERT INTO public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id, new_value, reason, source
  )
  VALUES (
    p_request_id,
    p_user_ids[1],
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object(
      'status', 'active', 
      'activity_id', v_activity_id, 
      'performers', p_user_ids,
      'next_due_at', v_next_due_at
    ),
    'Completed and rescheduled if recurring',
    'rpc'
  );

  RETURN v_result || jsonb_build_object('activity_id', v_activity_id, 'task_status', 'active', 'next_due_at', v_next_due_at);
END;
$$;


-- Update qa_admin_complete_task
CREATE OR REPLACE FUNCTION public.qa_admin_complete_task(
  p_household_id UUID,
  p_user_ids UUID[],
  p_task_id UUID,
  p_xp_reward INTEGER,
  p_coin_reward INTEGER,
  p_task_title TEXT,
  p_completed_at TIMESTAMPTZ DEFAULT NOW()
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_actor_id UUID;
  v_user_id UUID;
  v_activity_id UUID;
  v_task_desc TEXT;
  v_task_cat TEXT;
  v_due_at TIMESTAMPTZ;
  v_rec_type TEXT;
  v_rec_interval INTEGER;
  v_next_due_at TIMESTAMPTZ;
BEGIN
  v_actor_id := public.qa_admin_require_access();

  IF NOT EXISTS (
    SELECT 1
    FROM public.qa_admin_household_defaults(p_household_id)
    WHERE household_name IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Escenario QA invalido';
  END IF;

  IF p_user_ids IS NULL OR COALESCE(ARRAY_LENGTH(p_user_ids, 1), 0) = 0 THEN
    RAISE EXCEPTION 'Debe informarse al menos un usuario';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM unnest(p_user_ids) AS uid
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.household_members hm
      WHERE hm.household_id = p_household_id
        AND hm.user_id = uid
    )
  ) THEN
    RAISE EXCEPTION 'Uno o mas usuarios no pertenecen al hogar QA seleccionado';
  END IF;

  SELECT description, category, due_at, recurrence_type, recurrence_interval
    INTO v_task_desc, v_task_cat, v_due_at, v_rec_type, v_rec_interval
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

  -- Calculate next due date if recurring
  v_next_due_at := public.calculate_next_task_due_at(v_due_at, v_rec_type, v_rec_interval);

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
      'task_title', p_task_title,
      'xp_reward', p_xp_reward,
      'coins_reward', p_coin_reward,
      'performers', p_user_ids,
      'category', v_task_cat
    )
  ) RETURNING id INTO v_activity_id;

  UPDATE public.tasks
  SET
    status = 'active',
    due_at = COALESCE(v_next_due_at, due_at),
    completed_at = p_completed_at,
    completed_by = p_user_ids[1],
    last_completed_at = p_completed_at,
    last_verified_by = NULL,
    updated_at = NOW()
  WHERE id = p_task_id;

  FOREACH v_user_id IN ARRAY p_user_ids
  LOOP
    IF p_xp_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned', p_xp_reward, 'XP', v_activity_id::TEXT, 'activity', 'XP: ' || p_task_title, 'qa_admin', v_actor_id::TEXT
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;

    IF p_coin_reward > 0 THEN
      INSERT INTO public.ledger_entries (
        id, household_id, user_id, type, amount, currency, reference_id, reference_type, description, source, created_by
      ) VALUES (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned', p_coin_reward, 'COIN', v_activity_id::TEXT, 'activity', 'Coins: ' || p_task_title, 'qa_admin', v_actor_id::TEXT
      ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
    END IF;
  END LOOP;

  INSERT INTO public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id, new_value, reason, source
  ) VALUES (
    'qa_admin_' || extract(epoch from now())::bigint,
    v_actor_id,
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object(
      'status', 'active', 
      'activity_id', v_activity_id, 
      'performers', p_user_ids,
      'next_due_at', v_next_due_at
    ),
    'QA admin completed task and rescheduled if recurring',
    'qa_admin'
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Task completed',
    'status', 'ok',
    'activity_id', v_activity_id,
    'task_status', 'active',
    'next_due_at', v_next_due_at,
    'xp_earned', p_xp_reward,
    'coins_earned', p_coin_reward
  );
END;
$$;
