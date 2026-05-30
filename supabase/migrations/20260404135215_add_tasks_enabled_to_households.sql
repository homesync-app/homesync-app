-- Reconstructed from remote migration history (version 20260404135215).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.households
  ADD COLUMN IF NOT EXISTS tasks_enabled BOOLEAN NOT NULL DEFAULT true;
