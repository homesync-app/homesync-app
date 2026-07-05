-- Fix get_personal_finance_summary v2's privacy guard: it used auth.uid()
-- directly, which casts the JWT's `sub` claim straight to uuid. For
-- Firebase-authenticated sessions that claim is the Firebase UID (a 28-char
-- alnum string, not a uuid), so the cast itself throws
-- "invalid input syntax for type uuid" before the function body ever runs —
-- independent of what the client sends as p_user_id/p_household_id.
--
-- Every other finance RPC already routes through public.current_app_user_id(),
-- which resolves the Firebase UID to the app's users.id safely. Do the same
-- here instead of calling auth.uid() directly.

CREATE OR REPLACE FUNCTION public.get_personal_finance_summary(
  p_user_id uuid,
  p_household_id uuid,
  p_month_start timestamptz DEFAULT NULL,
  p_month_end timestamptz DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_start timestamptz :=
    COALESCE(p_month_start, date_trunc('month', now()));
  v_end timestamptz :=
    COALESCE(p_month_end, date_trunc('month', now()) + interval '1 month');
  v_shared_economy boolean := false;
  v_ledger DECIMAL := 0;
  v_income DECIMAL := 0;
  v_expense_personal DECIMAL := 0;
  v_share_from_splits DECIMAL := 0;
  v_share_fallback DECIMAL := 0;
  v_expense DECIMAL := 0;
BEGIN
  -- Privacidad: solo miembros del hogar pueden leer el resumen.
  IF public.current_app_user_id() IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = public.current_app_user_id()
  ) THEN
    RETURN jsonb_build_object('balance', 0, 'income', 0, 'expense', 0);
  END IF;

  SELECT h.finance_mode = 'shared' INTO v_shared_economy
  FROM public.households h
  WHERE h.id = p_household_id;
  v_shared_economy := COALESCE(v_shared_economy, false);

  -- Ledger de por vida (stock de premios/ajustes en moneda real).
  SELECT COALESCE(SUM(amount), 0) INTO v_ledger
  FROM public.ledger_entries
  WHERE user_id = p_user_id
    AND household_id = p_household_id
    AND (currency IS NULL OR (currency <> 'XP' AND currency <> 'COIN'));

  -- Ingresos del mes.
  SELECT COALESCE(SUM(e.amount), 0) INTO v_income
  FROM public.expenses e
  WHERE e.household_id = p_household_id
    AND e.type = 'income'
    AND e.paid_at >= v_start
    AND e.paid_at < v_end
    AND (v_shared_economy OR e.paid_by = p_user_id);

  -- Gastos no compartidos (personales/gifts) pagados por mí; en economía
  -- integrada, TODOS los gastos del hogar a monto completo.
  SELECT COALESCE(SUM(e.amount), 0) INTO v_expense_personal
  FROM public.expenses e
  WHERE e.household_id = p_household_id
    AND e.type = 'expense'
    AND e.paid_at >= v_start
    AND e.paid_at < v_end
    AND (
      v_shared_economy
      OR (
        e.paid_by = p_user_id
        AND COALESCE(
          e.is_shared,
          CASE
            WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
              THEN false
            ELSE true
          END
        ) = false
      )
    );

  IF NOT v_shared_economy THEN
    -- Mi parte de los compartidos del mes (los pague quien los pague).
    SELECT COALESCE(SUM(es.amount), 0) INTO v_share_from_splits
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND es.user_id = p_user_id
      AND e.paid_at >= v_start
      AND e.paid_at < v_end
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = true;

    -- Compartidos legacy sin filas de split: partes iguales entre miembros.
    SELECT COALESCE(SUM(e.amount / GREATEST(mc.cnt, 1)), 0)
      INTO v_share_fallback
    FROM public.expenses e
    CROSS JOIN LATERAL (
      SELECT count(*) AS cnt
      FROM public.household_members hm
      WHERE hm.household_id = e.household_id
    ) mc
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND e.paid_at >= v_start
      AND e.paid_at < v_end
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = true
      AND NOT EXISTS (
        SELECT 1 FROM public.expense_splits es WHERE es.expense_id = e.id
      );
  END IF;

  v_expense := v_expense_personal + v_share_from_splits + v_share_fallback;

  RETURN jsonb_build_object(
    'balance', v_ledger + v_income - v_expense,
    'income', v_income,
    'expense', v_expense,
    'expense_personal', v_expense_personal,
    'expense_shared_share', v_share_from_splits + v_share_fallback,
    'ledger', v_ledger,
    'shared_economy', v_shared_economy,
    'month_start', v_start,
    'variation', 0
  );
END;
$function$;
