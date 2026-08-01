-- Reconstructed from remote migration history (version 20260313152825).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Restore unique constraint for tasks that are currently active or pending
-- This prevents duplicates from being added while a version of the task is still outstanding.
-- It allows recreating the task once it's been 'verified' (fully completed).

DROP INDEX IF EXISTS idx_tasks_title_category_household;

CREATE UNIQUE INDEX tasks_unique_active_per_household ON public.tasks (
  lower(TRIM(BOTH FROM title)), 
  COALESCE(category, 'general'::text), 
  household_id
) 
WHERE (status IN ('active', 'pending_approval', 'pending_verification', 'assigned', 'objected'));

-- Keep a non-unique index for performance on general queries if needed
CREATE INDEX idx_tasks_household_lookup ON public.tasks (household_id, created_at DESC);
;