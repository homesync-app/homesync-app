-- Reconstructed from remote migration history (version 20260226024942).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Enhance rewards table to support suggestions
ALTER TABLE public.rewards ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES public.users(id);
ALTER TABLE public.rewards ADD COLUMN IF NOT EXISTS is_approved boolean DEFAULT true;
ALTER TABLE public.rewards ADD COLUMN IF NOT EXISTS suggested_to uuid REFERENCES public.users(id);

-- Update RLS for rewards if needed (assuming public.rewards already has RLS)
-- We'll ensure users can see all rewards in their household, including pending ones they created.

-- Add a comment to explain the new flow
COMMENT ON COLUMN public.rewards.is_approved IS 'false if it is a suggestion that needs approval from the partner';
;