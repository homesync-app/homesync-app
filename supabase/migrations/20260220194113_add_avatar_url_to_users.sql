-- Reconstructed from remote migration history (version 20260220194113).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Add avatar_url column to users table (this is what's causing all 400 errors)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS avatar_url text;
;