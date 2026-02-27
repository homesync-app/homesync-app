-- ============================================
-- EXPENSE MANAGEMENT SYSTEM
-- ============================================

-- Add expense categories
CREATE TABLE IF NOT EXISTS public.expense_categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT DEFAULT '#6B7280'
);

INSERT INTO public.expense_categories (id, name, icon, color) VALUES
  ('groceries', 'Supermercado', '🛒', '#10B981'),
  ('utilities', 'Servicios', '💡', '#F59E0B'),
  ('rent', 'Alquiler', '🏠', '#3B82F6'),
  ('dining', 'Restaurantes', '🍽️', '#EC4899'),
  ('transport', 'Transporte', '🚗', '#8B5CF6'),
  ('entertainment', 'Entretenimiento', '🎬', '#06B6D4'),
  ('health', 'Salud', '💊', '#EF4444'),
  ('other', 'Otros', '📦', '#6B7280')
ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Expense categories readable by all"
  ON public.expense_categories FOR SELECT
  TO authenticated
  USING (true);

-- ============================================
-- RPC: CREATE EXPENSE WITH AUTO SPLIT
-- ============================================

CREATE OR REPLACE FUNCTION public.create_expense(
  p_user_id UUID,
  p_household_id UUID,
  p_title TEXT,
  p_amount DECIMAL,
  p_paid_by UUID,
  p_category TEXT DEFAULT 'other',
  p_description TEXT DEFAULT NULL,
  p_currency TEXT DEFAULT 'EUR',
  p_split_type TEXT DEFAULT 'equal',
  p_split_user_ids UUID[] DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expense_id UUID;
  v_split_count INTEGER;
  v_split_amount DECIMAL;
  v_member_ids UUID[];
  v_member_id UUID;
BEGIN
  -- Create expense
  INSERT INTO public.expenses (
    id,
    household_id,
    created_by_id,
    title,
    description,
    category,
    amount,
    currency,
    paid_by,
    paid_at
  ) VALUES (
    gen_random_uuid(),
    p_household_id,
    p_user_id,
    p_title,
    p_description,
    p_category,
    p_amount,
    p_currency,
    p_paid_by,
    NOW()
  )
  RETURNING id INTO v_expense_id;

  -- Get members to split
  IF p_split_user_ids IS NOT NULL THEN
    v_member_ids := p_split_user_ids;
  ELSE
    SELECT array_agg(user_id) INTO v_member_ids
    FROM public.household_members
    WHERE household_id = p_household_id;
  END IF;

  -- Calculate and create splits
  v_split_count := array_length(v_member_ids, 1);
  v_split_amount := p_amount / v_split_count;

  FOREACH v_member_id IN ARRAY v_member_ids
  LOOP
    INSERT INTO public.expense_splits (
      id,
      expense_id,
      user_id,
      amount
    ) VALUES (
      gen_random_uuid(),
      v_expense_id,
      v_member_id,
      v_split_amount
    );
  END LOOP;

  RETURN v_expense_id;
END;
$$;

-- ============================================
-- RPC: GET EXPENSE BALANCE (Fixed version)
-- ============================================

CREATE OR REPLACE FUNCTION public.get_expense_balance(
  p_household_id UUID
)
RETURNS TABLE (
  user_id UUID,
  user_email TEXT,
  total_paid DECIMAL,
  total_owed DECIMAL,
  balance DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH payments AS (
    SELECT e.paid_by as payer_id, SUM(e.amount) as total_paid
    FROM public.expenses e
    WHERE e.household_id = p_household_id
    GROUP BY e.paid_by
  ),
  owes AS (
    SELECT es.user_id as debtor_id, SUM(es.amount) as total_owed
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
    GROUP BY es.user_id
  )
  SELECT 
    u.id,
    u.email,
    COALESCE(p.total_paid, 0),
    COALESCE(o.total_owed, 0),
    COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0)
  FROM public.users u
  LEFT JOIN payments p ON p.payer_id = u.id
  LEFT JOIN owes o ON o.debtor_id = u.id
  WHERE u.id IN (
    SELECT hm.user_id FROM public.household_members hm WHERE hm.household_id = p_household_id
  )
  ORDER BY (COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0)) DESC;
END;
$$;

-- ============================================
-- RPC: GET DEBTS BETWEEN USERS (Fixed version)
-- ============================================

DROP FUNCTION IF EXISTS public.get_debts(UUID);

CREATE OR REPLACE FUNCTION public.get_debts(
  p_household_id UUID
)
RETURNS TABLE (
  debtor_id UUID,
  debtor_email TEXT,
  creditor_id UUID,
  creditor_email TEXT,
  debt_amount DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH balances AS (
    SELECT 
      u.id as uid,
      u.email as uemail,
      COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0) as bal
    FROM public.users u
    LEFT JOIN (
      SELECT paid_by, SUM(amount) as total_paid
      FROM public.expenses WHERE household_id = p_household_id
      GROUP BY paid_by
    ) p ON p.paid_by = u.id
    LEFT JOIN (
      SELECT es.user_id, SUM(es.amount) as total_owed
      FROM public.expense_splits es
      JOIN public.expenses e ON e.id = es.expense_id
      WHERE e.household_id = p_household_id
      GROUP BY es.user_id
    ) o ON o.user_id = u.id
    WHERE u.id IN (
      SELECT hm.user_id FROM public.household_members hm WHERE hm.household_id = p_household_id
    )
  ),
  debtors AS (
    SELECT uid, uemail, bal FROM balances WHERE bal < 0
  ),
  creditors AS (
    SELECT uid, uemail, bal FROM balances WHERE bal > 0
  )
  SELECT 
    d.uid,
    d.uemail,
    c.uid,
    c.uemail,
    LEAST(ABS(d.bal), c.bal)
  FROM debtors d
  CROSS JOIN creditors c
  WHERE ABS(d.bal) > 0.01 AND c.bal > 0.01
  ORDER BY LEAST(ABS(d.bal), c.bal) DESC;
END;
$$;

-- ============================================
-- RPC: GET DEBTS BETWEEN USERS
-- ============================================

CREATE OR REPLACE FUNCTION public.get_debts(
  p_household_id UUID
)
RETURNS TABLE (
  debtor_id UUID,
  debtor_email TEXT,
  creditor_id UUID,
  creditor_email TEXT,
  amount DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH balances AS (
    SELECT 
      u.id as user_id,
      u.email as user_email,
      COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0) as balance
    FROM public.users u
    LEFT JOIN (
      SELECT paid_by, SUM(amount) as total_paid
      FROM public.expenses WHERE household_id = p_household_id
      GROUP BY paid_by
    ) p ON p.paid_by = u.id
    LEFT JOIN (
      SELECT es.user_id, SUM(es.amount) as total_owed
      FROM public.expense_splits es
      JOIN public.expenses e ON e.id = es.expense_id
      WHERE e.household_id = p_household_id
      GROUP BY es.user_id
    ) o ON o.user_id = u.id
    WHERE u.id IN (
      SELECT user_id FROM public.household_members WHERE household_id = p_household_id
    )
  ),
  debtors AS (
    SELECT user_id, user_email, balance FROM balances WHERE balance < 0
  ),
  creditors AS (
    SELECT user_id, user_email, balance FROM balances WHERE balance > 0
  )
  SELECT 
    d.user_id as debtor_id,
    d.user_email as debtor_email,
    c.user_id as creditor_id,
    c.user_email as creditor_email,
    LEAST(ABS(d.balance), c.balance) as amount
  FROM debtors d
  CROSS JOIN creditors c
  WHERE ABS(d.balance) > 0.01 AND c.balance > 0.01
  ORDER BY amount DESC;
END;
$$;

-- ============================================
-- RPC: GET EXPENSE HISTORY
-- ============================================

CREATE OR REPLACE FUNCTION public.get_expense_history(
  p_household_id UUID,
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  amount DECIMAL,
  currency TEXT,
  category TEXT,
  paid_by_email TEXT,
  created_at TIMESTAMPTZ,
  split_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.id,
    e.title,
    e.amount,
    e.currency,
    e.category,
    u.email as paid_by_email,
    e.created_at,
    (SELECT COUNT(*) FROM public.expense_splits WHERE expense_id = e.id) as split_count
  FROM public.expenses e
  JOIN public.users u ON u.id = e.paid_by
  WHERE e.household_id = p_household_id
  ORDER BY e.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- ============================================
-- RPC: SETTLE DEBT (Fixed version)
-- ============================================

DROP FUNCTION IF EXISTS public.settle_debt(UUID, UUID, UUID, DECIMAL);

CREATE OR REPLACE FUNCTION public.settle_debt(
  p_user_id UUID,         -- Debtor (who pays)
  p_household_id UUID,
  p_to_user_id UUID,      -- Creditor (who receives)
  p_amount DECIMAL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expense_id UUID;
BEGIN
  -- Debtor pays the amount
  INSERT INTO public.expenses (
    id, household_id, created_by_id, title, description,
    category, amount, currency, paid_by, paid_at
  ) VALUES (
    gen_random_uuid(), p_household_id, p_user_id,
    'Liquidacion de deuda', 'Pago de deuda',
    'other', p_amount, 'EUR', p_user_id, NOW()
  )
  RETURNING id INTO v_expense_id;

  -- Split: only creditor owes this (receives the payment)
  INSERT INTO public.expense_splits (id, expense_id, user_id, amount)
  VALUES (gen_random_uuid(), v_expense_id, p_to_user_id, p_amount);

  RETURN v_expense_id;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.create_expense(UUID, UUID, TEXT, DECIMAL, UUID, TEXT, TEXT, TEXT, TEXT, UUID[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_expense_balance(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_debts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_expense_history(UUID, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.settle_debt(UUID, UUID, UUID, DECIMAL) TO authenticated;
