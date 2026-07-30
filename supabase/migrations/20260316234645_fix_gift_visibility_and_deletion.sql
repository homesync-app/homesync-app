-- Reconstructed from remote migration history (version 20260316234645).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Update save_expense_v4 or just the RLS logic? 
-- The user said "gift expenses should be seen by the other".
-- Currently save_expense_v4 sets is_shared = false for gifts.
-- Let's update get_combined_feed and get_filtered_expenses to include gifts explicitly when filtering by 'shared'.

-- 1. Correct Combined Feed to include status and potentially filter by visibility
CREATE OR REPLACE FUNCTION get_combined_feed(p_household_id UUID, p_limit INTEGER DEFAULT 20, p_offset INTEGER DEFAULT 0)
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
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Correct get_filtered_expenses to include gifts when p_sharing = 'shared'
CREATE OR REPLACE FUNCTION public.get_filtered_expenses(
    p_household_id UUID,
    p_type TEXT DEFAULT 'all',
    p_sharing TEXT DEFAULT 'all',
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_agg(t) INTO v_result
    FROM (
        SELECT 
            e.*,
            jsonb_build_object('email', u.email, 'full_name', u.full_name, 'avatar_url', u.avatar_url) as users,
            (
                SELECT jsonb_agg(s) 
                FROM (
                    SELECT s2.*, json_build_object('full_name', u2.full_name, 'avatar_url', u2.avatar_url) as users
                    FROM public.expense_splits s2
                    JOIN public.users u2 ON u2.id = s2.user_id
                    WHERE s2.expense_id = e.id
                ) s
            ) as expense_splits
        FROM public.expenses e
        JOIN public.users u ON u.id = e.paid_by
        WHERE e.household_id = p_household_id
        AND (p_type = 'all' OR e.type::TEXT = p_type)
        AND (
            p_sharing = 'all' OR 
            (p_sharing = 'shared' AND (e.is_shared = true OR e.split_type = 'gift')) OR
            (p_sharing = 'mine' AND e.is_shared = false AND e.split_type != 'gift')
        )
        ORDER BY e.paid_at DESC
        LIMIT p_limit
        OFFSET p_offset
    ) t;
    
    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- 3. Ensure RLS allows viewing gifts
DROP POLICY IF EXISTS "Household members can view shared expenses" ON public.expenses;
CREATE POLICY "Household members can view shared expenses" ON public.expenses
    FOR SELECT USING (
        is_shared = true 
        OR split_type = 'gift'
        OR auth.uid() = created_by_id 
        OR auth.uid() = paid_by
        OR auth.uid() IN (SELECT user_id FROM public.household_members WHERE household_id = expenses.household_id)
    );

-- 4. Fix delete trigger for activities to handle gift/personal properly
-- The trigger trg_on_expense_delete_cleanup was added earlier but let's re-verify it covers all cases.
-- It works on public.expenses AND deletes from household_activities where metadata->>'expense_id' matches.
;