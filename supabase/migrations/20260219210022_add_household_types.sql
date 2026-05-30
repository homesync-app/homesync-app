-- Reconstructed from remote migration history (version 20260219210022).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.households ADD COLUMN IF NOT EXISTS household_type TEXT NOT NULL DEFAULT 'couple';
ALTER TABLE public.households ADD COLUMN IF NOT EXISTS display_name TEXT;

CREATE TYPE household_type AS ENUM ('couple', 'family', 'roommates');

ALTER TABLE public.households ALTER COLUMN household_type TYPE TEXT;

COMMENT ON COLUMN public.households.household_type IS 'couple: Pareja (2 personas), family: Familia, roommates: Compaâ”œâ–’eros';
COMMENT ON COLUMN public.households.display_name IS 'Nombre personalizado del hogar';

CREATE OR REPLACE FUNCTION public.can_verify_tasks(
  p_user_id UUID,
  p_household_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_household_type TEXT;
  v_user_role TEXT;
BEGIN
  SELECT h.household_type, hm.role INTO v_household_type, v_user_role
  FROM households h
  JOIN household_members hm ON hm.household_id = h.id
  WHERE h.id = p_household_id AND hm.user_id = p_user_id;
  
  IF NOT FOUND THEN
    RETURN false;
  END IF;
  
  IF v_household_type = 'family' THEN
    RETURN v_user_role IN ('owner', 'admin');
  END IF;
  
  RETURN true;
END;
$$;

CREATE OR REPLACE FUNCTION public.verify_task_transaction(
  p_request_id TEXT,
  p_user_id UUID,
  p_task_id UUID,
  p_verified_by UUID,
  p_next_due_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_rows_affected INTEGER;
  v_start_time TIMESTAMPTZ := NOW();
  v_result JSONB;
  v_household_id UUID;
  v_can_verify BOOLEAN;
BEGIN
  SELECT household_id INTO v_household_id FROM tasks WHERE id = p_task_id;
  
  IF v_household_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Task not found');
  END IF;
  
  v_can_verify := can_verify_tasks(p_verified_by, v_household_id);
  
  IF NOT v_can_verify THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'No tienes permiso para verificar tareas en este hogar'
    );
  END IF;

  UPDATE public.tasks
  SET 
    status = 'verified',
    last_verified_by = p_verified_by,
    next_due_at = p_next_due_at,
    updated_at = NOW()
  WHERE id = p_task_id
  AND status IN ('pending_verification', 'in_review');

  GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

  IF v_rows_affected = 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Task already verified or not pending verification'
    );
  END IF;

  RETURN jsonb_build_object('success', true, 'message', 'Task verified');
END;
$$;
