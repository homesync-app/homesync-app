-- Economía integrada (finance_mode = 'shared'): el pozo del hogar es solo de los
-- adultos (docs/TEEN_FINANCES_SPEC.md). Hasta ahora el resumen, los presupuestos y la
-- tendencia sumaban también lo que cobra y gasta un adolescente en su cuenta personal:
-- la mesada aparecía como ingreso del hogar (además de como gasto del adulto que la
-- paga) y sus gastos personales inflaban "Gastos". Ahora:
--   * lo que paga o cobra un teen/child queda fuera del pozo compartido;
--   * la mesada sigue contando como gasto del adulto que la manda;
--   * si quien consulta es teen/child, ve su propia cuenta (vista personal).
-- get_month_recap_v1 reutiliza get_personal_finance_summary y hereda el cambio.

CREATE OR REPLACE FUNCTION public.is_finance_minor(p_household_id uuid, p_user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = p_user_id
      AND hm.member_type IN ('teen', 'child')
  );
$function$;

REVOKE EXECUTE ON FUNCTION public.is_finance_minor(uuid, uuid) FROM anon, public;
-- Solo la usan otras funciones SECURITY DEFINER: no hace falta exponerla al cliente.
REVOKE EXECUTE ON FUNCTION public.is_finance_minor(uuid, uuid) FROM authenticated;

CREATE OR REPLACE FUNCTION public.get_personal_finance_summary(p_user_id uuid, p_household_id uuid, p_month_start timestamp with time zone DEFAULT NULL::timestamp with time zone, p_month_end timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user uuid := public.current_app_user_id();
  v_start timestamptz :=
    COALESCE(p_month_start, date_trunc('month', now()));
  v_end timestamptz :=
    COALESCE(p_month_end, date_trunc('month', now()) + interval '1 month');
  v_shared_economy boolean := false;
  v_ledger DECIMAL := 0;
  v_income DECIMAL := 0;
  v_income_shared_share DECIMAL := 0;
  v_income_shared_fallback DECIMAL := 0;
  v_expense_personal DECIMAL := 0;
  v_share_from_splits DECIMAL := 0;
  v_share_fallback DECIMAL := 0;
  v_expense DECIMAL := 0;
BEGIN
  IF v_user IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_user
  ) THEN
    RETURN jsonb_build_object('balance', 0, 'income', 0, 'expense', 0);
  END IF;

  SELECT h.finance_mode = 'shared' INTO v_shared_economy
  FROM public.households h
  WHERE h.id = p_household_id;
  v_shared_economy := COALESCE(v_shared_economy, false);
  -- Un adolescente o chico tiene su propia cuenta: nunca ve el pozo del hogar.
  IF public.is_finance_minor(p_household_id, v_user) THEN
    v_shared_economy := false;
  END IF;

  SELECT COALESCE(SUM(amount), 0) INTO v_ledger
  FROM public.ledger_entries
  WHERE user_id = v_user
    AND household_id = p_household_id
    AND (currency IS NULL OR (currency <> 'XP' AND currency <> 'COIN'));

  IF v_shared_economy THEN
    SELECT COALESCE(SUM(e.amount), 0) INTO v_income
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND e.type = 'income'
      AND e.paid_at >= v_start
      AND e.paid_at < v_end
      AND NOT public.is_finance_minor(e.household_id, e.paid_by);
  ELSE
    SELECT COALESCE(SUM(e.amount), 0) INTO v_income
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND e.type = 'income'
      AND e.paid_at >= v_start
      AND e.paid_at < v_end
      AND e.paid_by = v_user
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = false;

    SELECT COALESCE(SUM(es.amount), 0) INTO v_income_shared_share
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND e.type = 'income'
      AND es.user_id = v_user
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

    SELECT COALESCE(SUM(e.amount / GREATEST(mc.cnt, 1)), 0)
      INTO v_income_shared_fallback
    FROM public.expenses e
    CROSS JOIN LATERAL (
      SELECT count(*) AS cnt
      FROM public.household_members hm
      WHERE hm.household_id = e.household_id
    ) mc
    WHERE e.household_id = p_household_id
      AND e.type = 'income'
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

    v_income := v_income + v_income_shared_share + v_income_shared_fallback;
  END IF;

  SELECT COALESCE(SUM(e.amount), 0) INTO v_expense_personal
  FROM public.expenses e
  WHERE e.household_id = p_household_id
    AND e.type = 'expense'
    AND e.paid_at >= v_start
    AND e.paid_at < v_end
    AND (
      (v_shared_economy AND NOT public.is_finance_minor(e.household_id, e.paid_by))
      OR (
        e.paid_by = v_user
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
    SELECT COALESCE(SUM(es.amount), 0) INTO v_share_from_splits
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND es.user_id = v_user
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

CREATE OR REPLACE FUNCTION public.get_category_spend_v1(p_household_id uuid, p_month_start timestamp with time zone DEFAULT NULL::timestamp with time zone, p_month_end timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS TABLE(category text, spent numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user uuid := public.current_app_user_id();
  v_start timestamptz := COALESCE(p_month_start, date_trunc('month', now()));
  v_end timestamptz :=
    COALESCE(p_month_end, date_trunc('month', now()) + interval '1 month');
  v_shared_economy boolean := false;
BEGIN
  IF v_user IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_user
  ) THEN
    RETURN;
  END IF;

  SELECT h.finance_mode = 'shared' INTO v_shared_economy
  FROM public.households h
  WHERE h.id = p_household_id;
  v_shared_economy := COALESCE(v_shared_economy, false);
  -- Un adolescente o chico tiene su propia cuenta: nunca ve el pozo del hogar.
  IF public.is_finance_minor(p_household_id, v_user) THEN
    v_shared_economy := false;
  END IF;

  IF v_shared_economy THEN
    RETURN QUERY
    SELECT COALESCE(e.category, 'other') AS category, SUM(e.amount) AS spent
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND NOT public.is_finance_minor(e.household_id, e.paid_by)
      AND e.type = 'expense'
      AND e.paid_at >= v_start
      AND e.paid_at < v_end
    GROUP BY 1;
    RETURN;
  END IF;

  RETURN QUERY
  WITH personal AS (
    SELECT COALESCE(e.category, 'other') AS cat, SUM(e.amount) AS amt
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND e.paid_at >= v_start
      AND e.paid_at < v_end
      AND e.paid_by = v_user
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = false
    GROUP BY 1
  ),
  shared_share AS (
    SELECT COALESCE(e.category, 'other') AS cat, SUM(es.amount) AS amt
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND es.user_id = v_user
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
    GROUP BY 1
  ),
  legacy_fallback AS (
    SELECT COALESCE(e.category, 'other') AS cat,
           SUM(e.amount / GREATEST(mc.cnt, 1)) AS amt
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
      )
    GROUP BY 1
  )
  SELECT u.cat AS category, SUM(u.amt) AS spent
  FROM (
    SELECT * FROM personal
    UNION ALL
    SELECT * FROM shared_share
    UNION ALL
    SELECT * FROM legacy_fallback
  ) u
  GROUP BY u.cat;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_monthly_spend_trend_v1(p_household_id uuid, p_months integer DEFAULT 6)
 RETURNS TABLE(month_start date, spent numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user uuid := public.current_app_user_id();
  v_months integer := LEAST(GREATEST(COALESCE(p_months, 6), 1), 24);
  v_from timestamptz;
  v_shared_economy boolean := false;
BEGIN
  IF v_user IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_user
  ) THEN
    RETURN;
  END IF;

  v_from := date_trunc('month', now()) - make_interval(months => v_months - 1);

  SELECT h.finance_mode = 'shared' INTO v_shared_economy
  FROM public.households h
  WHERE h.id = p_household_id;
  v_shared_economy := COALESCE(v_shared_economy, false);
  -- Un adolescente o chico tiene su propia cuenta: nunca ve el pozo del hogar.
  IF public.is_finance_minor(p_household_id, v_user) THEN
    v_shared_economy := false;
  END IF;

  IF v_shared_economy THEN
    RETURN QUERY
    SELECT date_trunc('month', e.paid_at)::date AS month_start,
           SUM(e.amount) AS spent
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND NOT public.is_finance_minor(e.household_id, e.paid_by)
      AND e.type = 'expense'
      AND e.paid_at >= v_from
    GROUP BY 1
    ORDER BY 1;
    RETURN;
  END IF;

  RETURN QUERY
  WITH personal AS (
    SELECT date_trunc('month', e.paid_at)::date AS m, SUM(e.amount) AS amt
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND e.paid_at >= v_from
      AND e.paid_by = v_user
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = false
    GROUP BY 1
  ),
  shared_share AS (
    SELECT date_trunc('month', e.paid_at)::date AS m, SUM(es.amount) AS amt
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND es.user_id = v_user
      AND e.paid_at >= v_from
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = true
    GROUP BY 1
  ),
  legacy_fallback AS (
    SELECT date_trunc('month', e.paid_at)::date AS m,
           SUM(e.amount / GREATEST(mc.cnt, 1)) AS amt
    FROM public.expenses e
    CROSS JOIN LATERAL (
      SELECT count(*) AS cnt
      FROM public.household_members hm
      WHERE hm.household_id = e.household_id
    ) mc
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND e.paid_at >= v_from
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
      )
    GROUP BY 1
  )
  SELECT u.m AS month_start, SUM(u.amt) AS spent
  FROM (
    SELECT * FROM personal
    UNION ALL
    SELECT * FROM shared_share
    UNION ALL
    SELECT * FROM legacy_fallback
  ) u
  GROUP BY u.m
  ORDER BY u.m;
END;
$function$;
