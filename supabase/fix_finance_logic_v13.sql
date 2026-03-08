-- Definitive Finance Logic Fix V13
-- Focus: Symmetry, Gift handling, Personal expenses, and Auto-splitting.

-- 0. Ensure transaction_type enum exists
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transaction_type') THEN
        CREATE TYPE transaction_type AS ENUM ('expense', 'income', 'settlement');
    END IF;
END $$;

-- 1. Ensure columns exist on expenses table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'split_type') THEN
        ALTER TABLE public.expenses ADD COLUMN split_type TEXT DEFAULT 'equal';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'is_shared') THEN
        ALTER TABLE public.expenses ADD COLUMN is_shared BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'type') THEN
        ALTER TABLE public.expenses ADD COLUMN type transaction_type DEFAULT 'expense';
    END IF;
END $$;

-- 2. Robust Save Function
CREATE OR REPLACE FUNCTION public.save_expense_v4(
    p_id UUID DEFAULT NULL,
    p_household_id UUID DEFAULT NULL,
    p_title TEXT DEFAULT NULL,
    p_amount DECIMAL DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_paid_by UUID DEFAULT NULL,
    p_paid_at TIMESTAMPTZ DEFAULT NOW(),
    p_description TEXT DEFAULT NULL,
    p_split_type TEXT DEFAULT 'equal',
    p_is_shared BOOLEAN DEFAULT true,
    p_type TEXT DEFAULT 'expense',
    p_splits JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_expense_id UUID := p_id;
    v_is_shared BOOLEAN := p_is_shared;
    v_member_id UUID;
    v_member_count INT;
    v_household_id UUID := p_household_id;
BEGIN
    -- Infer household_id if not provided
    IF v_household_id IS NULL THEN
        SELECT household_id INTO v_household_id FROM public.household_members WHERE user_id = p_paid_by LIMIT 1;
    END IF;

    -- Logic for is_shared
    -- 'personal' and 'gift' are NOT shared in the sense that they don't create debt for the partner.
    IF p_split_type IN ('personal', 'gift') THEN
        v_is_shared := false;
    END IF;

    -- Upsert Expense
    IF v_expense_id IS NULL THEN
        INSERT INTO public.expenses (
            household_id, created_by_id, title, description, category, 
            amount, paid_by, paid_at, split_type, is_shared, type
        ) VALUES (
            v_household_id, p_paid_by, p_title, p_description, p_category, 
            p_amount, p_paid_by, p_paid_at, p_split_type, v_is_shared, p_type::transaction_type
        ) RETURNING id INTO v_expense_id;
    ELSE
        UPDATE public.expenses SET
            title = p_title,
            description = p_description,
            category = p_category,
            amount = p_amount,
            paid_by = p_paid_by,
            paid_at = p_paid_at,
            split_type = p_split_type,
            is_shared = v_is_shared,
            type = p_type::transaction_type,
            updated_at = NOW()
        WHERE id = v_expense_id;
        
        DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
    END IF;

    -- Handle Splits logic
    IF p_split_type = 'gift' THEN
        -- Gift: Payer pays everything. No one else owes him.
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, p_paid_by, p_amount);
        
    ELSIF p_split_type = 'personal' THEN
        -- Personal: Only for the payer.
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, p_paid_by, p_amount);
        
    ELSIF p_split_type = 'equal' AND (p_splits IS NULL OR jsonb_array_length(p_splits) <= 1) THEN
        -- Auto-split among all household members
        SELECT COUNT(*) INTO v_member_count FROM public.household_members WHERE household_id = v_household_id;
        FOR v_member_id IN SELECT user_id FROM public.household_members WHERE household_id = v_household_id LOOP
            INSERT INTO public.expense_splits (expense_id, user_id, amount)
            VALUES (v_expense_id, v_member_id, p_amount / NULLIF(v_member_count, 0));
        END LOOP;
        
    ELSIF p_splits IS NOT NULL THEN
        -- Use provided splits
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        SELECT v_expense_id, (s->>'user_id')::UUID, (s->>'amount')::DECIMAL
        FROM jsonb_array_elements(p_splits) AS s;
    END IF;

    RETURN v_expense_id;
END;
$$;

-- 3. Symmetric Balance Function
DROP FUNCTION IF EXISTS public.get_expense_balance(UUID);
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
        SELECT u.id, u.email, u.full_name
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
        NULL::TEXT as avatar_url -- Placeholder if not in schema
    FROM members m
    LEFT JOIN paid p ON p.paid_by = m.id
    LEFT JOIN owed o ON o.user_id = m.id;
END;
$$;

-- 4. Personal Finance Summary
CREATE OR REPLACE FUNCTION public.get_personal_finance_summary(p_user_id UUID, p_household_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_balance DECIMAL := 0;
    v_income DECIMAL := 0;
    v_expense DECIMAL := 0;
BEGIN
    SELECT balance INTO v_balance
    FROM public.get_expense_balance(p_household_id)
    WHERE user_id = p_user_id;

    SELECT 
        COALESCE(SUM(amount) FILTER (WHERE type = 'income'), 0),
        COALESCE(SUM(amount) FILTER (WHERE type = 'expense'), 0)
    INTO v_income, v_expense
    FROM public.expenses
    WHERE paid_by = p_user_id 
    AND household_id = p_household_id
    AND date_trunc('month', paid_at) = date_trunc('month', NOW());

    RETURN jsonb_build_object(
        'balance', COALESCE(v_balance, 0),
        'income', v_income,
        'expense', v_expense,
        'variation', 0.0
    );
END;
$$;

-- 5. Filtered Expenses RPC
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
            jsonb_build_object('email', u.email, 'full_name', u.full_name) as payer,
            (
                SELECT jsonb_agg(s) 
                FROM public.expense_splits s 
                WHERE s.expense_id = e.id
            ) as expense_splits
        FROM public.expenses e
        JOIN public.users u ON u.id = e.paid_by
        WHERE e.household_id = p_household_id
        AND (p_type = 'all' OR e.type::TEXT = p_type)
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

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.save_expense_v4(UUID, UUID, TEXT, DECIMAL, TEXT, UUID, TIMESTAMPTZ, TEXT, TEXT, BOOLEAN, TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_expense_balance(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_personal_finance_summary(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_filtered_expenses(UUID, TEXT, TEXT, INTEGER, INTEGER) TO authenticated;
