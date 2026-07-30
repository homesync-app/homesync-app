-- Reconstructed from remote migration history (version 20260308131811).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.get_personal_finance_summary(p_user_id uuid, p_household_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_ledger_balance DECIMAL := 0;
    v_total_income DECIMAL := 0;
    v_total_expenses DECIMAL := 0;
    v_monthly_variation DECIMAL := 0;
    v_received_settlements DECIMAL := 0;
    v_paid_settlements DECIMAL := 0;
BEGIN
    -- 1. Balance from ledger (Rewards, adjustments)
    SELECT COALESCE(SUM(amount), 0) INTO v_ledger_balance
    FROM public.ledger_entries
    WHERE user_id = p_user_id 
      AND household_id = p_household_id 
      AND (currency IS NULL OR (currency <> 'XP' AND currency <> 'COIN'));

    -- 2. Total Income recorded by the user (regular income)
    SELECT COALESCE(SUM(amount), 0) INTO v_total_income
    FROM public.expenses
    WHERE paid_by = p_user_id 
      AND household_id = p_household_id 
      AND type = 'income';

    -- 3. Total Expenses paid by the user (regular expenses)
    SELECT COALESCE(SUM(amount), 0) INTO v_total_expenses
    FROM public.expenses
    WHERE paid_by = p_user_id 
      AND household_id = p_household_id 
      AND type = 'expense';

    -- 4. Paid Settlements (Money paid to partner)
    SELECT COALESCE(SUM(amount), 0) INTO v_paid_settlements
    FROM public.expenses
    WHERE paid_by = p_user_id 
      AND household_id = p_household_id 
      AND type = 'settlement';

    -- 5. Received Settlements (Money received from partner)
    SELECT COALESCE(SUM(es.amount), 0) INTO v_received_settlements
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE es.user_id = p_user_id 
      AND e.type = 'settlement';

    RETURN jsonb_build_object(
        'balance', v_ledger_balance + v_total_income + v_received_settlements - v_total_expenses - v_paid_settlements,
        'income', v_total_income + v_received_settlements,
        'expense', v_total_expenses + v_paid_settlements,
        'variation', 5.0
    );
END;
$function$;
