-- Reconstructed from remote migration history (version 20260323221524).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.household_members ADD COLUMN IF NOT EXISTS display_role text;
COMMENT ON COLUMN public.household_members.display_role IS 'Custom label for the member in the household (e.g. Padre, Madre, Hijo, etc)';
