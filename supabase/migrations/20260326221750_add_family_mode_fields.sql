-- Reconstructed from remote migration history (version 20260326221750).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.rewards ADD COLUMN IF NOT EXISTS target_type TEXT DEFAULT 'all' CHECK (target_type IN ('adult', 'child', 'all'));

ALTER TABLE public.household_members ADD COLUMN IF NOT EXISTS member_type TEXT DEFAULT 'adult' CHECK (member_type IN ('adult', 'child'));

-- Update existing child members if possible based on display_role (heuristic)
UPDATE public.household_members 
SET member_type = 'child' 
WHERE LOWER(display_role) IN ('hijo', 'hija', 'niâ”œâ–’o', 'niâ”œâ–’a', 'hije');
;