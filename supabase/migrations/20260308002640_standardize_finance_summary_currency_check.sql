-- Reconstructed from remote migration history (version 20260308002640).
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
BEGIN
    -- 1. Balance from ledger (Rewards, adjustments)
    -- We'll sum anything that isn't XP or COIN as money.
    SELECT COALESCE(SUM(amount), 0) INTO v_ledger_balance
    FROM public.ledger_entries
    WHERE user_id = p_user_id 
      AND household_id = p_household_id 
      AND (currency IS NULL OR (currency <> 'XP' AND currency <> 'COIN'));

    -- 2. Total Income recorded by the user
    SELECT COALESCE(SUM(amount), 0) INTO v_total_income
    FROM public.expenses
    WHERE paid_by = p_user_id 
      AND household_id = p_household_id 
      AND type = 'income';

    -- 3. Total Expenses paid by the user
    SELECT COALESCE(SUM(amount), 0) INTO v_total_expenses
    FROM public.expenses
    WHERE paid_by = p_user_id 
      AND household_id = p_household_id 
      AND type = 'expense';

    -- 4. Variation calculation
    v_monthly_variation := 0;

    RETURN jsonb_build_object(
        'balance', v_ledger_balance + v_total_income - v_total_expenses,
        'income', v_total_income,
        'expense', v_total_expenses,
        'variation', 5.0
    );
END;
$function$;
