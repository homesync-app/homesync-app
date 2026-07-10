-- Cierre de mes narrativo ("Tu {mes} en HomeSync", premium en cliente).
--
-- Un solo RPC junta todo lo que el recap muestra, reutilizando las piezas
-- existentes para mantener UNA sola semántica de números:
--   * total/ingresos del mes: get_personal_finance_summary (bounds explícitos)
--   * total del mes anterior: ídem, para el delta
--   * top categorías: get_category_spend_v1
--   * aportes por miembro: cash real en compartidos (quién puso)
--   * ahorro sumado a metas del hogar en el mes
-- Todo con la semántica de "mi parte" en economía dividida y hogar completo
-- en integrada, igual que el resto de Finanzas.

CREATE OR REPLACE FUNCTION public.get_month_recap_v1(
  p_household_id uuid,
  p_month_start timestamptz,
  p_month_end timestamptz
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_user uuid := public.current_app_user_id();
  v_prev_start timestamptz := p_month_start - interval '1 month';
  v_summary jsonb;
  v_prev_summary jsonb;
  v_by_category jsonb;
  v_by_payer jsonb;
  v_savings numeric := 0;
  v_count integer := 0;
BEGIN
  IF v_user IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_user
  ) THEN
    RETURN jsonb_build_object('expense_count', 0);
  END IF;

  v_summary := public.get_personal_finance_summary(
    v_user, p_household_id, p_month_start, p_month_end
  );
  v_prev_summary := public.get_personal_finance_summary(
    v_user, p_household_id, v_prev_start, p_month_start
  );

  SELECT COALESCE(jsonb_agg(x), '[]'::jsonb) INTO v_by_category
  FROM (
    SELECT c.category, round(c.spent) AS spent
    FROM public.get_category_spend_v1(
      p_household_id, p_month_start, p_month_end
    ) c
    WHERE c.spent > 0
    ORDER BY c.spent DESC
    LIMIT 5
  ) x;

  -- Cash real puesto en COMPARTIDOS por cada miembro (la narrativa de
  -- "quién puso"); los personales quedan fuera para que la cifra sea la
  -- misma para todos los miembros.
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'user_id', u.id,
        'name', u.full_name,
        'avatar_url', u.avatar_url,
        'paid', round(p.paid)
      )
      ORDER BY p.paid DESC
    ),
    '[]'::jsonb
  ) INTO v_by_payer
  FROM (
    SELECT e.paid_by, SUM(e.amount) AS paid
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND e.type = 'expense'
      AND e.paid_at >= p_month_start
      AND e.paid_at < p_month_end
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = true
    GROUP BY e.paid_by
  ) p
  JOIN public.users u ON u.id = p.paid_by;

  SELECT COALESCE(SUM(sc.amount), 0) INTO v_savings
  FROM public.savings_contributions sc
  JOIN public.savings_goals sg ON sg.id = sc.goal_id
  WHERE sg.household_id = p_household_id
    AND sc.created_at >= p_month_start
    AND sc.created_at < p_month_end;

  SELECT count(*) INTO v_count
  FROM public.expenses e
  WHERE e.household_id = p_household_id
    AND e.type = 'expense'
    AND e.paid_at >= p_month_start
    AND e.paid_at < p_month_end
    AND (
      COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift')
            THEN false
          ELSE true
        END
      ) = true
      OR e.paid_by = v_user
      OR e.created_by_id = v_user
    );

  RETURN jsonb_build_object(
    'total_spent', round(COALESCE((v_summary->>'expense')::numeric, 0)),
    'prev_spent', round(COALESCE((v_prev_summary->>'expense')::numeric, 0)),
    'income', round(COALESCE((v_summary->>'income')::numeric, 0)),
    'by_category', v_by_category,
    'by_payer', v_by_payer,
    'savings_added', round(v_savings),
    'expense_count', v_count,
    'shared_economy', COALESCE((v_summary->>'shared_economy')::boolean, false)
  );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.get_month_recap_v1(uuid, timestamptz, timestamptz) TO authenticated;
