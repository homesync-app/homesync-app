-- Align recurring runtime contract with documented HomeSync behavior.
-- Goals:
-- 1. Make next_execution_date a first-class DB field.
-- 2. Version the process_recurring_expenses runtime contract in migrations.
-- 3. Avoid implicit backfill for newly created recurring templates.

ALTER TABLE public.expense_templates
ADD COLUMN IF NOT EXISTS next_execution_date TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_expense_templates_household_active_next_execution
ON public.expense_templates (household_id, is_active, next_execution_date);

CREATE OR REPLACE FUNCTION public.finance_clamped_monthly_due_date(
  p_anchor_date DATE,
  p_day_of_month INTEGER
)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_month_start DATE := date_trunc('month', p_anchor_date)::date;
  v_last_day INTEGER := extract(
    day from (date_trunc('month', p_anchor_date)::date + interval '1 month - 1 day')
  )::integer;
  v_safe_day INTEGER := least(greatest(p_day_of_month, 1), v_last_day);
BEGIN
  RETURN (v_month_start + ((v_safe_day - 1) * interval '1 day'))::date;
END;
$$;

CREATE OR REPLACE FUNCTION public.finance_first_valid_monthly_due_date(
  p_reference_date DATE,
  p_day_of_month INTEGER
)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_current_due DATE := public.finance_clamped_monthly_due_date(
    p_reference_date,
    p_day_of_month
  );
BEGIN
  IF v_current_due >= p_reference_date THEN
    RETURN v_current_due;
  END IF;

  RETURN public.finance_clamped_monthly_due_date(
    (date_trunc('month', p_reference_date)::date + interval '1 month')::date,
    p_day_of_month
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.finance_next_monthly_due_date(
  p_current_due DATE,
  p_day_of_month INTEGER
)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  RETURN public.finance_clamped_monthly_due_date(
    (date_trunc('month', p_current_due)::date + interval '1 month')::date,
    p_day_of_month
  );
END;
$$;

-- Backfill next_execution_date without creating implicit overdue debt.
-- Existing templates with no explicit next_execution_date start from the first
-- valid occurrence from today onward.
UPDATE public.expense_templates t
SET
  next_execution_date = public.finance_first_valid_monthly_due_date(
    CURRENT_DATE,
    t.day_of_month
  )::timestamptz,
  updated_at = timezone('utc'::text, now())
WHERE t.is_active = true
  AND t.next_execution_date IS NULL
  AND coalesce(t.frequency, 'monthly') = 'monthly';

DROP FUNCTION IF EXISTS public.process_recurring_expenses(UUID);
CREATE OR REPLACE FUNCTION public.process_recurring_expenses(
  p_household_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := public.current_app_user_id();
  v_horizon DATE := (
    date_trunc('month', CURRENT_DATE)::date + interval '2 month - 1 day'
  )::date;
  template_row RECORD;
  v_next_due DATE;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT public.is_current_household_member(p_household_id) THEN
    RAISE EXCEPTION 'User is not a member of this household';
  END IF;

  FOR template_row IN
    SELECT *
    FROM public.expense_templates
    WHERE household_id = p_household_id
      AND is_active = true
      AND coalesce(frequency, 'monthly') = 'monthly'
    ORDER BY created_at ASC
  LOOP
    v_next_due := coalesce(
      template_row.next_execution_date::date,
      public.finance_first_valid_monthly_due_date(CURRENT_DATE, template_row.day_of_month)
    );

    WHILE v_next_due <= v_horizon LOOP
      INSERT INTO public.planned_expenses (
        household_id,
        template_id,
        title,
        amount,
        category,
        split_type,
        payer_default,
        due_date,
        status
      ) VALUES (
        template_row.household_id,
        template_row.id,
        template_row.title,
        template_row.default_amount,
        template_row.category,
        template_row.split_type,
        template_row.payer_default,
        v_next_due,
        'pending'
      )
      ON CONFLICT (template_id, due_date) DO NOTHING;

      v_next_due := public.finance_next_monthly_due_date(
        v_next_due,
        template_row.day_of_month
      );
    END LOOP;

    UPDATE public.expense_templates
    SET
      next_execution_date = v_next_due::timestamptz,
      updated_at = timezone('utc'::text, now())
    WHERE id = template_row.id
      AND next_execution_date IS DISTINCT FROM v_next_due::timestamptz;
  END LOOP;
END;
$$;

GRANT EXECUTE ON FUNCTION public.process_recurring_expenses(UUID) TO authenticated;
