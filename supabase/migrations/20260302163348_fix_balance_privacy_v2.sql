-- Reconstructed from remote migration history (version 20260302163348).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

DROP FUNCTION IF EXISTS public.get_expense_balance(UUID);

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
    WHERE e.household_id = p_household_id AND e.is_shared = true
    GROUP BY e.paid_by
  ),
  owes AS (
    SELECT es.user_id as debtor_id, SUM(es.amount) as total_owed
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id AND e.is_shared = true
    GROUP BY es.user_id
  )
  SELECT 
    u.id,
    u.email,
    COALESCE(p.total_paid, 0)::DECIMAL,
    COALESCE(o.total_owed, 0)::DECIMAL,
    (COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0))::DECIMAL
  FROM public.users u
  LEFT JOIN payments p ON p.payer_id = u.id
  LEFT JOIN owes o ON o.debtor_id = u.id
  WHERE u.id IN (
    SELECT hm.user_id FROM public.household_members hm WHERE hm.household_id = p_household_id
  )
  ORDER BY (COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0)) DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_expense_balance(UUID) TO authenticated;
;