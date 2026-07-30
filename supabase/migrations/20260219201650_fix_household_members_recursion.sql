-- Reconstructed from remote migration history (version 20260219201650).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

DROP POLICY IF EXISTS "Users can view household members" ON public.household_members;

CREATE POLICY "Users can view household members"
ON public.household_members FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM household_members hm
    WHERE hm.household_id = household_members.household_id
    AND hm.user_id = auth.uid()
  )
);
