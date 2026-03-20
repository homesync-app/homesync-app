-- Finance hardening: align RPC contracts with app and return typed feed data

-- 1) Combined feed with stable transaction_type + payer metadata
DROP FUNCTION IF EXISTS public.get_combined_feed(UUID, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION public.get_combined_feed(
    p_household_id UUID,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    record_type TEXT,
    transaction_type TEXT,
    id UUID,
    title TEXT,
    amount NUMERIC,
    category TEXT,
    split_type TEXT,
    payer_id UUID,
    payer_email TEXT,
    payer_full_name TEXT,
    payer_avatar_url TEXT,
    date TIMESTAMPTZ,
    status TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        'expense'::TEXT AS record_type,
        e.type::TEXT AS transaction_type,
        e.id,
        e.title,
        e.amount,
        e.category,
        e.split_type,
        e.paid_by AS payer_id,
        u.email AS payer_email,
        u.full_name AS payer_full_name,
        u.avatar_url AS payer_avatar_url,
        e.paid_at AS date,
        'paid'::TEXT AS status
    FROM public.expenses e
    LEFT JOIN public.users u ON u.id = e.paid_by
    WHERE e.household_id = p_household_id
      AND e.type IN ('expense', 'income', 'settlement')

    UNION ALL

    SELECT
        'planned'::TEXT AS record_type,
        'expense'::TEXT AS transaction_type,
        pe.id,
        pe.title,
        pe.amount,
        pe.category,
        pe.split_type,
        pe.payer_default AS payer_id,
        u.email AS payer_email,
        u.full_name AS payer_full_name,
        u.avatar_url AS payer_avatar_url,
        pe.due_date::TIMESTAMPTZ AS date,
        pe.status
    FROM public.planned_expenses pe
    LEFT JOIN public.users u ON u.id = pe.payer_default
    WHERE pe.household_id = p_household_id
      AND pe.status != 'paid'

    ORDER BY date DESC, id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_combined_feed(UUID, INTEGER, INTEGER) TO authenticated;

-- 2) Planned expense payment with explicit JSON response contract
DROP FUNCTION IF EXISTS public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, UUID);
CREATE OR REPLACE FUNCTION public.pay_planned_expense(
    p_planned_id UUID,
    p_amount DECIMAL,
    p_paid_at TIMESTAMPTZ,
    p_paid_by UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_expense_id UUID;
    v_household_id UUID;
    v_title TEXT;
    v_category TEXT;
    v_split_type TEXT;
BEGIN
    SELECT household_id, title, category, split_type
    INTO v_household_id, v_title, v_category, v_split_type
    FROM public.planned_expenses
    WHERE id = p_planned_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Planned expense not found'
        );
    END IF;

    INSERT INTO public.expenses (
        household_id,
        title,
        amount,
        category,
        paid_by,
        paid_at,
        type,
        split_type,
        planned_expense_id
    ) VALUES (
        v_household_id,
        v_title,
        p_amount,
        v_category,
        p_paid_by,
        p_paid_at,
        'expense',
        v_split_type,
        p_planned_id
    ) RETURNING id INTO v_expense_id;

    UPDATE public.planned_expenses
    SET status = 'paid'
    WHERE id = p_planned_id;

    IF v_split_type = 'equal' THEN
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        SELECT
            v_expense_id,
            hm.user_id,
            p_amount / NULLIF((SELECT count(*)::DECIMAL FROM public.household_members WHERE household_id = v_household_id), 0)
        FROM public.household_members hm
        WHERE hm.household_id = v_household_id;
    ELSIF v_split_type = 'personal' THEN
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, p_paid_by, p_amount);
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'expense_id', v_expense_id,
        'message', 'Planned expense paid successfully'
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, UUID) TO authenticated;
