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

  IF to_regprocedure('public.save_expense_v4(uuid,uuid,text,numeric,text,uuid,timestamp with time zone,text,text,boolean,text,jsonb,text,uuid)') IS NULL THEN
    RAISE EXCEPTION 'Missing function: public.save_expense_v4(..., p_receipt_path text, p_pool_id uuid)';
  END IF;

  IF to_regprocedure('public.get_home_bootstrap(integer,integer,integer)') IS NULL THEN
    RAISE EXCEPTION 'Missing function: public.get_home_bootstrap(integer,integer,integer)';
  END IF;

  IF to_regprocedure('public.pay_planned_expense(uuid,numeric,timestamp with time zone,text)') IS NULL THEN
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

-- ─────────────────────────────────────────────────────────────────────────────
-- Critical-flow RPC coverage (AGENTS.md smoke checklist).
-- Checked by NAME (not full signature) so the gate is robust to the frequent
-- argument-overload churn these functions go through. Each name maps to a flow
-- the app cannot live without:
--   complete_task_v1            → completar una tarea normal / recurrente
--   approve_task_v1             → aprobar/verificar una tarea pendiente
--   get_combined_feed           → cargar el feed de finanzas
--   save_expense_v4             → registrar un gasto
--   upsert_catalog_request      → usar el catálogo de shopping
--   join_household_by_code      → onboarding / linking de hogar
--   settle_debt_v1              → saldar un balance (idempotente por request_id)
--   process_recurring_expenses  → materializar planned/recurring del mes
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  v_name text;
  v_required text[] := ARRAY[
    'complete_task_v1',
    'approve_task_v1',
    'reject_task_v1',
    'get_pending_approvals',
    'update_member_task_approval',
    'get_combined_feed',
    'save_expense_v4',
    'upsert_catalog_request',
    'join_household_by_code',
    'settle_debt_v1',
    'process_recurring_expenses'
  ];
BEGIN
  FOREACH v_name IN ARRAY v_required LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = 'public' AND p.proname = v_name
    ) THEN
      RAISE EXCEPTION 'Missing critical RPC: public.% (AGENTS.md smoke checklist)', v_name;
    END IF;
  END LOOP;
END $$;

-- Mutation RPCs must NOT be executable by anon. A regression here means an
-- unauthenticated caller could complete tasks / mutate finance state.
DO $$
DECLARE
  v_proc oid;
  v_name text;
  v_mutating text[] := ARRAY[
    'complete_task_v1',
    'approve_task_v1',
    'reject_task_v1',
    'update_member_task_approval',
    'upsert_catalog_request',
    'settle_debt_v1'
  ];
BEGIN
  FOREACH v_name IN ARRAY v_mutating LOOP
    FOR v_proc IN
      SELECT p.oid
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = 'public' AND p.proname = v_name
    LOOP
      IF has_function_privilege('anon', v_proc, 'EXECUTE') THEN
        RAISE EXCEPTION 'Security regression: anon can EXECUTE public.% — revoke anon grant', v_name;
      END IF;
    END LOOP;
  END LOOP;
END $$;

-- Row Level Security must stay ENABLED on every sensitive table. Disabling RLS
-- (even briefly via a migration) exposes cross-household data.
DO $$
DECLARE
  v_table text;
  v_sensitive text[] := ARRAY[
    'expenses',
    'expense_splits',
    'households',
    'household_members',
    'tasks',
    'notifications',
    'planned_expenses',
    'expense_templates',
    'user_feedback'
  ];
BEGIN
  FOREACH v_table IN ARRAY v_sensitive LOOP
    -- Only assert on tables that exist in this database.
    IF EXISTS (
      SELECT 1 FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public' AND c.relname = v_table AND c.relkind = 'r'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relname = v_table AND c.relrowsecurity
      ) THEN
        RAISE EXCEPTION 'RLS is DISABLED on sensitive table public.%', v_table;
      END IF;
    END IF;
  END LOOP;
END $$;
