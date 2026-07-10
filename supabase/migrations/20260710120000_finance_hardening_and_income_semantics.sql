-- Finanzas: endurecimiento + semántica de ingresos coherente por tipo de hogar.
--
-- 1) DROP del overload legacy de save_expense_v4 (12 args, sin p_is_shared):
--    SECURITY DEFINER sin chequeo de membresía y con upsert por id sin validar
--    dueño → cualquier autenticado podía insertar gastos en hogares ajenos o
--    pisar un gasto existente conociendo su UUID. Además escribía columnas de
--    expense_splits que ya no existen (share_amount/share_percentage). Nadie
--    lo llama: cliente, offline queue y settle_debt_v1 usan la firma con
--    p_is_shared.
--
-- 2) planned_expenses.type: las plantillas recurrentes soportan ingresos
--    (p. ej. sueldo mensual) pero el pipeline planificado perdía el tipo y al
--    "pagar" un ingreso planificado se registraba un GASTO. Ahora el tipo
--    viaja plantilla → planificado → feed → movimiento real.
--
-- 3) pay_planned_expense: lock FOR UPDATE + guard de estado (evita pago doble
--    por doble-tap, cliente desactualizado o carrera entre dos miembros),
--    validación de monto, propagación de type/title_key y backlink
--    planned_expenses.expense_id.
--
-- 4) get_expense_balance: los ingresos quedan FUERA del balance de deudas.
--    Un ingreso compartido creaba deuda invertida (quien cobraba quedaba como
--    acreedor). Las deudas se derivan solo de gastos y liquidaciones.
--
-- 5) get_personal_finance_summary: en economía dividida un ingreso compartido
--    se reparte por splits (igual que los gastos); antes acreditaba el monto
--    completo solo a quien lo cobró y 0 al resto.
--
-- 6) Recordatorios de pagos planificados: solo type='expense' (un sueldo no
--    "vence").

-- ---------------------------------------------------------------------------
-- 1) Drop del overload legacy inseguro.
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.save_expense_v4(
  p_household_id uuid,
  p_title text,
  p_amount numeric,
  p_category text,
  p_paid_by uuid,
  p_type text,
  p_description text,
  p_split_type text,
  p_splits jsonb,
  p_paid_at timestamp with time zone,
  p_id uuid,
  p_receipt_path text
);

-- ---------------------------------------------------------------------------
-- 2) planned_expenses.type
-- ---------------------------------------------------------------------------
ALTER TABLE public.planned_expenses
  ADD COLUMN IF NOT EXISTS type text NOT NULL DEFAULT 'expense';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'planned_expenses_type_check'
      AND conrelid = 'public.planned_expenses'::regclass
  ) THEN
    ALTER TABLE public.planned_expenses
      ADD CONSTRAINT planned_expenses_type_check
      CHECK (type IN ('expense', 'income'));
  END IF;
END $$;

-- Backfill: planificados ya generados desde plantillas de ingreso.
UPDATE public.planned_expenses pe
SET type = 'income'
FROM public.expense_templates et
WHERE et.id = pe.template_id
  AND et.type = 'income'
  AND pe.type <> 'income';

-- El generador de planificados arrastra el tipo de la plantilla.
CREATE OR REPLACE FUNCTION public.finance_process_recurring_expenses_internal(p_household_id uuid)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'public'
AS $function$
declare
  v_horizon date := (
    date_trunc('month', current_date)::date + interval '2 month - 1 day'
  )::date;
  template_row record;
  v_next_due date;
begin
  for template_row in
    select *
    from public.expense_templates
    where household_id = p_household_id
      and is_active = true
      and coalesce(frequency, 'monthly') = 'monthly'
    order by created_at asc
  loop
    v_next_due := coalesce(
      template_row.next_execution_date::date,
      public.finance_first_valid_monthly_due_date(current_date, template_row.day_of_month)
    );

    while v_next_due <= v_horizon loop
      insert into public.planned_expenses (
        household_id,
        template_id,
        title,
        title_key,
        amount,
        category,
        split_type,
        payer_default,
        due_date,
        status,
        type
      ) values (
        template_row.household_id,
        template_row.id,
        template_row.title,
        template_row.title_key,
        template_row.default_amount,
        template_row.category,
        template_row.split_type,
        template_row.payer_default,
        v_next_due,
        'pending',
        coalesce(template_row.type, 'expense')
      )
      on conflict (template_id, due_date) do nothing;

      v_next_due := public.finance_next_monthly_due_date(
        v_next_due,
        template_row.day_of_month
      );
    end loop;

    update public.expense_templates
    set
      next_execution_date = v_next_due::timestamptz,
      updated_at = timezone('utc'::text, now())
    where id = template_row.id
      and next_execution_date is distinct from v_next_due::timestamptz;
  end loop;
end;
$function$;

-- El feed expone el tipo real del planificado (antes 'expense' hardcodeado).
CREATE OR REPLACE FUNCTION public.get_combined_feed(p_household_id uuid, p_limit integer DEFAULT 20, p_offset integer DEFAULT 0)
RETURNS TABLE(record_type text, transaction_type text, id uuid, title text, title_key text, amount numeric, category text, split_type text, payer_id uuid, payer_email text, payer_full_name text, payer_avatar_url text, date timestamp with time zone, status text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := public.current_app_user_id();
begin
  if v_uid is null then
    return;
  end if;

  if not public.is_current_household_member(p_household_id) then
    return;
  end if;

  return query
  select
    'expense'::text as record_type,
    e.type::text as transaction_type,
    e.id,
    e.title,
    e.title_key,
    e.amount,
    e.category,
    e.split_type,
    e.paid_by as payer_id,
    u.email as payer_email,
    u.full_name as payer_full_name,
    u.avatar_url as payer_avatar_url,
    e.paid_at as date,
    'paid'::text as status
  from public.expenses e
  left join public.users u on u.id = e.paid_by
  where e.household_id = p_household_id
    and e.type in ('expense', 'income', 'settlement')
    and (
      coalesce(
        e.is_shared,
        case
          when lower(coalesce(e.split_type, 'equal')) in ('personal', 'gift') then false
          else true
        end
      ) = true
      or e.paid_by = v_uid
      or e.created_by_id = v_uid
    )

  union all

  select
    'planned'::text as record_type,
    coalesce(pe.type, 'expense')::text as transaction_type,
    pe.id,
    pe.title,
    pe.title_key,
    pe.amount,
    pe.category,
    pe.split_type,
    pe.payer_default as payer_id,
    u.email as payer_email,
    u.full_name as payer_full_name,
    u.avatar_url as payer_avatar_url,
    pe.due_date::timestamptz as date,
    pe.status
  from public.planned_expenses pe
  left join public.users u on u.id = pe.payer_default
  where pe.household_id = p_household_id
    and pe.status = 'pending'
    and (
      lower(coalesce(pe.split_type, 'equal')) not in ('personal', 'gift')
      or pe.payer_default = v_uid
    )

  order by date desc, id desc
  limit p_limit
  offset p_offset;
end;
$function$;

-- ---------------------------------------------------------------------------
-- 3) pay_planned_expense endurecido.
-- ---------------------------------------------------------------------------
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
  v_title_key TEXT;
  v_category TEXT;
  v_split_type TEXT;
  v_type TEXT;
  v_status TEXT;
  v_is_shared BOOLEAN;
  v_ratio NUMERIC;
  v_anchor UUID;
  v_split_member_count INT;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
  END IF;

  IF p_amount IS NULL OR p_amount <= 0 THEN
    RETURN jsonb_build_object('success', false, 'message', 'Amount must be greater than 0');
  END IF;

  -- Lock: dos pagos concurrentes del mismo planificado se serializan acá y el
  -- segundo cae en el guard de estado de abajo en vez de duplicar el gasto.
  SELECT pe.household_id, h.household_type, pe.title, pe.title_key, pe.category,
         pe.split_type, coalesce(pe.type, 'expense'), pe.status
  INTO v_household_id, v_household_type, v_title, v_title_key, v_category,
       v_split_type, v_type, v_status
  FROM public.planned_expenses pe
  JOIN public.households h ON h.id = pe.household_id
  WHERE pe.id = p_planned_id
  FOR UPDATE OF pe;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Planned expense not found');
  END IF;

  IF v_status <> 'pending' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Planned expense already processed');
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
    household_id, created_by_id, title, title_key, amount, category, paid_by,
    paid_at, type, split_type, is_shared, planned_expense_id
  ) VALUES (
    v_household_id, v_uid, v_title, v_title_key, p_amount, v_category,
    v_payer_uuid, p_paid_at, v_type::public.transaction_type,
    coalesce(v_split_type, 'equal'), v_is_shared, p_planned_id
  ) RETURNING id INTO v_expense_id;

  UPDATE public.planned_expenses
  SET status = 'paid',
      expense_id = v_expense_id
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

-- ---------------------------------------------------------------------------
-- 4) get_expense_balance sin ingresos.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_expense_balance(p_household_id uuid)
RETURNS TABLE(user_id uuid, user_email text, user_full_name text, balance numeric, avatar_url text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := public.current_app_user_id();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN;
  END IF;

  RETURN QUERY
  WITH members AS (
    SELECT u.id, u.email, u.full_name, u.avatar_url
    FROM public.users u
    JOIN public.household_members hm ON hm.user_id = u.id
    WHERE hm.household_id = p_household_id
  ),
  -- Solo gastos y liquidaciones generan deuda. Un ingreso compartido NO es
  -- plata que alguien puso por el hogar: sumarlo invertía el balance (quien
  -- cobraba quedaba como acreedor de su propio ingreso).
  paid AS (
    SELECT e.paid_by AS user_id, SUM(e.amount) AS total_paid
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND e.type::text IN ('expense', 'settlement')
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
    GROUP BY e.paid_by
  ),
  owed AS (
    SELECT es.user_id, SUM(es.amount) AS total_owed
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND e.type::text IN ('expense', 'settlement')
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
    GROUP BY es.user_id
  )
  SELECT
    m.id AS user_id,
    m.email AS user_email,
    m.full_name AS user_full_name,
    COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0) AS balance,
    m.avatar_url
  FROM members m
  LEFT JOIN paid p ON p.user_id = m.id
  LEFT JOIN owed o ON o.user_id = m.id
  ORDER BY balance DESC;
END;
$function$;

-- ---------------------------------------------------------------------------
-- 5) get_personal_finance_summary: ingresos compartidos por splits en
--    economía dividida (simétrico a los gastos).
-- ---------------------------------------------------------------------------
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
  -- Privacidad: solo miembros del hogar, y solo el propio resumen
  -- (v_user reemplaza a p_user_id en todas las queries).
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

  -- Ledger de por vida (stock de premios/ajustes en moneda real).
  SELECT COALESCE(SUM(amount), 0) INTO v_ledger
  FROM public.ledger_entries
  WHERE user_id = v_user
    AND household_id = p_household_id
    AND (currency IS NULL OR (currency <> 'XP' AND currency <> 'COIN'));

  -- Ingresos del mes. Economía integrada: todos los del hogar. Dividida: los
  -- propios no compartidos a monto completo + MI parte de los compartidos
  -- (splits, con fallback a partes iguales para legacy sin splits) — espejo
  -- exacto de cómo se computan los gastos más abajo.
  IF v_shared_economy THEN
    SELECT COALESCE(SUM(e.amount), 0) INTO v_income
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND e.type = 'income'
      AND e.paid_at >= v_start
      AND e.paid_at < v_end;
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
    -- Mi parte de los compartidos del mes (los pague quien los pague).
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

-- ---------------------------------------------------------------------------
-- 6) Recordatorios: solo planificados de gasto.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.generate_planned_payment_reminders_v1()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_upcoming integer := 0;
  v_due integer := 0;
begin
  with premium_households as (
    select h.id
    from public.households h
    where h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
    union
    select hm.household_id
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    where coalesce(u.is_premium, false) = true
      and (u.premium_until is null or u.premium_until > now())
  ),
  candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join premium_households ph on ph.id = pe.household_id
    where pe.status = 'pending'
      and coalesce(pe.type, 'expense') = 'expense'
      and pe.due_date = current_date + 3
  ),
  recipients as (
    select c.id, c.household_id, c.title, c.amount, c.due_date, hm.user_id
    from candidates c
    join public.household_members hm on hm.household_id = c.household_id
    where coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
      and (c.payer_default is null or hm.user_id = c.payer_default)
  ),
  inserted as (
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id, params
    )
    select
      r.household_id,
      r.user_id,
      'Pago proximo: ' || r.title,
      'Vence el ' || to_char(r.due_date, 'DD/MM')
        || ' - $' || to_char(r.amount, 'FM999999990'),
      'planned_payment_upcoming',
      'planned_expense',
      r.id,
      jsonb_build_object(
        'expense_title', r.title,
        'amount', r.amount,
        'due_date', r.due_date
      )
    from recipients r
    where not exists (
      select 1
      from public.notifications n
      where n.type = 'planned_payment_upcoming'
        and n.related_entity_id = r.id
        and n.user_id = r.user_id
    )
    returning 1
  )
  select count(*) into v_upcoming from inserted;

  with premium_households as (
    select h.id
    from public.households h
    where h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
    union
    select hm.household_id
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    where coalesce(u.is_premium, false) = true
      and (u.premium_until is null or u.premium_until > now())
  ),
  candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join premium_households ph on ph.id = pe.household_id
    where pe.status = 'pending'
      and coalesce(pe.type, 'expense') = 'expense'
      and pe.due_date = current_date
  ),
  recipients as (
    select c.id, c.household_id, c.title, c.amount, c.due_date, hm.user_id
    from candidates c
    join public.household_members hm on hm.household_id = c.household_id
    where coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
      and (c.payer_default is null or hm.user_id = c.payer_default)
  ),
  inserted as (
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id, params
    )
    select
      r.household_id,
      r.user_id,
      'Vence hoy: ' || r.title,
      'Registralo desde Finanzas cuando lo pagues - $'
        || to_char(r.amount, 'FM999999990'),
      'planned_payment_due',
      'planned_expense',
      r.id,
      jsonb_build_object(
        'expense_title', r.title,
        'amount', r.amount,
        'due_date', r.due_date
      )
    from recipients r
    where not exists (
      select 1
      from public.notifications n
      where n.type = 'planned_payment_due'
        and n.related_entity_id = r.id
        and n.user_id = r.user_id
    )
    returning 1
  )
  select count(*) into v_due from inserted;

  return jsonb_build_object(
    'success', true,
    'upcoming', v_upcoming,
    'due_today', v_due,
    'run_date', current_date
  );
end;
$function$;
