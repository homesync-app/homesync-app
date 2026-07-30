-- Reconstructed from remote migration history (version 20260219204536).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.reject_task_transaction(
  p_request_id TEXT,
  p_user_id UUID,
  p_task_id UUID,
  p_rejected_by UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_rows_affected INTEGER;
  v_start_time TIMESTAMPTZ := NOW();
  v_result JSONB;
  v_household_id UUID;
BEGIN
  SELECT household_id INTO v_household_id FROM tasks WHERE id = p_task_id;

  UPDATE public.tasks
  SET 
    status = 'rejected',
    updated_at = NOW()
  WHERE id = p_task_id
  AND status = 'pending_verification';

  GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

  IF v_rows_affected = 0 THEN
    v_result := jsonb_build_object(
      'success', false,
      'message', 'Task not in pending_verification state'
    );
    RETURN v_result;
  END IF;

  INSERT INTO public.audit_logs (
    request_id,
    user_id,
    household_id,
    action,
    entity_type,
    entity_id,
    new_value,
    reason,
    source
  ) VALUES (
    p_request_id,
    p_user_id,
    v_household_id,
    'reject_task',
    'task',
    p_task_id,
    jsonb_build_object('status', 'rejected'),
    p_reason,
    'rpc'
  );

  v_result := jsonb_build_object(
    'success', true,
    'message', 'Task rejected'
  );

  RETURN v_result;
END;
$$;
