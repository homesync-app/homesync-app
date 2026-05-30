-- Reconstructed from remote migration history (version 20260308165437).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.add_savings_contribution(
  p_goal_id UUID,
  p_user_id UUID,
  p_household_id UUID,
  p_amount DECIMAL,
  p_note TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_contribution_id UUID;
  v_goal_title TEXT;
BEGIN
  -- Get goal title
  SELECT title INTO v_goal_title FROM public.savings_goals WHERE id = p_goal_id;

  -- 1. Insert contribution
  INSERT INTO public.savings_contributions (
    goal_id, user_id, amount, note
  ) VALUES (
    p_goal_id, p_user_id, p_amount, p_note
  )
  RETURNING id INTO v_contribution_id;

  -- 2. Update goal amount
  UPDATE public.savings_goals
  SET current_amount = current_amount + p_amount,
      updated_at = NOW()
  WHERE id = p_goal_id;

  -- 3. Create expense entry (impacts personal balance)
  INSERT INTO public.expenses (
    household_id, created_by_id, title, amount, paid_by, category, is_shared, type
  ) VALUES (
    p_household_id, p_user_id, 'Ahorro: ' || COALESCE(v_goal_title, 'Meta'),
    p_amount, p_user_id, 'savings', false, 'expense'
  );

  RETURN jsonb_build_object(
    'success', true,
    'contribution_id', v_contribution_id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.add_savings_contribution(UUID, UUID, UUID, DECIMAL, TEXT) TO authenticated;
