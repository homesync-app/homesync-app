-- Anchor the household split ratio to a specific member so it is respected
-- consistently regardless of who pays/registers a shared expense.
--
-- default_split_ratio is the share (0..1) that belongs to split_ratio_anchor_id;
-- the other member pays (1 - default_split_ratio). Applies to 2-member divided
-- households with a non-0.5 ratio; otherwise expenses split equally.
--
-- Regular expenses already receive per-member split amounts computed by the
-- client; this makes pay_planned_expense (recurring) use the same anchored
-- ratio so recurring debts respect the configured percentage too.

ALTER TABLE public.households
  ADD COLUMN IF NOT EXISTS split_ratio_anchor_id uuid REFERENCES public.users(id);

-- Backfill existing custom-ratio households to the owner as a sensible default
-- (users can re-save the finance config to change it). Past records untouched.
UPDATE public.households h
SET split_ratio_anchor_id = (
  SELECT hm.user_id
  FROM public.household_members hm
  WHERE hm.household_id = h.id AND hm.role = 'owner'
  ORDER BY hm.joined_at NULLS LAST
  LIMIT 1
)
WHERE h.split_ratio_anchor_id IS NULL
  AND coalesce(h.default_split_ratio, 0.5) <> 0.5;

CREATE OR REPLACE FUNCTION public.pay_planned_expense(
  p_planned_id UUID,
  p_amount DECIMAL,
  p_paid_at TIMESTAMPTZ,
  p_paid_by TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := public.current_app_user_id();
  v_payer_uuid UUID;
  v_expense_id UUID;
  v_household_id UUID;
  v_title TEXT;
  v_category TEXT;
  v_split_type TEXT;
  v_is_shared BOOLEAN;
  v_ratio NUMERIC;
  v_anchor UUID;
  v_member_count INT;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
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

  SELECT hm.user_id
  INTO v_payer_uuid
  FROM public.household_members hm
  JOIN public.users u ON u.id = hm.user_id
  WHERE hm.household_id = v_household_id
    AND (u.id::text = p_paid_by OR u.firebase_uid = p_paid_by)
  LIMIT 1;

  IF v_payer_uuid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Payer is not a member of this household');
  END IF;

  v_is_shared := CASE
    WHEN lower(coalesce(v_split_type, 'equal')) IN ('personal', 'gift') THEN false
    ELSE true
  END;

  INSERT INTO public.expenses (
    household_id, created_by_id, title, amount, category, paid_by, paid_at,
    type, split_type, is_shared, planned_expense_id
  ) VALUES (
    v_household_id, v_uid, v_title, p_amount, v_category, v_payer_uuid, p_paid_at,
    'expense', coalesce(v_split_type, 'equal'), v_is_shared, p_planned_id
  ) RETURNING id INTO v_expense_id;

  UPDATE public.planned_expenses
  SET status = 'paid'
  WHERE id = p_planned_id;

  IF lower(coalesce(v_split_type, 'equal')) IN ('personal', 'gift') THEN
    INSERT INTO public.expense_splits (expense_id, user_id, amount)
    VALUES (v_expense_id, v_payer_uuid, p_amount);
  ELSE
    SELECT default_split_ratio, split_ratio_anchor_id
    INTO v_ratio, v_anchor
    FROM public.households
    WHERE id = v_household_id;

    SELECT count(*) INTO v_member_count
    FROM public.household_members
    WHERE household_id = v_household_id;

    IF v_member_count = 2 AND v_anchor IS NOT NULL
       AND v_ratio IS NOT NULL AND v_ratio <> 0.5 THEN
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT
        v_expense_id,
        hm.user_id,
        CASE WHEN hm.user_id = v_anchor
             THEN p_amount * v_ratio
             ELSE p_amount * (1 - v_ratio)
        END
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id;
    ELSE
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT
        v_expense_id,
        hm.user_id,
        p_amount / NULLIF(v_member_count, 0)
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'expense_id', v_expense_id,
    'message', 'Planned expense paid successfully'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, TEXT) TO authenticated;
