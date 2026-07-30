-- Reconstructed from remote migration history (version 20260308165658).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.savings_contributions
DROP CONSTRAINT IF EXISTS savings_contributions_goal_id_fkey,
ADD CONSTRAINT savings_contributions_goal_id_fkey
  FOREIGN KEY (goal_id)
  REFERENCES public.savings_goals(id)
  ON DELETE CASCADE;
