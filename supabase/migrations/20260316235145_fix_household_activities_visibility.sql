-- Reconstructed from remote migration history (version 20260316235145).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Update RLS for household_activities to include gifts
DROP POLICY IF EXISTS "users_view_household_activities" ON public.household_activities;
CREATE POLICY "users_view_household_activities" ON public.household_activities
    FOR SELECT USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
        AND (
            is_shared = true 
            OR user_id = auth.uid()
            OR metadata->>'split_type' = 'gift'
            OR metadata->>'split_type' = 'regalo'
        )
    );

-- Also ensure the get_combined_feed RPC is up to date (though it already seems correct from my query)
-- But let's re-run it just in case to be absolutely sure.
CREATE OR REPLACE FUNCTION get_combined_feed(
    p_household_id UUID,
    p_limit INTEGER DEFAULT 30,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    record_type TEXT,
    id UUID,
    title TEXT,
    amount NUMERIC,
    category TEXT,
    split_type TEXT,
    payer_id UUID,
    date TIMESTAMP WITH TIME ZONE,
    status TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    -- Real Expenses: Shared OR Gift
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
    AND (e.is_shared = true OR e.split_type = 'gift')

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
    WHERE pe.household_id = p_household_id AND pe.status != 'paid'

    ORDER BY date DESC, id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;
;