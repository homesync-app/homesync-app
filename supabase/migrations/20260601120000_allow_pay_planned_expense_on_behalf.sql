-- Allow registering a planned (recurring) payment on behalf of any household member.
--
-- Two problems are fixed here vs 20260321172158_finance_privacy_hardening_v2.sql:
--
-- 1. That migration added a guard rejecting any call where p_paid_by != auth.uid(),
--    which broke the intended "¿Quién pagó?" selector (either member can mark a
--    shared bill as paid and attribute it). We replace it with household-membership
--    validation of both the caller and the selected payer.
--
-- 2. The Flutter client passes the payer id as a string that may be EITHER a
--    Supabase users.id UUID or a Firebase UID (depending on the provider that
--    sourced it). A UUID-typed parameter rejected Firebase UIDs at binding time
--    with 22P02 ("invalid input syntax for type uuid"). We type p_paid_by as TEXT
--    and resolve it to the canonical users.id, accepting either form, validating
--    household membership in the same lookup.
--
-- 3. The caller identity must come from public.current_app_user_id() (which the
--    rest of the finance RPCs use), NOT auth.uid(): with Firebase-bridged JWTs,
--    auth.uid() yields the Firebase UID and `v_uid uuid := auth.uid()` throws
--    22P02. current_app_user_id() safely resolves the Supabase users.id UUID.
--
-- Records created_by_id = caller uuid (who registered) and paid_by = resolved
-- payer uuid (who actually paid).

DROP FUNCTION IF EXISTS public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, UUID);
DROP FUNCTION IF EXISTS public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, TEXT);

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

  -- The caller must belong to the household.
  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = v_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'User is not a member of this household');
  END IF;

  -- Resolve the payer: accept either a Supabase UUID string or a Firebase UID,
  -- and require it to be a member of this household (payer selector semantics:
  -- either member can be marked as the one who paid).
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
    v_uid,            -- who registered the payment
    v_title,
    p_amount,
    v_category,
    v_payer_uuid,     -- who actually paid (resolved)
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
    VALUES (v_expense_id, v_payer_uuid, p_amount);
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'expense_id', v_expense_id,
    'message', 'Planned expense paid successfully'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, TEXT) TO authenticated;
