-- Reconstructed from remote migration history (version 20260311150142).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Drop and recreate get_combined_feed to change return type
DROP FUNCTION IF EXISTS public.get_combined_feed(uuid, integer, integer);

CREATE OR REPLACE FUNCTION public.get_combined_feed(p_household_id UUID, p_limit INTEGER DEFAULT 20, p_offset INTEGER DEFAULT 0)
RETURNS TABLE (
    record_type TEXT,
    id UUID,
    title TEXT,
    amount NUMERIC,
    category TEXT,
    split_type TEXT,
    payer_id UUID,
    date TIMESTAMP WITH TIME ZONE,
    status TEXT,
    is_shared BOOLEAN
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
        'paid'::TEXT as status,
        e.is_shared
    FROM public.expenses e
    WHERE e.household_id = p_household_id 
      AND (e.type = 'expense' OR e.type = 'settlement')
      AND (e.is_shared = true OR e.paid_by = auth.uid()) -- PRIVATE logic

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
        pe.status,
        (pe.split_type != 'personal' AND pe.split_type != 'gift') as is_shared
    FROM public.planned_expenses pe
    WHERE pe.household_id = p_household_id AND pe.status != 'paid'
      AND (pe.split_type NOT IN ('personal', 'gift') OR pe.payer_default = auth.uid()) -- PRIVATE logic

    ORDER BY date DESC, id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update get_filtered_expenses (No return type change, just logic)
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
            jsonb_build_object('email', u.email, 'full_name', u.full_name, 'avatar_url', u.avatar_url) as payer,
            (
                SELECT jsonb_agg(s) 
                FROM (
                    SELECT s1.*, jsonb_build_object('full_name', u1.full_name, 'avatar_url', u1.avatar_url) as users
                    FROM public.expense_splits s1
                    JOIN public.users u1 ON u1.id = s1.user_id
                    WHERE s1.expense_id = e.id
                ) s
            ) as expense_splits
        FROM public.expenses e
        JOIN public.users u ON u.id = e.paid_by
        WHERE e.household_id = p_household_id
        AND (p_type = 'all' OR e.type::TEXT = p_type)
        AND (e.is_shared = true OR e.paid_by = auth.uid()) -- PRIVATE logic
        AND (
            p_sharing = 'all' OR 
            (p_sharing = 'shared' AND e.is_shared = true) OR
            (p_sharing = 'mine' AND e.is_shared = false)
        )
        ORDER BY e.paid_at DESC
        LIMIT p_limit
        OFFSET p_offset
    ) t;
    
    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;
;