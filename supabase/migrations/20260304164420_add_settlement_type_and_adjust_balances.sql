-- Reconstructed from remote migration history (version 20260304164420).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TYPE public.transaction_type ADD VALUE IF NOT EXISTS 'settlement';

CREATE OR REPLACE FUNCTION public.settle_debt(p_user_id uuid, p_household_id uuid, p_to_user_id uuid, p_amount numeric)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_expense_id UUID;
BEGIN
  -- Debtor pays the amount
  INSERT INTO public.expenses (
    id, household_id, created_by_id, title, description,
    category, amount, currency, paid_by, paid_at,
    is_shared, type, split_type
  ) VALUES (
    gen_random_uuid(), p_household_id, p_user_id,
    'Liquidaciâ”œâ”‚n de pareja', 'Ajuste de saldos',
    'other', p_amount, 'ARS', p_user_id, NOW(),
    true, 'settlement', 'gift'
  )
  RETURNING id INTO v_expense_id;

  -- Split: only creditor owes this (receives the payment)
  INSERT INTO public.expense_splits (id, expense_id, user_id, amount)
  VALUES (gen_random_uuid(), v_expense_id, p_to_user_id, p_amount);

  RETURN v_expense_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_personal_finance_summary(p_user_id uuid, p_household_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_current_month_start TIMESTAMPTZ := date_trunc('month', NOW());
  v_prev_month_start TIMESTAMPTZ := date_trunc('month', NOW() - INTERVAL '1 month');
  v_prev_month_end TIMESTAMPTZ := v_current_month_start - INTERVAL '1 second';
  
  v_total_income DECIMAL := 0;
  v_total_expense DECIMAL := 0;
  v_month_income DECIMAL := 0;
  v_month_expense DECIMAL := 0;
  v_prev_month_expense DECIMAL := 0;
  v_variation_pct DECIMAL := 0;

  -- Settlement variables
  v_settlement_paid DECIMAL := 0;
  v_settlement_received DECIMAL := 0;
BEGIN
  -- 1. All-time Income (Personal)
  SELECT COALESCE(SUM(amount), 0) INTO v_total_income
  FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id AND type = 'income';

  -- 2. All-time Expense (Personal)
  SELECT COALESCE(SUM(amount), 0) INTO v_total_expense
  FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id AND type = 'expense';

  -- 3. Current Month Income
  SELECT COALESCE(SUM(amount), 0) INTO v_month_income
  FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id 
    AND type = 'income' AND paid_at >= v_current_month_start;

  -- 4. Current Month Expense
  SELECT COALESCE(SUM(amount), 0) INTO v_month_expense
  FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id 
    AND type = 'expense' AND paid_at >= v_current_month_start;

  -- 5. Previous Month Expense (for variation)
  SELECT COALESCE(SUM(amount), 0) INTO v_prev_month_expense
  FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id 
    AND type = 'expense' AND paid_at >= v_prev_month_start AND paid_at <= v_prev_month_end;

  -- 6. Liquidations impact personal real balance
  SELECT COALESCE(SUM(amount), 0) INTO v_settlement_paid
  FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id AND type = 'settlement';

  SELECT COALESCE(SUM(es.amount), 0) INTO v_settlement_received
  FROM public.expense_splits es
  JOIN public.expenses e ON e.id = es.expense_id
  WHERE e.household_id = p_household_id AND e.type = 'settlement' AND es.user_id = p_user_id;

  -- Calculate Variation
  IF v_prev_month_expense > 0 THEN
    v_variation_pct := ((v_month_expense / v_prev_month_expense) - 1) * 100;
  ELSE
    v_variation_pct := 0;
  END IF;

  RETURN jsonb_build_object(
    'total_balance', (v_total_income - v_total_expense - v_settlement_paid + v_settlement_received),
    'month_income', v_month_income,
    'month_expense', v_month_expense,
    'variation_pct', v_variation_pct,
    'total_income', v_total_income,
    'total_expense', v_total_expense
  );
END;
$function$;
;