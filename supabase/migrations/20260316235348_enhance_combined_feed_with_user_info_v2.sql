-- Reconstructed from remote migration history (version 20260316235348).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Drop first because return type changes
DROP FUNCTION IF EXISTS get_combined_feed(UUID, INTEGER, INTEGER);

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
    payer_full_name TEXT,
    payer_avatar_url TEXT,
    payer_email TEXT,
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
        u.full_name as payer_full_name,
        u.avatar_url as payer_avatar_url,
        u.email as payer_email,
        e.paid_at as date,
        'paid'::TEXT as status
    FROM public.expenses e
    LEFT JOIN public.users u ON u.id = e.paid_by
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
        u.full_name as payer_full_name,
        u.avatar_url as payer_avatar_url,
        u.email as payer_email,
        pe.due_date::TIMESTAMP WITH TIME ZONE as date,
        pe.status
    FROM public.planned_expenses pe
    LEFT JOIN public.users u ON u.id = pe.payer_default
    WHERE pe.household_id = p_household_id AND pe.status != 'paid'

    ORDER BY date DESC, id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;
;