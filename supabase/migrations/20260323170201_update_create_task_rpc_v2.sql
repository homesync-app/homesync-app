-- Reconstructed from remote migration history (version 20260323170201).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.create_task(
  p_user_id uuid,
  p_title text,
  p_category text DEFAULT NULL::text,
  p_assigned_to uuid DEFAULT NULL::uuid,
  p_type text DEFAULT 'one_time'::text,
  p_difficulty text DEFAULT 'medium'::text,
  p_xp_reward integer DEFAULT 0,
  p_coin_reward integer DEFAULT 0,
  p_priority text DEFAULT 'medium'::text,
  p_due_at timestamp with time zone DEFAULT NULL::timestamp with time zone,
  p_recurrence_type text DEFAULT NULL::text,
  p_recurrence_interval integer DEFAULT 1,
  p_recurrence_end_at timestamp with time zone DEFAULT NULL::timestamp with time zone,
  p_recurrence_weekdays integer[] DEFAULT ARRAY[]::integer[],
  p_recurrence_month_days integer[] DEFAULT ARRAY[]::integer[]
) RETURNS uuid AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
;