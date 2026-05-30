-- Reconstructed from remote migration history (version 20260313141731).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

DROP INDEX IF EXISTS tasks_unique_per_household;
-- Create a more relaxed index that allows multiple tasks with same name if they are different occurrences.
-- Or just don't have a unique index on title at all, which is more standard for tasks.
-- If the user wants to avoid duplicates, the UI should handle it.
-- But for now, let's just make it NOT unique or unique including ID (which makes it not unique).
-- Let's just create a regular index for performance.
CREATE INDEX idx_tasks_title_category_household ON public.tasks (title, category, household_id);
;