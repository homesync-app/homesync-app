-- Reconstructed from remote migration history (version 20260302144110).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Allow authenticated users to insert weekly winners (for weekly winner function)
CREATE POLICY "Members can insert weekly winners" ON public.weekly_winners
  FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT household_id FROM public.household_members WHERE user_id = auth.uid()
    )
  );

-- Allow users to view all weekly winners in their household
DROP POLICY IF EXISTS "Members can view their household winners" ON public.weekly_winners;
CREATE POLICY "Members can view their household winners" ON public.weekly_winners
  FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.household_members WHERE user_id = auth.uid()
    )
  );
