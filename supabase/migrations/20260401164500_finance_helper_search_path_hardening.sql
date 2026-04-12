-- Harden helper functions introduced for recurring runtime alignment.
-- These are immutable utility functions, but we still pin search_path to
-- satisfy security linting and keep function execution deterministic.

CREATE OR REPLACE FUNCTION public.finance_clamped_monthly_due_date(
  p_anchor_date DATE,
  p_day_of_month INTEGER
)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
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
SET search_path = public
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
SET search_path = public
AS $$
BEGIN
  RETURN public.finance_clamped_monthly_due_date(
    (date_trunc('month', p_current_due)::date + interval '1 month')::date,
    p_day_of_month
  );
END;
$$;
