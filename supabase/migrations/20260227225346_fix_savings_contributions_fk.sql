-- Reconstructed from remote migration history (version 20260227225346).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Drop the old FK to auth.users and point to public.users to enable joins
ALTER TABLE public.savings_contributions 
DROP CONSTRAINT IF EXISTS savings_contributions_user_id_fkey;

ALTER TABLE public.savings_contributions
ADD CONSTRAINT savings_contributions_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
;