-- Reconstructed from remote migration history (version 20260313120455).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Add created_by_id to tasks and setup for approval logic
BEGIN;

-- 1. Add created_by_id column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tasks' AND column_name = 'created_by_id') THEN
        ALTER TABLE public.tasks ADD COLUMN created_by_id UUID REFERENCES public.users(id);
    END IF;
END $$;

COMMIT;
