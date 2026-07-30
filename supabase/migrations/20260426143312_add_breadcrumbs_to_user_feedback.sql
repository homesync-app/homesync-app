-- Reconstructed from remote migration history (version 20260426143312).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.user_feedback
ADD COLUMN IF NOT EXISTS breadcrumbs jsonb DEFAULT '[]';
