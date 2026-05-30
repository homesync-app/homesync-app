-- Reconstructed from remote migration history (version 20260218104835).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Drop existing function
DROP FUNCTION IF EXISTS public.create_task(UUID, UUID, TEXT, TEXT, UUID, TEXT, TEXT, INTEGER, INTEGER, TEXT, TIMESTAMPTZ);

-- Create new function that auto-creates household
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

-- Grant permission
GRANT EXECUTE ON FUNCTION public.create_task(
  UUID, TEXT, TEXT, UUID, TEXT, TEXT, INTEGER, INTEGER, TEXT, TIMESTAMPTZ
) TO authenticated;
