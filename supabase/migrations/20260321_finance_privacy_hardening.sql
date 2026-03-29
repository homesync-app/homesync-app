-- Finance privacy hardening
-- Goal: ensure personal/private expenses are only visible to the creator/payer,
-- and shared flows keep working for household-level balances and feed.

-- 1) Ensure privacy columns exist and are normalized
ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS split_type TEXT DEFAULT 'equal';

ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS is_shared BOOLEAN DEFAULT true;

UPDATE public.expenses e
SET is_shared = CASE
  WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
  ELSE true
END
WHERE e.is_shared IS DISTINCT FROM CASE
  WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
  ELSE true
END;

-- 2) Tighten RLS visibility for expenses
DROP POLICY IF EXISTS "Users can view household expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can view visible household expenses" ON public.expenses;

CREATE POLICY "Users can view visible household expenses"
ON public.expenses
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = expenses.household_id
      AND hm.user_id = auth.uid()
  )
  AND (
    COALESCE(
      expenses.is_shared,
      CASE
        WHEN lower(coalesce(expenses.split_type, 'equal')) IN ('personal', 'gift') THEN false
        ELSE true
      END
    ) = true
    OR expenses.paid_by = auth.uid()
    OR expenses.created_by_id = auth.uid()
  )
);

-- 3) Tighten RLS visibility for expense splits to match visible expenses
DROP POLICY IF EXISTS "Users can view expense splits" ON public.expense_splits;
DROP POLICY IF EXISTS "Users can view visible expense splits" ON public.expense_splits;

CREATE POLICY "Users can view visible expense splits"
ON public.expense_splits
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.expenses e
    JOIN public.household_members hm
      ON hm.household_id = e.household_id
    WHERE e.id = expense_splits.expense_id
      AND hm.user_id = auth.uid()
      AND (
        COALESCE(
          e.is_shared,
          CASE
            WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
            ELSE true
          END
        ) = true
        OR e.paid_by = auth.uid()
        OR e.created_by_id = auth.uid()
      )
  )
);

-- 4) Canonical filtered expenses RPC with auth-aware privacy filtering
CREATE OR REPLACE FUNCTION public.get_filtered_expenses(
  p_household_id UUID,
  p_type TEXT DEFAULT 'all',
  p_sharing TEXT DEFAULT 'all',
  p_limit INTEGER DEFAULT 100,
  p_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_result JSONB;
BEGIN
  IF v_uid IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN '[]'::jsonb;
  END IF;

  SELECT jsonb_agg(t) INTO v_result
  FROM (
    SELECT
      e.*,
      jsonb_build_object(
        'email', u.email,
        'full_name', u.full_name,
        'avatar_url', u.avatar_url
      ) AS payer,
      (
        SELECT jsonb_agg(s)
        FROM public.expense_splits s
        WHERE s.expense_id = e.id
      ) AS expense_splits
    FROM public.expenses e
    JOIN public.users u ON u.id = e.paid_by
    WHERE e.household_id = p_household_id
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
      AND (
        p_type = 'all'
        OR e.type::TEXT = p_type
      )
      AND (
        p_sharing = 'all'
        OR (
          p_sharing = 'shared'
          AND COALESCE(
            e.is_shared,
            CASE
              WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
              ELSE true
            END
          ) = true
        )
        OR (
          p_sharing = 'mine'
          AND COALESCE(
            e.is_shared,
            CASE
              WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
              ELSE true
            END
          ) = false
          AND (e.paid_by = v_uid OR e.created_by_id = v_uid)
        )
      )
    ORDER BY e.paid_at DESC
    LIMIT p_limit
    OFFSET p_offset
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_filtered_expenses(UUID, TEXT, TEXT, INTEGER, INTEGER) TO authenticated;

-- 5) Canonical combined feed RPC with privacy filtering for both real and planned entries
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
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
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
    AND pe.status != 'paid'
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

-- 6) Keep household balance based on shared expenses only
CREATE OR REPLACE FUNCTION public.get_expense_balance(
  p_household_id UUID
)
RETURNS TABLE (
  user_id UUID,
  user_email TEXT,
  user_full_name TEXT,
  balance NUMERIC,
  avatar_url TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN;
  END IF;

  RETURN QUERY
  WITH members AS (
    SELECT u.id, u.email, u.full_name, u.avatar_url
    FROM public.users u
    JOIN public.household_members hm ON hm.user_id = u.id
    WHERE hm.household_id = p_household_id
  ),
  paid AS (
    SELECT e.paid_by AS user_id, SUM(e.amount) AS total_paid
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
    GROUP BY e.paid_by
  ),
  owed AS (
    SELECT es.user_id, SUM(es.amount) AS total_owed
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
    GROUP BY es.user_id
  )
  SELECT
    m.id AS user_id,
    m.email AS user_email,
    m.full_name AS user_full_name,
    COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0) AS balance,
    m.avatar_url
  FROM members m
  LEFT JOIN paid p ON p.user_id = m.id
  LEFT JOIN owed o ON o.user_id = m.id
  ORDER BY balance DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_expense_balance(UUID) TO authenticated;

-- 7) Planned payment should write consistent privacy fields
DROP FUNCTION IF EXISTS public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, UUID);
CREATE OR REPLACE FUNCTION public.pay_planned_expense(
  p_planned_id UUID,
  p_amount DECIMAL,
  p_paid_at TIMESTAMPTZ,
  p_paid_by UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_expense_id UUID;
  v_household_id UUID;
  v_title TEXT;
  v_category TEXT;
  v_split_type TEXT;
  v_is_shared BOOLEAN;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
  END IF;

  IF p_paid_by IS DISTINCT FROM v_uid THEN
    RETURN jsonb_build_object('success', false, 'message', 'You can only pay with your own user');
  END IF;

  SELECT household_id, title, category, split_type
  INTO v_household_id, v_title, v_category, v_split_type
  FROM public.planned_expenses
  WHERE id = p_planned_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Planned expense not found');
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = v_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'User is not a member of this household');
  END IF;

  v_is_shared := CASE
    WHEN lower(coalesce(v_split_type, 'equal')) IN ('personal', 'gift') THEN false
    ELSE true
  END;

  INSERT INTO public.expenses (
    household_id,
    created_by_id,
    title,
    amount,
    category,
    paid_by,
    paid_at,
    type,
    split_type,
    is_shared,
    planned_expense_id
  ) VALUES (
    v_household_id,
    v_uid,
    v_title,
    p_amount,
    v_category,
    p_paid_by,
    p_paid_at,
    'expense',
    coalesce(v_split_type, 'equal'),
    v_is_shared,
    p_planned_id
  ) RETURNING id INTO v_expense_id;

  UPDATE public.planned_expenses
  SET status = 'paid'
  WHERE id = p_planned_id;

  IF lower(coalesce(v_split_type, 'equal')) = 'equal' THEN
    INSERT INTO public.expense_splits (expense_id, user_id, amount)
    SELECT
      v_expense_id,
      hm.user_id,
      p_amount / NULLIF((SELECT count(*)::DECIMAL FROM public.household_members WHERE household_id = v_household_id), 0)
    FROM public.household_members hm
    WHERE hm.household_id = v_household_id;
  ELSE
    INSERT INTO public.expense_splits (expense_id, user_id, amount)
    VALUES (v_expense_id, p_paid_by, p_amount);
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'expense_id', v_expense_id,
    'message', 'Planned expense paid successfully'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, UUID) TO authenticated;
