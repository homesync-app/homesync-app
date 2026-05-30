-- Reconstructed from remote migration history (version 20260316233808).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Update get_combined_feed to include gifts for non-payers
CREATE OR REPLACE FUNCTION public.get_combined_feed(
    p_household_id UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    record_type TEXT,
    id UUID,
    title TEXT,
    amount DECIMAL,
    category TEXT,
    split_type TEXT,
    payer_id UUID,
    date TIMESTAMP WITH TIME ZONE,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Real Expenses
    SELECT 
        'expense'::TEXT as record_type,
        e.id,
        e.title,
        e.amount,
        e.category,
        e.split_type,
        e.paid_by as payer_id,
        e.paid_at as date,
        'paid'::TEXT as status
    FROM public.expenses e
    WHERE e.household_id = p_household_id 
      AND (e.type = 'expense' OR e.type = 'settlement')
      -- Fix: Include gifts (split_type = 'gift') for everyone, even if is_shared is false
      AND (e.is_shared = true OR e.split_type = 'gift' OR e.paid_by = auth.uid())

    UNION ALL

    -- Planned Expenses (Pending or Skipped)
    SELECT 
        'planned'::TEXT as record_type,
        pe.id,
        pe.title,
        pe.amount,
        pe.category,
        pe.split_type,
        pe.payer_default as payer_id,
        pe.due_date::TIMESTAMP WITH TIME ZONE as date,
        pe.status
    FROM public.planned_expenses pe
    WHERE pe.household_id = p_household_id 
      AND pe.status != 'paid'
      AND (pe.split_type != 'personal' OR pe.payer_default = auth.uid())

    ORDER BY date DESC, id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Update get_filtered_expenses to include gifts in 'shared'
CREATE OR REPLACE FUNCTION public.get_filtered_expenses(
    p_household_id UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0,
    p_sharing TEXT DEFAULT 'all'
)
RETURNS SETOF public.expenses AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND (
          p_sharing = 'all' OR 
          (p_sharing = 'shared' AND (e.is_shared = true OR e.split_type = 'gift')) OR
          (p_sharing = 'mine' AND e.is_shared = false AND e.split_type != 'gift' AND e.paid_by = auth.uid())
      )
    ORDER BY e.paid_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Add trigger to clean up household_activities when an expense is deleted
CREATE OR REPLACE FUNCTION public.trg_on_expense_delete_cleanup()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.household_activities
    WHERE metadata->>'expense_id' = OLD.id::TEXT;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_expense_delete ON public.expenses;
CREATE TRIGGER on_expense_delete
    AFTER DELETE ON public.expenses
    FOR EACH ROW
    EXECUTE FUNCTION trg_on_expense_delete_cleanup();

-- 4. Clean up existing orphaned activities (where expense no longer exists)
DELETE FROM public.household_activities
WHERE event_type = 'expense_added'
  AND metadata->>'expense_id' IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM public.expenses e 
    WHERE e.id::TEXT = metadata->>'expense_id'
  );

-- 5. Fix RLS policy for deletion (allow creators to delete their own expenses)
-- If the policy exists with quotes or without, we try both or just name it.
DO $$
BEGIN
    DROP POLICY IF EXISTS "Owners can delete expenses" ON public.expenses;
    DROP POLICY IF EXISTS Owners_can_delete_expenses ON public.expenses;
EXCEPTION
    WHEN others THEN NULL;
END $$;

CREATE POLICY "Owners and creators can delete expenses"
  ON public.expenses FOR DELETE
  USING (
    household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
    OR created_by_id = auth.uid()
  );
;