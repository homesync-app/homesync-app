-- Planned expenses are paid server-side, so their split scope must mirror the
-- Flutter expense form: family/couple finances split between adults only;
-- friends/roommates split between all members.

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
  v_household_type TEXT;
  v_title TEXT;
  v_category TEXT;
  v_split_type TEXT;
  v_is_shared BOOLEAN;
  v_ratio NUMERIC;
  v_anchor UUID;
  v_split_member_count INT;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
  END IF;

  SELECT pe.household_id, h.household_type, pe.title, pe.category, pe.split_type
  INTO v_household_id, v_household_type, v_title, v_category, v_split_type
  FROM public.planned_expenses pe
  JOIN public.households h ON h.id = pe.household_id
  WHERE pe.id = p_planned_id;

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
    AND (
      lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
      OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
    )
  LIMIT 1;

  IF v_payer_uuid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Payer is not an eligible adult member of this household');
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

    WITH split_members AS (
      SELECT hm.user_id
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND (
          lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
          OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
        )
    )
    SELECT count(*) INTO v_split_member_count
    FROM split_members;

    IF v_split_member_count = 2
       AND v_anchor IS NOT NULL
       AND v_ratio IS NOT NULL
       AND v_ratio <> 0.5
       AND EXISTS (
         SELECT 1
         FROM public.household_members hm
         WHERE hm.household_id = v_household_id
           AND hm.user_id = v_anchor
           AND (
             lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
             OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
           )
       ) THEN
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT
        v_expense_id,
        hm.user_id,
        CASE WHEN hm.user_id = v_anchor
             THEN p_amount * v_ratio
             ELSE p_amount * (1 - v_ratio)
        END
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND (
          lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
          OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
        );
    ELSE
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT
        v_expense_id,
        hm.user_id,
        p_amount / NULLIF(v_split_member_count, 0)
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND (
          lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
          OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
        );
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

-- Repair already-created planned equal splits for family/couple households.
DO $$
DECLARE
  v_expense RECORD;
BEGIN
  FOR v_expense IN
    SELECT
      e.id,
      e.household_id,
      e.amount,
      h.default_split_ratio,
      h.split_ratio_anchor_id,
      count(*) FILTER (
        WHERE coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
      ) as adult_count,
      count(*) FILTER (
        WHERE coalesce(hm.member_type, 'parent') NOT IN ('parent', 'guardian', 'adult')
      ) as child_split_count
    FROM public.expenses e
    JOIN public.households h ON h.id = e.household_id
    JOIN public.expense_splits es ON es.expense_id = e.id
    LEFT JOIN public.household_members hm
      ON hm.household_id = e.household_id
     AND hm.user_id = es.user_id
    WHERE e.planned_expense_id IS NOT NULL
      AND lower(coalesce(e.split_type, 'equal')) = 'equal'
      AND lower(coalesce(h.household_type, 'couple')) NOT IN ('friends', 'roommates')
    GROUP BY e.id, e.household_id, e.amount, h.default_split_ratio, h.split_ratio_anchor_id
    HAVING count(*) FILTER (
      WHERE coalesce(hm.member_type, 'parent') NOT IN ('parent', 'guardian', 'adult')
    ) > 0
       AND count(*) FILTER (
      WHERE coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
    ) > 0
  LOOP
    DELETE FROM public.expense_splits
    WHERE expense_id = v_expense.id;

    INSERT INTO public.expense_splits (expense_id, user_id, amount)
    SELECT
      v_expense.id,
      hm.user_id,
      CASE
        WHEN v_expense.adult_count = 2
          AND v_expense.split_ratio_anchor_id IS NOT NULL
          AND v_expense.default_split_ratio IS NOT NULL
          AND v_expense.default_split_ratio <> 0.5
          AND EXISTS (
            SELECT 1
            FROM public.household_members anchor_member
            WHERE anchor_member.household_id = v_expense.household_id
              AND anchor_member.user_id = v_expense.split_ratio_anchor_id
              AND coalesce(anchor_member.member_type, 'parent') IN ('parent', 'guardian', 'adult')
          )
        THEN
          CASE WHEN hm.user_id = v_expense.split_ratio_anchor_id
               THEN v_expense.amount * v_expense.default_split_ratio
               ELSE v_expense.amount * (1 - v_expense.default_split_ratio)
          END
        ELSE v_expense.amount / NULLIF(v_expense.adult_count, 0)
      END
    FROM public.household_members hm
    WHERE hm.household_id = v_expense.household_id
      AND coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult');
  END LOOP;
END $$;
