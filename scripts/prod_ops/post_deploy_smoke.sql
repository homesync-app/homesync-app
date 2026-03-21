-- Production smoke checks for HomeSync finance/security hardening.
-- This script is fail-fast: any invariant breach raises exception.

DO $$
BEGIN
  -- Core finance RPCs must exist
  IF to_regprocedure('public.get_filtered_expenses(uuid,text,text,integer,integer)') IS NULL THEN
    RAISE EXCEPTION 'Missing function: public.get_filtered_expenses(uuid,text,text,integer,integer)';
  END IF;

  IF to_regprocedure('public.get_combined_feed(uuid,integer,integer)') IS NULL THEN
    RAISE EXCEPTION 'Missing function: public.get_combined_feed(uuid,integer,integer)';
  END IF;

  IF to_regprocedure('public.get_expense_balance(uuid)') IS NULL THEN
    RAISE EXCEPTION 'Missing function: public.get_expense_balance(uuid)';
  END IF;

  IF to_regprocedure('public.save_expense_v4(uuid,uuid,text,numeric,text,uuid,timestamp with time zone,text,text,boolean,text,jsonb)') IS NULL THEN
    RAISE EXCEPTION 'Missing function: public.save_expense_v4(...)';
  END IF;

  IF to_regprocedure('public.pay_planned_expense(uuid,numeric,timestamp with time zone,uuid)') IS NULL THEN
    RAISE EXCEPTION 'Missing function: public.pay_planned_expense(...)';
  END IF;

  -- Legacy overloaded signature must not exist
  IF to_regprocedure('public.get_filtered_expenses(uuid,integer,integer,text)') IS NOT NULL THEN
    RAISE EXCEPTION 'Legacy overloaded get_filtered_expenses signature still exists';
  END IF;
END $$;

DO $$
DECLARE
  v_count integer;
BEGIN
  -- Required constraints on expenses
  SELECT count(*) INTO v_count
  FROM pg_constraint
  WHERE conrelid = 'public.expenses'::regclass
    AND conname IN (
      'expenses_split_type_allowed_chk',
      'expenses_amount_positive_chk',
      'expenses_title_not_blank_chk'
    );

  IF v_count < 3 THEN
    RAISE EXCEPTION 'Missing one or more required constraints on public.expenses';
  END IF;
END $$;

DO $$
DECLARE
  v_count integer;
BEGIN
  -- Required triggers must be enabled
  SELECT count(*) INTO v_count
  FROM pg_trigger t
  JOIN pg_class c ON c.oid = t.tgrelid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname = 'expenses'
    AND t.tgname IN (
      'trg_enforce_expense_privacy_consistency',
      'trg_validate_expense_membership_integrity',
      'on_expense_action'
    )
    AND t.tgenabled = 'O'
    AND NOT t.tgisinternal;

  IF v_count < 3 THEN
    RAISE EXCEPTION 'Missing one or more required enabled triggers on public.expenses';
  END IF;
END $$;

DO $$
DECLARE
  v_count integer;
BEGIN
  -- Required RLS policies must exist
  SELECT count(*) INTO v_count
  FROM pg_policies
  WHERE schemaname = 'public'
    AND ((tablename = 'expenses' AND policyname = 'Users can view visible household expenses')
      OR (tablename = 'expense_splits' AND policyname = 'Users can view visible expense splits')
      OR (tablename = 'mercadopago_webhooks' AND policyname = 'service_role can manage mercadopago_webhooks'));

  IF v_count < 3 THEN
    RAISE EXCEPTION 'Missing one or more required RLS policies';
  END IF;
END $$;

-- Report summary for observability
SELECT
  now() AS checked_at,
  (SELECT count(*) FROM public.expenses) AS expenses_rows,
  (SELECT count(*) FROM public.expense_splits) AS expense_splits_rows,
  (SELECT count(*) FROM pg_policies WHERE schemaname = 'public' AND tablename IN ('expenses','expense_splits')) AS relevant_policies;
