-- Reconstructed from remote migration history (version 20260218104154).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Update create_task function to remove description parameter
CREATE OR REPLACE FUNCTION public.create_task(
  p_user_id UUID,
  p_household_id UUID,
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
AS $$
DECLARE
  v_task_id UUID;
BEGIN
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
    p_household_id,
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
$$ SECURITY DEFINER;

-- Add ensure_user_household function
CREATE OR REPLACE FUNCTION public.ensure_user_household(
  p_user_id UUID,
  p_household_name TEXT DEFAULT 'Mi Hogar'
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_household_id UUID;
BEGIN
  SELECT household_id INTO v_household_id
  FROM public.household_members
  WHERE user_id = p_user_id
  LIMIT 1;

  IF v_household_id IS NOT NULL THEN
    RETURN v_household_id;
  END IF;

  INSERT INTO public.households (name)
  VALUES (p_household_name)
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

  RETURN v_household_id;
END;
$$ SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.create_task(
  UUID, UUID, TEXT, TEXT, UUID, TEXT, TEXT, INTEGER, INTEGER, TEXT, TIMESTAMPTZ
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.ensure_user_household(
  UUID, TEXT
) TO authenticated;
