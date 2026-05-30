-- Reconstructed from remote migration history (version 20260306234403).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Refine Finance Logic V13 - Include Avatars
CREATE OR REPLACE FUNCTION public.get_expense_balance(p_household_id UUID)
RETURNS TABLE (
    user_id UUID,
    user_email TEXT,
    user_full_name TEXT,
    balance DECIMAL,
    avatar_url TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH members AS (
        SELECT u.id, u.email, u.full_name, u.avatar_url
        FROM public.users u
        JOIN public.household_members hm ON hm.user_id = u.id
        WHERE hm.household_id = p_household_id
    ),
    paid AS (
        SELECT e.paid_by, SUM(e.amount) as total
        FROM public.expenses e
        WHERE e.household_id = p_household_id AND e.is_shared = true
        GROUP BY e.paid_by
    ),
    owed AS (
        -- Sum of what each user should have paid for shared expenses
        SELECT es.user_id, SUM(es.amount) as total
        FROM public.expense_splits es
        JOIN public.expenses e ON e.id = es.expense_id
        WHERE e.household_id = p_household_id AND e.is_shared = true
        GROUP BY es.user_id
    )
    SELECT 
        m.id,
        m.email,
        m.full_name,
        COALESCE(p.total, 0) - COALESCE(o.total, 0) as balance,
        m.avatar_url
    FROM members m
    LEFT JOIN paid p ON p.paid_by = m.id
    LEFT JOIN owed o ON o.user_id = m.id;
END;
$$;
;