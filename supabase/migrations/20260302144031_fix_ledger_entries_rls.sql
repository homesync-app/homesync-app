-- Reconstructed from remote migration history (version 20260302144031).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Allow authenticated users to insert ledger entries (for weekly winner bonus)
CREATE POLICY "Users can insert own ledger" ON public.ledger_entries
  FOR INSERT
  WITH CHECK (
    user_id IN (
      SELECT user_id FROM public.household_members WHERE household_id = ledger_entries.household_id
    )
  );

-- Allow users to update their own ledger entries
CREATE POLICY "Users can update own ledger" ON public.ledger_entries
  FOR UPDATE
  USING (
    user_id IN (
      SELECT user_id FROM public.household_members WHERE household_id = ledger_entries.household_id
    )
  )
  WITH CHECK (
    user_id IN (
      SELECT user_id FROM public.household_members WHERE household_id = ledger_entries.household_id
    )
  );

-- Allow household members to view all ledger entries in their household
CREATE POLICY "Household members can view all ledger" ON public.ledger_entries
  FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.household_members WHERE user_id = auth.uid()
    )
  );
