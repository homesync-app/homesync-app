-- Reconstructed from remote migration history (version 20260303002903).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

DROP FUNCTION IF EXISTS public.get_expense_balance(uuid);

CREATE OR REPLACE FUNCTION public.get_expense_balance(p_household_id uuid)
 RETURNS TABLE(user_id uuid, user_email text, user_full_name text, avatar_url text, total_paid numeric, total_owed numeric, balance numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  WITH payments AS (
    SELECT e.paid_by as payer_id, SUM(CASE WHEN e.type = 'income' THEN -e.amount ELSE e.amount END) as total_paid
    FROM public.expenses e
    WHERE e.household_id = p_household_id AND e.is_shared = true
    GROUP BY e.paid_by
  ),
  owes AS (
    SELECT es.user_id as debtor_id, SUM(CASE WHEN e.type = 'income' THEN -es.amount ELSE es.amount END) as total_owed
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id AND e.is_shared = true
    GROUP BY es.user_id
  )
  SELECT 
    u.id as user_id,
    u.email as user_email,
    u.full_name as user_full_name,
    u.avatar_url,
    COALESCE(p.total_paid, 0)::DECIMAL as total_paid,
    COALESCE(o.total_owed, 0)::DECIMAL as total_owed,
    (COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0))::DECIMAL as balance
  FROM public.users u
  LEFT JOIN payments p ON p.payer_id = u.id
  LEFT JOIN owes o ON o.debtor_id = u.id
  WHERE u.id IN (
    SELECT hm.user_id FROM public.household_members hm WHERE hm.household_id = p_household_id
  )
  ORDER BY balance DESC;
END;
$function$;
