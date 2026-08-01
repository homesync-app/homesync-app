-- Reconstructed from remote migration history (version 20260219232527).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Update create_task to support recurrence
DROP FUNCTION IF EXISTS create_task(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER, INTEGER, TEXT, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION create_task(
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
  p_recurrence_end_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID AS $$
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
    recurrence_end_at
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
    p_recurrence_end_at
  )
  RETURNING id INTO v_task_id;

  RETURN v_task_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update verify_task_transaction to create next recurring task
CREATE OR REPLACE FUNCTION verify_task_transaction(
  p_request_id TEXT,
  p_user_id UUID,
  p_task_id UUID,
  p_verified_by UUID,
  p_next_due_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_task RECORD;
  v_household_id UUID;
  v_user_role TEXT;
  v_household_type TEXT;
  v_can_verify BOOLEAN;
  v_new_task_id UUID;
BEGIN
  SELECT * INTO v_task FROM tasks WHERE id = p_task_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Task not found');
  END IF;

  IF v_task.status != 'pending_verification' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Task is not pending verification');
  END IF;

  SELECT hm.household_id, hm.role, h.household_type
  INTO v_household_id, v_user_role, v_household_type
  FROM household_members hm
  JOIN households h ON h.id = hm.household_id
  WHERE hm.user_id = p_user_id;

  IF v_household_type = 'family' AND v_user_role NOT IN ('owner', 'admin') THEN
    RETURN jsonb_build_object('success', false, 'message', 'Only parents can verify tasks in family');
  END IF;

  UPDATE tasks SET
    status = 'verified',
    last_verified_by = p_verified_by,
    next_due_at = p_next_due_at,
    updated_at = NOW()
  WHERE id = p_task_id;

  INSERT INTO audit_logs (household_id, user_id, action, entity_type, entity_id, details)
  VALUES (
    v_household_id,
    p_user_id,
    'task_verified',
    'task',
    p_task_id,
    jsonb_build_object('title', v_task.title, 'xp', v_task.xp_reward, 'coins', v_task.coin_reward)
  );

  IF v_task.recurrence_type IS NOT NULL THEN
    v_new_task_id := create_next_recurring_task(p_task_id, p_verified_by);
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Task verified successfully',
    'new_recurring_task', v_new_task_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
;