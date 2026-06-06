-- Parent Mode allowance transfers are only for teenagers.
--
-- Children do not have access to the Finance tab, so allowing an adult to send
-- money to a child creates a balance the child cannot inspect or use.

CREATE OR REPLACE FUNCTION public.transfer_to_member(
  p_household_id UUID,
  p_to_user      UUID,
  p_amount       NUMERIC,
  p_note         TEXT DEFAULT NULL,
  p_request_id   TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid             UUID := public.current_app_user_id();
  v_from_member     TEXT;
  v_from_name       TEXT;
  v_to_member       TEXT;
  v_to_name         TEXT;
  v_currency        TEXT;
  v_req             TEXT := COALESCE(NULLIF(p_request_id, ''), gen_random_uuid()::text);
  v_expense_out_id  UUID;
  v_income_in_id    UUID;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
  END IF;
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RETURN jsonb_build_object('success', false, 'message', 'Invalid amount');
  END IF;
  IF v_uid = p_to_user THEN
    RETURN jsonb_build_object('success', false, 'message', 'Cannot transfer to yourself');
  END IF;

  IF NOT public.is_household_premium(p_household_id) THEN
    RETURN jsonb_build_object('success', false, 'message', 'Premium required');
  END IF;

  SELECT hm.member_type, u.full_name
    INTO v_from_member, v_from_name
  FROM public.household_members hm
  JOIN public.users u ON u.id = hm.user_id
  WHERE hm.household_id = p_household_id AND hm.user_id = v_uid;
  IF v_from_member IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Sender is not a member of this household');
  END IF;
  IF COALESCE(v_from_member, 'parent') NOT IN ('parent', 'guardian', 'adult') THEN
    RETURN jsonb_build_object('success', false, 'message', 'Only adults can send an allowance');
  END IF;

  SELECT hm.member_type, u.full_name
    INTO v_to_member, v_to_name
  FROM public.household_members hm
  JOIN public.users u ON u.id = hm.user_id
  WHERE hm.household_id = p_household_id AND hm.user_id = p_to_user;
  IF v_to_member IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Recipient is not a member of this household');
  END IF;
  IF COALESCE(v_to_member, '') <> 'teen' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Recipient must be a teen with personal finances enabled');
  END IF;

  IF p_request_id IS NOT NULL AND EXISTS (
    SELECT 1 FROM public.expenses WHERE request_id = 'allowance-out-' || v_req
  ) THEN
    RETURN jsonb_build_object('success', true, 'idempotent', true, 'message', 'Already processed');
  END IF;

  SELECT currency INTO v_currency
  FROM public.expenses
  WHERE household_id = p_household_id
  ORDER BY created_at DESC
  LIMIT 1;
  v_currency := COALESCE(v_currency, 'ARS');

  INSERT INTO public.expenses (
    household_id, created_by_id, title, description, category, amount, currency,
    paid_by, paid_at, type, split_type, is_shared, request_id
  ) VALUES (
    p_household_id, v_uid, 'Mesada para ' || COALESCE(v_to_name, 'familiar'),
    p_note, 'allowance', p_amount, v_currency,
    v_uid, now(), 'expense', 'personal', false, 'allowance-out-' || v_req
  ) RETURNING id INTO v_expense_out_id;
  INSERT INTO public.expense_splits (expense_id, user_id, amount)
  VALUES (v_expense_out_id, v_uid, p_amount);

  INSERT INTO public.expenses (
    household_id, created_by_id, title, description, category, amount, currency,
    paid_by, paid_at, type, split_type, is_shared, request_id
  ) VALUES (
    p_household_id, v_uid, 'Mesada de ' || COALESCE(v_from_name, 'familiar'),
    p_note, 'allowance', p_amount, v_currency,
    p_to_user, now(), 'income', 'personal', false, 'allowance-in-' || v_req
  ) RETURNING id INTO v_income_in_id;
  INSERT INTO public.expense_splits (expense_id, user_id, amount)
  VALUES (v_income_in_id, p_to_user, p_amount);

  RETURN jsonb_build_object(
    'success', true,
    'amount', p_amount,
    'expense_out_id', v_expense_out_id,
    'income_in_id', v_income_in_id,
    'to_name', v_to_name
  );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.transfer_to_member(UUID, UUID, NUMERIC, TEXT, TEXT) FROM anon, PUBLIC;
GRANT EXECUTE ON FUNCTION public.transfer_to_member(UUID, UUID, NUMERIC, TEXT, TEXT) TO authenticated;

COMMENT ON FUNCTION public.transfer_to_member(UUID, UUID, NUMERIC, TEXT, TEXT) IS
  'Parent Mode allowance transfer: adult -> teen only. Children cannot receive allowances because they do not have Finance access.';
