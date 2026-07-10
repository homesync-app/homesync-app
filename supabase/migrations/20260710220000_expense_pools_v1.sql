-- Fondos de gasto (modo convivencia): "Asado", "Viaje a Bariloche".
--
-- Un fondo AGRUPA gastos compartidos — no es una economía aparte: sus gastos
-- entran al balance global como siempre (una sola verdad de deudas). El
-- detalle del fondo es una lente: total, quién puso cuánto y qué falta
-- saldar DE ESE FONDO. Registrar el pago de una deuda del fondo usa el
-- settle global (con pool_id para que el fondo también quede en cero).
--
-- save_expense_v4 y settle_debt_v1 suman p_pool_id: se DROPea la firma
-- anterior y se recrea con el parámetro nuevo con DEFAULT NULL en la misma
-- transacción (los clientes viejos llaman por nombre sin p_pool_id y
-- resuelven a la única firma).

CREATE TABLE IF NOT EXISTS public.expense_pools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id uuid NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  name text NOT NULL,
  emoji text NOT NULL DEFAULT '🎉',
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed')),
  created_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
  closed_at timestamptz
);

ALTER TABLE public.expense_pools ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "restrict_to_valid_jwt_expense_pools" ON public.expense_pools;
CREATE POLICY "restrict_to_valid_jwt_expense_pools"
  ON public.expense_pools
  AS RESTRICTIVE
  FOR ALL
  USING ((SELECT public.is_supabase_or_firebase_project_jwt()) IS TRUE);

DROP POLICY IF EXISTS "Members can view household pools" ON public.expense_pools;
CREATE POLICY "Members can view household pools"
  ON public.expense_pools
  FOR SELECT
  USING (public.is_current_household_member(household_id));

DROP POLICY IF EXISTS "Members can create household pools" ON public.expense_pools;
CREATE POLICY "Members can create household pools"
  ON public.expense_pools
  FOR INSERT
  WITH CHECK (public.is_current_household_member(household_id));

DROP POLICY IF EXISTS "Members can update household pools" ON public.expense_pools;
CREATE POLICY "Members can update household pools"
  ON public.expense_pools
  FOR UPDATE
  USING (public.is_current_household_member(household_id))
  WITH CHECK (public.is_current_household_member(household_id));

ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS pool_id uuid
    REFERENCES public.expense_pools(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_expenses_pool
  ON public.expenses (pool_id)
  WHERE pool_id IS NOT NULL;

-- --------------------------------------------------------------------------
-- save_expense_v4 con p_pool_id (DROP + recreate para no dejar overloads).
-- --------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.save_expense_v4(
  p_id uuid, p_household_id uuid, p_title text, p_amount numeric,
  p_category text, p_paid_by uuid, p_paid_at timestamp with time zone,
  p_description text, p_split_type text, p_is_shared boolean,
  p_type text, p_splits jsonb, p_receipt_path text
);

CREATE OR REPLACE FUNCTION public.save_expense_v4(
  p_id uuid DEFAULT NULL::uuid,
  p_household_id uuid DEFAULT NULL::uuid,
  p_title text DEFAULT NULL::text,
  p_amount numeric DEFAULT NULL::numeric,
  p_category text DEFAULT NULL::text,
  p_paid_by uuid DEFAULT NULL::uuid,
  p_paid_at timestamp with time zone DEFAULT now(),
  p_description text DEFAULT NULL::text,
  p_split_type text DEFAULT 'equal'::text,
  p_is_shared boolean DEFAULT true,
  p_type text DEFAULT 'expense'::text,
  p_splits jsonb DEFAULT NULL::jsonb,
  p_receipt_path text DEFAULT NULL::text,
  p_pool_id uuid DEFAULT NULL::uuid
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
    v_uid UUID := public.current_app_user_id();
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
      SELECT 1 FROM public.household_members hm
      WHERE hm.household_id = v_household_id AND hm.user_id = v_uid
    ) THEN
      RAISE EXCEPTION 'User is not member of household';
    END IF;

    IF p_paid_by IS NULL OR NOT EXISTS (
      SELECT 1 FROM public.household_members hm
      WHERE hm.household_id = v_household_id AND hm.user_id = p_paid_by
    ) THEN
      RAISE EXCEPTION 'paid_by must be a member of the household';
    END IF;

    -- El fondo debe ser del mismo hogar y estar activo.
    IF p_pool_id IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM public.expense_pools ep
      WHERE ep.id = p_pool_id
        AND ep.household_id = v_household_id
        AND ep.status = 'active'
    ) THEN
      RAISE EXCEPTION 'Pool not found or not active in this household';
    END IF;

    IF lower(coalesce(p_split_type, 'equal')) IN ('personal', 'gift') THEN
      v_is_shared := false;
    END IF;

    IF v_expense_id IS NULL THEN
      INSERT INTO public.expenses (
        household_id, created_by_id, title, description, category,
        amount, paid_by, paid_at, split_type, is_shared, type, receipt_path,
        pool_id
      ) VALUES (
        v_household_id, v_uid, p_title, p_description, p_category,
        p_amount, p_paid_by, p_paid_at, p_split_type, v_is_shared,
        p_type::transaction_type, p_receipt_path, p_pool_id
      ) RETURNING id INTO v_expense_id;
    ELSE
      UPDATE public.expenses
      SET
        title        = p_title,
        description  = p_description,
        category     = p_category,
        amount       = p_amount,
        paid_by      = p_paid_by,
        paid_at      = p_paid_at,
        split_type   = p_split_type,
        is_shared    = v_is_shared,
        type         = p_type::transaction_type,
        receipt_path = p_receipt_path,
        pool_id      = p_pool_id,
        updated_at   = NOW()
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
        SELECT 1 FROM jsonb_array_elements(p_splits) s
        WHERE NOT EXISTS (
          SELECT 1 FROM public.household_members hm
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
$function$;

GRANT EXECUTE ON FUNCTION public.save_expense_v4(uuid, uuid, text, numeric, text, uuid, timestamptz, text, text, boolean, text, jsonb, text, uuid) TO authenticated;

-- --------------------------------------------------------------------------
-- settle_debt_v1 con p_pool_id (para que la liquidación también ponga en
-- cero el fondo desde el que se registró).
-- --------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.settle_debt_v1(
  p_request_id text, p_household_id uuid, p_from_user_id uuid,
  p_to_user_id uuid, p_amount numeric
);

CREATE OR REPLACE FUNCTION public.settle_debt_v1(
  p_request_id text,
  p_household_id uuid,
  p_from_user_id uuid,
  p_to_user_id uuid,
  p_amount numeric,
  p_pool_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_expense_id uuid;
  v_existing_id uuid;
  v_actor uuid := public.current_app_user_id();
begin
  if v_actor is null then
    return jsonb_build_object(
      'success', false, 'message', 'Not authenticated', 'status', 'unauthenticated'
    );
  end if;

  if p_request_id is null or length(trim(p_request_id)) = 0 then
    return jsonb_build_object(
      'success', false, 'message', 'request_id is required', 'status', 'invalid'
    );
  end if;

  if p_household_id is null or p_from_user_id is null or p_to_user_id is null then
    return jsonb_build_object(
      'success', false, 'message', 'household and users are required', 'status', 'invalid'
    );
  end if;

  if p_amount is null or p_amount <= 0 then
    return jsonb_build_object(
      'success', false, 'message', 'amount must be greater than 0', 'status', 'invalid'
    );
  end if;

  select id into v_existing_id
  from public.expenses
  where request_id = p_request_id;

  if found then
    return jsonb_build_object(
      'success', true,
      'message', 'Already settled',
      'status', 'idempotent',
      'expense_id', v_existing_id,
      'idempotent', true
    );
  end if;

  v_expense_id := public.save_expense_v4(
    p_id          := null,
    p_household_id := p_household_id,
    p_title       := 'Liquidación de balance',
    p_amount      := p_amount,
    p_category    := 'other',
    p_paid_by     := p_from_user_id,
    p_paid_at     := now(),
    p_description := 'Saldar balance acumulado',
    p_split_type  := 'fixed',
    p_is_shared   := true,
    p_type        := 'settlement',
    p_splits      := jsonb_build_array(
                       jsonb_build_object('user_id', p_to_user_id, 'amount', p_amount)
                     ),
    p_receipt_path := null,
    p_pool_id     := p_pool_id
  );

  update public.expenses
  set request_id = p_request_id
  where id = v_expense_id;

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    v_actor,
    p_household_id,
    'settle_debt',
    'expense',
    v_expense_id,
    jsonb_build_object(
      'from_user_id', p_from_user_id,
      'to_user_id', p_to_user_id,
      'amount', p_amount,
      'pool_id', p_pool_id
    ),
    'Debt settled',
    'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Debt settled',
    'status', 'settled',
    'expense_id', v_expense_id,
    'idempotent', false
  );
exception
  when unique_violation then
    select id into v_existing_id
    from public.expenses
    where request_id = p_request_id;

    return jsonb_build_object(
      'success', true,
      'message', 'Already settled',
      'status', 'idempotent',
      'expense_id', v_existing_id,
      'idempotent', true
    );
end;
$function$;

GRANT EXECUTE ON FUNCTION public.settle_debt_v1(text, uuid, uuid, uuid, numeric, uuid) TO authenticated;

-- --------------------------------------------------------------------------
-- Detalle del fondo en un solo RPC: total, quién puso, balances del fondo y
-- últimos movimientos.
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_pool_summary_v1(p_pool_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_uid uuid := public.current_app_user_id();
  v_household_id uuid;
  v_pool jsonb;
  v_total numeric := 0;
  v_members jsonb;
  v_balances jsonb;
  v_expenses jsonb;
BEGIN
  SELECT ep.household_id,
         jsonb_build_object(
           'id', ep.id,
           'name', ep.name,
           'emoji', ep.emoji,
           'status', ep.status,
           'created_at', ep.created_at,
           'closed_at', ep.closed_at
         )
  INTO v_household_id, v_pool
  FROM public.expense_pools ep
  WHERE ep.id = p_pool_id;

  IF v_household_id IS NULL OR v_uid IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.household_members hm
    WHERE hm.household_id = v_household_id AND hm.user_id = v_uid
  ) THEN
    RETURN jsonb_build_object('found', false);
  END IF;

  SELECT COALESCE(SUM(e.amount), 0) INTO v_total
  FROM public.expenses e
  WHERE e.pool_id = p_pool_id
    AND e.type = 'expense';

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
  ) INTO v_members
  FROM (
    SELECT e.paid_by, SUM(e.amount) AS paid
    FROM public.expenses e
    WHERE e.pool_id = p_pool_id
      AND e.type = 'expense'
    GROUP BY e.paid_by
  ) p
  JOIN public.users u ON u.id = p.paid_by;

  -- Balance dentro del fondo: mismo modelo que get_expense_balance pero
  -- scoped a los movimientos del fondo (gastos + liquidaciones del fondo).
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'user_id', b.user_id,
        'name', u.full_name,
        'avatar_url', u.avatar_url,
        'balance', round(b.balance)
      )
      ORDER BY b.balance DESC
    ),
    '[]'::jsonb
  ) INTO v_balances
  FROM (
    SELECT
      COALESCE(paid.user_id, owed.user_id) AS user_id,
      COALESCE(paid.amt, 0) - COALESCE(owed.amt, 0) AS balance
    FROM (
      SELECT e.paid_by AS user_id, SUM(e.amount) AS amt
      FROM public.expenses e
      WHERE e.pool_id = p_pool_id
        AND e.type::text IN ('expense', 'settlement')
      GROUP BY 1
    ) paid
    FULL JOIN (
      SELECT es.user_id, SUM(es.amount) AS amt
      FROM public.expense_splits es
      JOIN public.expenses e ON e.id = es.expense_id
      WHERE e.pool_id = p_pool_id
        AND e.type::text IN ('expense', 'settlement')
      GROUP BY 1
    ) owed ON owed.user_id = paid.user_id
  ) b
  JOIN public.users u ON u.id = b.user_id
  WHERE abs(b.balance) > 0.01;

  SELECT COALESCE(
    jsonb_agg(x ORDER BY x->>'paid_at' DESC),
    '[]'::jsonb
  ) INTO v_expenses
  FROM (
    SELECT jsonb_build_object(
      'id', e.id,
      'title', e.title,
      'title_key', e.title_key,
      'amount', round(e.amount),
      'category', e.category,
      'type', e.type::text,
      'paid_at', e.paid_at,
      'payer_name', u.full_name
    ) AS x
    FROM public.expenses e
    LEFT JOIN public.users u ON u.id = e.paid_by
    WHERE e.pool_id = p_pool_id
    ORDER BY e.paid_at DESC
    LIMIT 50
  ) items;

  RETURN jsonb_build_object(
    'found', true,
    'pool', v_pool,
    'total', round(v_total),
    'members', v_members,
    'balances', v_balances,
    'expenses', v_expenses
  );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.get_pool_summary_v1(uuid) TO authenticated;
