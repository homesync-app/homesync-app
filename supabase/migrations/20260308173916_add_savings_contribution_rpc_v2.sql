-- Reconstructed from remote migration history (version 20260308173916).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION add_savings_contribution(
  p_goal_id UUID,
  p_user_id UUID,
  p_amount NUMERIC,
  p_note TEXT DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
  v_household_id UUID;
  v_goal_title TEXT;
BEGIN
  -- 1. Get goal info
  SELECT household_id, title INTO v_household_id, v_goal_title FROM public.savings_goals WHERE id = p_goal_id;
  
  IF v_household_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Meta no encontrada');
  END IF;

  -- 2. Insert contribution
  INSERT INTO public.savings_contributions (goal_id, user_id, amount, note)
  VALUES (p_goal_id, p_user_id, p_amount, p_note);
  
  -- 3. Impact personal balance (deduct from ledger)
  INSERT INTO public.ledger_entries (household_id, user_id, amount, currency_type, description, source_type, source_id)
  VALUES (v_household_id, p_user_id, -p_amount, 'ARS', 'Aporte a ahorro: ' || v_goal_title, 'savings_contribution', p_goal_id);
  
  -- 4. Log activity
  INSERT INTO public.household_activities (household_id, user_id, event_type, title, description)
  VALUES (v_household_id, p_user_id, 'savings_contribution', 'Aporte a meta', 'Sumâ”œâ”‚ $' || p_amount || ' a ' || v_goal_title);

  RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql;
;