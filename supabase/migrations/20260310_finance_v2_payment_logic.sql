-- PHASE 4: PAYMENT CONFIRMATION LOGIC

CREATE OR REPLACE FUNCTION pay_planned_expense(
    p_planned_id UUID,
    p_amount DECIMAL,
    p_paid_at TIMESTAMP WITH TIME ZONE,
    p_paid_by UUID
)
RETURNS UUID AS $$
DECLARE
    v_expense_id UUID;
    v_household_id UUID;
    v_title TEXT;
    v_category TEXT;
    v_split_type TEXT;
    v_template_id UUID;
BEGIN
    -- 1. Fetch planned expense details
    SELECT household_id, title, category, split_type, template_id
    INTO v_household_id, v_title, v_category, v_split_type, v_template_id
    FROM planned_expenses
    WHERE id = p_planned_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Planned expense not found';
    END IF;

    -- 2. Create the real expense
    INSERT INTO expenses (
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

    -- 3. Mark planned expense as paid
    UPDATE planned_expenses
    SET status = 'paid'
    WHERE id = p_planned_id;

    -- 4. Automatically generate splits if it was "equal"
    IF v_split_type = 'equal' THEN
        INSERT INTO expense_splits (expense_id, user_id, amount)
        SELECT 
            v_expense_id,
            profiles.id,
            p_amount / (SELECT count(*) FROM household_members WHERE household_id = v_household_id)
        FROM household_members
        JOIN profiles ON profiles.id = household_members.user_id
        WHERE household_members.household_id = v_household_id;
    ELSIF v_split_type = 'personal' THEN
        INSERT INTO expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, p_paid_by, p_amount);
    END IF;

    RETURN v_expense_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
