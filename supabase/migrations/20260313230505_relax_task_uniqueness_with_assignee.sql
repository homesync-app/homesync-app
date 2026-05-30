-- Reconstructed from remote migration history (version 20260313230505).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Relax the unique constraint to allow the same task title for different users within the same household.
-- We use NULLS NOT DISTINCT (PG 15+) so that multiple unassigned tasks with the same title are still forbidden,
-- but a task can exist once for each specific user (or unassigned).

DROP INDEX IF EXISTS tasks_unique_active_per_household;

CREATE UNIQUE INDEX tasks_unique_active_per_household 
ON public.tasks (
    lower(TRIM(BOTH FROM title)), 
    COALESCE(category, 'general'::text), 
    household_id, 
    assigned_to
) 
NULLS NOT DISTINCT
WHERE (status = ANY (ARRAY['active'::text, 'pending_approval'::text, 'pending_verification'::text, 'assigned'::text, 'objected'::text]));
;