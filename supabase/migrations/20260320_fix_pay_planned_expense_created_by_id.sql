-- Fix pay_planned_expense to satisfy NOT NULL created_by_id on expenses

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
    v_created_by UUID;
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

    -- Prefer authenticated actor as creator, fallback to payer.
    v_created_by := COALESCE(auth.uid(), p_paid_by);

    INSERT INTO public.expenses (
        household_id,
        created_by_id,
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
        v_created_by,
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
