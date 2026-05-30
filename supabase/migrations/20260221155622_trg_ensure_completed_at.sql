-- Reconstructed from remote migration history (version 20260221155622).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Asegurar que completed_at siempre estâ”œÂ® presente para el historial
CREATE OR REPLACE FUNCTION public.handle_task_history_timestamps()
RETURNS TRIGGER AS $$
BEGIN
  -- Si la tarea cambia a un estado de completado/verificado y no tiene completed_at
  IF NEW.status IN ('pending_verification', 'verified', 'objected') AND NEW.completed_at IS NULL THEN
    NEW.completed_at := NOW();
  END IF;

  -- Si se completâ”œâ”‚ pero no se sabe por quiâ”œÂ®n, intentar inferirlo
  IF NEW.status IN ('pending_verification', 'verified', 'objected') AND NEW.completed_by IS NULL THEN
    -- Si es pending_verification, probablemente la completâ”œâ”‚ el usuario actual
    IF auth.uid() IS NOT NULL THEN
      NEW.completed_by := auth.uid();
    -- Si no, usar el asignado como fallback
    ELSIF NEW.assigned_to IS NOT NULL THEN
      NEW.completed_by := NEW.assigned_to;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_task_history_timestamps ON public.tasks;
CREATE TRIGGER trg_task_history_timestamps
  BEFORE INSERT OR UPDATE ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_task_history_timestamps();
;