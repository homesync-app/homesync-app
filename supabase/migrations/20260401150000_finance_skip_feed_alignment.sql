-- Align skipped planned expenses with current HomeSync UX:
-- skipped items should remain stored for auditability, but they should not
-- behave like pending items in the combined feed.

DROP FUNCTION IF EXISTS public.get_combined_feed(UUID, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION public.get_combined_feed(
  p_household_id UUID,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  record_type TEXT,
  transaction_type TEXT,
  id UUID,
  title TEXT,
  amount NUMERIC,
  category TEXT,
  split_type TEXT,
  payer_id UUID,
  payer_email TEXT,
  payer_full_name TEXT,
  payer_avatar_url TEXT,
  date TIMESTAMPTZ,
  status TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := public.current_app_user_id();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF NOT public.is_current_household_member(p_household_id) THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    'expense'::TEXT AS record_type,
    e.type::TEXT AS transaction_type,
    e.id,
    e.title,
    e.amount,
    e.category,
    e.split_type,
    e.paid_by AS payer_id,
    u.email AS payer_email,
    u.full_name AS payer_full_name,
    u.avatar_url AS payer_avatar_url,
    e.paid_at AS date,
    'paid'::TEXT AS status
  FROM public.expenses e
  LEFT JOIN public.users u ON u.id = e.paid_by
  WHERE e.household_id = p_household_id
    AND e.type IN ('expense', 'income', 'settlement')
    AND (
      COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
      OR e.paid_by = v_uid
      OR e.created_by_id = v_uid
    )

  UNION ALL

  SELECT
    'planned'::TEXT AS record_type,
    'expense'::TEXT AS transaction_type,
    pe.id,
    pe.title,
    pe.amount,
    pe.category,
    pe.split_type,
    pe.payer_default AS payer_id,
    u.email AS payer_email,
    u.full_name AS payer_full_name,
    u.avatar_url AS payer_avatar_url,
    pe.due_date::TIMESTAMPTZ AS date,
    pe.status
  FROM public.planned_expenses pe
  LEFT JOIN public.users u ON u.id = pe.payer_default
  WHERE pe.household_id = p_household_id
    AND pe.status = 'pending'
    AND (
      lower(coalesce(pe.split_type, 'equal')) NOT IN ('personal', 'gift')
      OR pe.payer_default = v_uid
    )

  ORDER BY date DESC, id DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_combined_feed(UUID, INTEGER, INTEGER) TO authenticated;
