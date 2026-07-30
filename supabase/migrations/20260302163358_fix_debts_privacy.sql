-- Reconstructed from remote migration history (version 20260302163358).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

DROP FUNCTION IF EXISTS public.get_debts(UUID);

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
      SELECT paid_by, SUM(e.amount) as total_paid
      FROM public.expenses e WHERE e.household_id = p_household_id AND e.is_shared = true
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
    SELECT b.user_id, b.user_email, b.balance FROM balances b WHERE b.balance < -0.01
  ),
  creditors AS (
    SELECT b.user_id, b.user_email, b.balance FROM balances b WHERE b.balance > 0.01
  )
  SELECT 
    d.user_id as debtor_id,
    d.user_email as debtor_email,
    c.user_id as creditor_id,
    c.user_email as creditor_email,
    LEAST(ABS(d.balance), c.balance)::DECIMAL as amount
  FROM debtors d
  CROSS JOIN creditors c
  WHERE ABS(d.balance) > 0.01 AND c.balance > 0.01
  ORDER BY amount DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_debts(UUID) TO authenticated;
;