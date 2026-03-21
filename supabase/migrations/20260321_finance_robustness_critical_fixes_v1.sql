-- Critical robustness fixes
-- 1) save_expense_v4: auth/membership checks + created_by trust boundary + privacy consistency
-- 2) handle_expense_notifications: do not notify members who cannot view private expenses

CREATE OR REPLACE FUNCTION public.save_expense_v4(
    p_id UUID DEFAULT NULL,
    p_household_id UUID DEFAULT NULL,
    p_title TEXT DEFAULT NULL,
    p_amount DECIMAL DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_paid_by UUID DEFAULT NULL,
    p_paid_at TIMESTAMPTZ DEFAULT NOW(),
    p_description TEXT DEFAULT NULL,
    p_split_type TEXT DEFAULT 'equal',
    p_is_shared BOOLEAN DEFAULT true,
    p_type TEXT DEFAULT 'expense',
    p_splits JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_expense_id UUID := p_id;
    v_is_shared BOOLEAN := p_is_shared;
    v_member_id UUID;
    v_member_count INT;
    v_household_id UUID := p_household_id;
    v_rows_updated INT := 0;
BEGIN
    IF v_uid IS NULL THEN
      RAISE EXCEPTION 'Not authenticated';
    END IF;

    IF v_household_id IS NULL THEN
      SELECT household_id INTO v_household_id
      FROM public.household_members
      WHERE user_id = v_uid
      LIMIT 1;
    END IF;

    IF v_household_id IS NULL THEN
      RAISE EXCEPTION 'Household not found for user';
    END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND hm.user_id = v_uid
    ) THEN
      RAISE EXCEPTION 'User is not member of household';
    END IF;

    IF p_paid_by IS NULL OR NOT EXISTS (
      SELECT 1
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND hm.user_id = p_paid_by
    ) THEN
      RAISE EXCEPTION 'paid_by must be a member of the household';
    END IF;

    IF lower(coalesce(p_split_type, 'equal')) IN ('personal', 'gift') THEN
      v_is_shared := false;
    END IF;

    IF v_expense_id IS NULL THEN
      INSERT INTO public.expenses (
        household_id, created_by_id, title, description, category,
        amount, paid_by, paid_at, split_type, is_shared, type
      ) VALUES (
        v_household_id, v_uid, p_title, p_description, p_category,
        p_amount, p_paid_by, p_paid_at, p_split_type, v_is_shared, p_type::transaction_type
      ) RETURNING id INTO v_expense_id;
    ELSE
      UPDATE public.expenses
      SET
        title = p_title,
        description = p_description,
        category = p_category,
        amount = p_amount,
        paid_by = p_paid_by,
        paid_at = p_paid_at,
        split_type = p_split_type,
        is_shared = v_is_shared,
        type = p_type::transaction_type,
        updated_at = NOW()
      WHERE id = v_expense_id
        AND created_by_id = v_uid;

      GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
      IF v_rows_updated = 0 THEN
        RAISE EXCEPTION 'Expense not found or not owned by user';
      END IF;

      DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
    END IF;

    IF lower(coalesce(p_split_type, 'equal')) IN ('gift', 'personal') THEN
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, p_paid_by, p_amount);

    ELSIF lower(coalesce(p_split_type, 'equal')) = 'equal'
      AND (p_splits IS NULL OR jsonb_array_length(p_splits) <= 1) THEN
      SELECT COUNT(*) INTO v_member_count
      FROM public.household_members
      WHERE household_id = v_household_id;

      FOR v_member_id IN
        SELECT user_id FROM public.household_members WHERE household_id = v_household_id
      LOOP
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, v_member_id, p_amount / NULLIF(v_member_count, 0));
      END LOOP;

    ELSIF p_splits IS NOT NULL THEN
      IF EXISTS (
        SELECT 1
        FROM jsonb_array_elements(p_splits) s
        WHERE NOT EXISTS (
          SELECT 1
          FROM public.household_members hm
          WHERE hm.household_id = v_household_id
            AND hm.user_id = (s->>'user_id')::UUID
        )
      ) THEN
        RAISE EXCEPTION 'One or more split users are not household members';
      END IF;

      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT v_expense_id, (s->>'user_id')::UUID, (s->>'amount')::DECIMAL
      FROM jsonb_array_elements(p_splits) AS s;
    END IF;

    RETURN v_expense_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_expense_notifications()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  creator_name TEXT;
  member_id UUID;
  action_verb TEXT;
  display_title TEXT;
  v_is_visible BOOLEAN;
BEGIN
  SELECT split_part(full_name, ' ', 1)
  INTO creator_name
  FROM public.users
  WHERE id = NEW.created_by_id;

  IF creator_name IS NULL OR creator_name = '' THEN
    creator_name := 'Alguien';
  END IF;

  IF NEW.category = 'groceries' THEN
    action_verb := 'compró en';
  ELSE
    action_verb := 'gastó en';
  END IF;

  IF NEW.title = 'Liquidacion de deuda' THEN
    display_title := '¡Deuda saldada!';
    action_verb := 'saldó la deuda con';
  ELSE
    display_title := 'Nuevo movimiento';
  END IF;

  FOR member_id IN
    SELECT user_id
    FROM public.household_members
    WHERE household_id = NEW.household_id
      AND user_id <> NEW.created_by_id
  LOOP
    v_is_visible := (
      coalesce(NEW.is_shared, true) = true
      OR member_id = NEW.paid_by
      OR member_id = NEW.created_by_id
    );

    IF v_is_visible THEN
      INSERT INTO public.notifications (
        household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id
      ) VALUES (
        NEW.household_id,
        member_id,
        NEW.created_by_id,
        display_title,
        CASE
          WHEN NEW.title = 'Liquidacion de deuda' THEN creator_name || ' saldó su deuda de $ ' || NEW.amount
          ELSE creator_name || ' ' || action_verb || ' ' || NEW.title || ' ($ ' || NEW.amount || ')'
        END,
        'expense_added',
        'expense',
        NEW.id
      );
    END IF;
  END LOOP;

  RETURN NEW;
END;
$$;
