-- Reconstructed from remote migration history (version 20260318005757).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION resolve_task_objection(
  p_task_id UUID,
  p_user_id UUID -- The person who objected (partner)
) RETURNS JSONB AS $$
DECLARE
  v_task RECORD;
  v_activity RECORD;
BEGIN
  SELECT * INTO v_task FROM public.tasks WHERE id = p_task_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Tarea no encontrada');
  END IF;
  
  IF v_task.status != 'objected' THEN
    RETURN jsonb_build_object('success', false, 'message', 'La tarea no estâ”œÃ­ en disputa');
  END IF;
  
  IF v_task.objected_by != p_user_id THEN
    RETURN jsonb_build_object('success', false, 'message', 'Solo quien objetâ”œâ”‚ puede retirar la objeciâ”œâ”‚n');
  END IF;
  
  -- Update task back to verified
  UPDATE public.tasks SET
    status = 'verified',
    objection_reason = NULL,
    objected_by = NULL,
    objected_at = NULL,
    updated_at = NOW()
  WHERE id = p_task_id;
  
  -- Find the activity to restore rewards
  SELECT * INTO v_activity 
  FROM public.household_activities 
  WHERE (metadata->>'task_id')::UUID = p_task_id 
  ORDER BY created_at DESC LIMIT 1;

  IF v_activity IS NOT NULL THEN
    -- Restore ledger entries (XP and Coins)
    INSERT INTO public.ledger_entries (user_id, household_id, amount, currency, type, description, reference_type, reference_id)
    VALUES 
      (v_activity.user_id, v_activity.household_id, (v_activity.metadata->>'xp_per_user')::INTEGER, 'XP', 'task_completion', 'Tarea verificada (postponed)', 'activity', v_activity.id::TEXT),
      (v_activity.user_id, v_activity.household_id, (v_activity.metadata->>'coins_per_user')::INTEGER, 'COIN', 'task_completion', 'Tarea verificada (postponed)', 'activity', v_activity.id::TEXT);
  END IF;

  RETURN jsonb_build_object('success', true, 'message', 'Objeciâ”œâ”‚n retirada y recompensas restauradas');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
;