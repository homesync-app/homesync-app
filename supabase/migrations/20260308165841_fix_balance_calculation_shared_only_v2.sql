-- Reconstructed from remote migration history (version 20260308165841).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

DROP FUNCTION IF EXISTS public.get_expense_balance(UUID);
DROP FUNCTION IF EXISTS public.get_debts(UUID);

-- Re-create get_expense_balance
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
    AND e.is_shared = true
    GROUP BY e.paid_by
  ),
  owes AS (
    SELECT es.user_id as debtor_id, SUM(es.amount) as total_owed
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
    AND e.is_shared = true
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

-- Re-create get_debts
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
      FROM public.expenses WHERE household_id = p_household_id AND is_shared = true
      GROUP BY paid_by
    ) p ON p.paid_by = u.id
    LEFT JOIN (
      SELECT es.user_id, SUM(es.amount) as total_owed
      FROM public.expense_splits es
      JOIN public.expenses e ON e.id = es.expense_id
      WHERE e.household_id = p_household_id AND e.is_shared = true
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

GRANT EXECUTE ON FUNCTION public.get_expense_balance(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_debts(UUID) TO authenticated;
