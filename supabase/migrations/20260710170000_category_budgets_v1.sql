-- Presupuestos mensuales por categoría (feature premium).
--
-- Modelo por modo de hogar:
--  * Economía integrada (finance_mode = 'shared'): presupuesto DEL HOGAR
--    (owner_user_id NULL) — cualquier miembro lo ve y lo edita.
--  * Economía dividida: presupuesto PERSONAL (owner_user_id = dueño) — solo
--    el dueño lo ve/edita, porque su gasto por categoría es "su parte" y es
--    información personal (mismo criterio de privacidad que el resumen).
--
-- get_category_spend_v1 devuelve el gasto del mes por categoría con la MISMA
-- semántica de "mi parte" que get_personal_finance_summary: integrada = todo
-- el hogar a monto completo; dividida = mis personales completos + mi share
-- por splits de los compartidos (+ fallback equal para legacy sin splits).

CREATE TABLE IF NOT EXISTS public.category_budgets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id uuid NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  owner_user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  category text NOT NULL,
  monthly_limit numeric NOT NULL CHECK (monthly_limit > 0),
  created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Un presupuesto por categoría y dueño (NULL agrupado como hogar).
CREATE UNIQUE INDEX IF NOT EXISTS uq_category_budgets_scope
  ON public.category_budgets (
    household_id,
    COALESCE(owner_user_id, '00000000-0000-0000-0000-000000000000'::uuid),
    category
  );

ALTER TABLE public.category_budgets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "restrict_to_valid_jwt_category_budgets" ON public.category_budgets;
CREATE POLICY "restrict_to_valid_jwt_category_budgets"
  ON public.category_budgets
  AS RESTRICTIVE
  FOR ALL
  USING ((SELECT public.is_supabase_or_firebase_project_jwt()) IS TRUE);

DROP POLICY IF EXISTS "Members can view own or household budgets" ON public.category_budgets;
CREATE POLICY "Members can view own or household budgets"
  ON public.category_budgets
  FOR SELECT
  USING (
    public.is_current_household_member(household_id)
    AND (owner_user_id IS NULL OR owner_user_id = public.current_app_user_id())
  );

DROP POLICY IF EXISTS "Members can insert own or household budgets" ON public.category_budgets;
CREATE POLICY "Members can insert own or household budgets"
  ON public.category_budgets
  FOR INSERT
  WITH CHECK (
    public.is_current_household_member(household_id)
    AND (owner_user_id IS NULL OR owner_user_id = public.current_app_user_id())
  );

DROP POLICY IF EXISTS "Members can update own or household budgets" ON public.category_budgets;
CREATE POLICY "Members can update own or household budgets"
  ON public.category_budgets
  FOR UPDATE
  USING (
    public.is_current_household_member(household_id)
    AND (owner_user_id IS NULL OR owner_user_id = public.current_app_user_id())
  )
  WITH CHECK (
    public.is_current_household_member(household_id)
    AND (owner_user_id IS NULL OR owner_user_id = public.current_app_user_id())
  );

DROP POLICY IF EXISTS "Members can delete own or household budgets" ON public.category_budgets;
CREATE POLICY "Members can delete own or household budgets"
  ON public.category_budgets
  FOR DELETE
  USING (
    public.is_current_household_member(household_id)
    AND (owner_user_id IS NULL OR owner_user_id = public.current_app_user_id())
  );

-- Gasto del mes por categoría, con semántica de "mi parte" por modo.
CREATE OR REPLACE FUNCTION public.get_category_spend_v1(
  p_household_id uuid,
  p_month_start timestamptz DEFAULT NULL,
  p_month_end timestamptz DEFAULT NULL
)
RETURNS TABLE(category text, spent numeric)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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

  IF v_shared_economy THEN
    RETURN QUERY
    SELECT COALESCE(e.category, 'other') AS category, SUM(e.amount) AS spent
    FROM public.expenses e
    WHERE e.household_id = p_household_id
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

GRANT EXECUTE ON FUNCTION public.get_category_spend_v1(uuid, timestamptz, timestamptz) TO authenticated;
