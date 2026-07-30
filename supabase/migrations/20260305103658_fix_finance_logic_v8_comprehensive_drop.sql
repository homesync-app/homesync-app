-- Reconstructed from remote migration history (version 20260305103658).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- REPARACIâ”œÃ´N COMPLETA DE FINANZAS
-- Limpieza total de funciones previas para asegurar la nueva arquitectura simâ”œÂ®trica

-- 0. Dropear funciones previas
DROP FUNCTION IF EXISTS public.save_expense_v4(uuid,uuid,text,numeric,text,uuid,timestamptz,text,text,boolean,text,jsonb);
DROP FUNCTION IF EXISTS public.save_expense_v4(uuid,uuid,text,decimal,text,uuid,timestamptz,text,text,boolean,text,jsonb);
DROP FUNCTION IF EXISTS public.get_expense_balance(uuid);
DROP FUNCTION IF EXISTS public.get_personal_finance_summary(uuid,uuid);
DROP FUNCTION IF EXISTS public.settle_debt(uuid,uuid,uuid,numeric);
DROP FUNCTION IF EXISTS public.settle_debt(uuid,uuid,uuid,decimal);

-- 1. Asegurar esquema de columnas
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS is_shared BOOLEAN DEFAULT TRUE;
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'expense';
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS split_type TEXT DEFAULT 'equal';

-- 2. FUNCIâ”œÃ´N: save_expense_v4
CREATE OR REPLACE FUNCTION public.save_expense_v4(
  p_id UUID,
  p_household_id UUID,
  p_title TEXT,
  p_amount DECIMAL,
  p_category TEXT,
  p_paid_by UUID,
  p_paid_at TIMESTAMPTZ,
  p_description TEXT,
  p_split_type TEXT,
  p_is_shared BOOLEAN,
  p_type TEXT,
  p_splits JSONB
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expense_id UUID;
  v_split RECORD;
BEGIN
  IF p_id IS NOT NULL THEN
    UPDATE public.expenses SET 
      title = p_title, amount = p_amount, category = p_category, paid_by = p_paid_by,
      paid_at = p_paid_at, description = p_description, split_type = p_split_type,
      is_shared = p_is_shared, type = p_type, updated_at = NOW()
    WHERE id = p_id;
    v_expense_id := p_id;
    DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
  ELSE
    INSERT INTO public.expenses (
      household_id, created_by_id, title, amount, category, paid_by, paid_at, description, split_type, is_shared, type
    ) VALUES (
      p_household_id, auth.uid(), p_title, p_amount, p_category, p_paid_by, p_paid_at, p_description, p_split_type, p_is_shared, p_type
    ) RETURNING id INTO v_expense_id;
  END IF;

  IF p_splits IS NOT NULL AND jsonb_array_length(p_splits) > 0 THEN
    FOR v_split IN SELECT * FROM jsonb_to_recordset(p_splits) AS x(user_id UUID, amount DECIMAL)
    LOOP
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, v_split.user_id, v_split.amount);
    END LOOP;
  ELSE
    IF NOT p_is_shared OR p_split_type = 'personal' THEN
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, p_paid_by, p_amount);
    ELSE
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT v_expense_id, user_id, p_amount / NULLIF((SELECT count(*)::decimal FROM public.household_members WHERE household_id = p_household_id), 0)
      FROM public.household_members WHERE household_id = p_household_id;
    END IF;
  END IF;

  RETURN v_expense_id;
END;
$$;

-- 3. FUNCIâ”œÃ´N: get_expense_balance (Simetrâ”œÂ¡a Total)
CREATE OR REPLACE FUNCTION public.get_expense_balance(p_household_id UUID)
RETURNS TABLE (
  user_id UUID,
  user_email TEXT,
  user_full_name TEXT,
  total_paid DECIMAL,
  total_owed DECIMAL,
  balance DECIMAL,
  avatar_url TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  WITH payments AS (
    SELECT e.paid_by as payer_id, SUM(e.amount) as total_contribution
    FROM public.expenses e
    WHERE e.household_id = p_household_id AND e.is_shared = true AND e.type = 'expense'
    GROUP BY e.paid_by
  ),
  owes AS (
    SELECT es.user_id as debtor_id, SUM(es.amount) as total_debt
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id AND e.is_shared = true AND e.type = 'expense'
    GROUP BY es.user_id
  ),
  settles_p AS (
    SELECT e.paid_by as s_id, SUM(e.amount) as s_amt FROM public.expenses e 
    WHERE e.household_id = p_household_id AND e.type = 'settlement' GROUP BY e.paid_by
  ),
  settles_r AS (
    SELECT es.user_id as r_id, SUM(es.amount) as r_amt FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id AND e.type = 'settlement' GROUP BY es.user_id
  )
  SELECT 
    u.id, u.email, u.full_name,
    COALESCE(p.total_contribution, 0)::DECIMAL as total_paid,
    COALESCE(o.total_debt, 0)::DECIMAL as total_owed,
    (COALESCE(p.total_contribution, 0) - COALESCE(o.total_debt, 0) + COALESCE(sp.s_amt, 0) - COALESCE(sr.r_amt, 0))::DECIMAL as balance,
    u.avatar_url
  FROM public.users u
  JOIN public.household_members hm ON hm.user_id = u.id
  LEFT JOIN payments p ON p.payer_id = u.id
  LEFT JOIN owes o ON o.debtor_id = u.id
  LEFT JOIN settles_p sp ON sp.s_id = u.id
  LEFT JOIN settles_r sr ON sr.r_id = u.id
  WHERE hm.household_id = p_household_id;
END;
$$;

-- 4. FUNCIâ”œÃ´N: get_personal_finance_summary
CREATE OR REPLACE FUNCTION public.get_personal_finance_summary(p_user_id UUID, p_household_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_income DECIMAL; v_expense DECIMAL; v_house_bal DECIMAL;
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO v_income FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id AND type = 'income' AND date_trunc('month', paid_at) = date_trunc('month', NOW());
  
  SELECT COALESCE(SUM(amount), 0) INTO v_expense FROM public.expenses
  WHERE paid_by = p_user_id AND household_id = p_household_id AND type = 'expense' AND date_trunc('month', paid_at) = date_trunc('month', NOW());

  SELECT balance INTO v_house_bal FROM public.get_expense_balance(p_household_id) WHERE user_id = p_user_id;

  RETURN jsonb_build_object('total_balance', v_income - v_expense, 'month_income', v_income, 'month_expense', v_expense, 'household_balance', v_house_bal, 'variation_pct', 0);
END;
$$;

-- 5. FUNCIâ”œÃ´N: settle_debt
CREATE OR REPLACE FUNCTION public.settle_debt(
  p_user_id UUID,
  p_household_id UUID,
  p_to_user_id UUID,
  p_amount DECIMAL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expense_id UUID;
BEGIN
  INSERT INTO public.expenses (
    household_id, created_by_id, title, amount, category, 
    paid_by, paid_at, description, type, is_shared
  ) VALUES (
    p_household_id, p_user_id, 'Liquidaciâ”œâ”‚n de pareja', p_amount, 'other', 
    p_user_id, NOW(), 'Saldado de balance', 'settlement', true
  ) RETURNING id INTO v_expense_id;

  INSERT INTO public.expense_splits (expense_id, user_id, amount)
  VALUES (v_expense_id, p_to_user_id, p_amount);

  RETURN v_expense_id;
END;
$$;

-- Permisos Finales
GRANT EXECUTE ON FUNCTION public.save_expense_v4 TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_expense_balance TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_personal_finance_summary TO authenticated;
GRANT EXECUTE ON FUNCTION public.settle_debt TO authenticated;
;