-- Tendencia de gasto mensual (últimos N meses) con la misma semántica de
-- "mi parte" que get_personal_finance_summary / get_category_spend_v1:
-- economía integrada = gasto del hogar completo; dividida = mis personales
-- completos + mi share por splits (+ fallback equal para legacy sin splits).

CREATE OR REPLACE FUNCTION public.get_monthly_spend_trend_v1(
  p_household_id uuid,
  p_months integer DEFAULT 6
)
RETURNS TABLE(month_start date, spent numeric)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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

  IF v_shared_economy THEN
    RETURN QUERY
    SELECT date_trunc('month', e.paid_at)::date AS month_start,
           SUM(e.amount) AS spent
    FROM public.expenses e
    WHERE e.household_id = p_household_id
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

GRANT EXECUTE ON FUNCTION public.get_monthly_spend_trend_v1(uuid, integer) TO authenticated;
