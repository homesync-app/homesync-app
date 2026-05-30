-- Reconstructed from remote migration history (version 20260221114912).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.expenses ADD COLUMN split_type text DEFAULT 'equal';
