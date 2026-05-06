-- Fix duplicate rewards caused by non-idempotent clone_reward_templates
-- 1. Delete existing duplicates keeping the oldest row per (household_id, title)
-- 2. Make clone_reward_templates idempotent

-- Step 1: Remove duplicates, keep oldest per household+title
DELETE FROM public.rewards
WHERE id NOT IN (
  SELECT DISTINCT ON (household_id, lower(trim(title))) id
  FROM public.rewards
  ORDER BY household_id, lower(trim(title)), created_at ASC, id ASC
);

-- Step 2: Make clone_reward_templates idempotent (bail out if rewards already exist)
CREATE OR REPLACE FUNCTION public.clone_reward_templates(
  p_user_id UUID,
  p_template_ids UUID[] DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_household_id UUID;
  v_cloned_count INTEGER := 0;
  v_template record;
BEGIN
  -- Get household
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

  -- Bail out early if rewards already exist for this household
  IF EXISTS (
    SELECT 1 FROM public.rewards WHERE household_id = v_household_id
  ) THEN
    RETURN 0;
  END IF;

  -- Clone templates to the 'rewards' table
  IF p_template_ids IS NULL THEN
    FOR v_template IN SELECT * FROM public.reward_templates ORDER BY sort_order
    LOOP
      INSERT INTO public.rewards (
        household_id,
        title,
        description,
        cost,
        icon,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.title,
        v_template.description,
        v_template.cost,
        v_template.icon,
        p_user_id,
        true
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  ELSE
    FOR v_template IN
      SELECT * FROM public.reward_templates
      WHERE id = ANY(p_template_ids)
      ORDER BY sort_order
    LOOP
      INSERT INTO public.rewards (
        household_id,
        title,
        description,
        cost,
        icon,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.title,
        v_template.description,
        v_template.cost,
        v_template.icon,
        p_user_id,
        true
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  END IF;

  RETURN v_cloned_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.clone_reward_templates(UUID, UUID[]) TO authenticated;
