-- Security hardening phase 1
-- Focus: permissive RLS policies + mutable search_path in finance-related functions.

-- 1) households: require authenticated creator
DROP POLICY IF EXISTS "Users can create households" ON public.households;
CREATE POLICY "Users can create households"
ON public.households
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- 2) application_logs: remove anonymous/permissive write-delete
DROP POLICY IF EXISTS "Allow anyone to insert logs" ON public.application_logs;
DROP POLICY IF EXISTS "Allow authenticated users to delete logs" ON public.application_logs;

CREATE POLICY "Authenticated users can insert own logs"
ON public.application_logs
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() IS NOT NULL
  AND (user_id IS NULL OR user_id = auth.uid())
);

CREATE POLICY "Users can delete own logs"
ON public.application_logs
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- 3) categories: read-only for authenticated users
DROP POLICY IF EXISTS "Categories are CRUD for all" ON public.categories;
DROP POLICY IF EXISTS "Categories are readable by all" ON public.categories;

CREATE POLICY "Categories are readable by authenticated"
ON public.categories
FOR SELECT
TO authenticated
USING (true);

-- 4) task_templates: read-only for authenticated users
DROP POLICY IF EXISTS "Templates are CRUD for all" ON public.task_templates;

CREATE POLICY "Task templates are readable by authenticated"
ON public.task_templates
FOR SELECT
TO authenticated
USING (true);

-- 5) Fix mutable search_path on key finance functions
ALTER FUNCTION public.save_expense_v4(
  p_id uuid,
  p_household_id uuid,
  p_title text,
  p_amount numeric,
  p_category text,
  p_paid_by uuid,
  p_paid_at timestamp with time zone,
  p_description text,
  p_split_type text,
  p_is_shared boolean,
  p_type text,
  p_splits jsonb
) SET search_path = public;

ALTER FUNCTION public.get_personal_finance_summary(
  p_user_id uuid,
  p_household_id uuid
) SET search_path = public;

ALTER FUNCTION public.get_debts(
  p_household_id uuid
) SET search_path = public;

ALTER FUNCTION public.get_expense_history(
  p_household_id uuid,
  p_limit integer,
  p_offset integer
) SET search_path = public;

ALTER FUNCTION public.settle_debt(
  p_user_id uuid,
  p_household_id uuid,
  p_to_user_id uuid,
  p_amount numeric
) SET search_path = public;

ALTER FUNCTION public.process_recurring_expenses(
  p_household_id uuid
) SET search_path = public;

ALTER FUNCTION public.ensure_planned_expenses()
SET search_path = public;

ALTER FUNCTION public.ensure_planned_expenses(
  p_household_id uuid
) SET search_path = public;

ALTER FUNCTION public.get_filtered_expenses(
  p_household_id uuid,
  p_type text,
  p_sharing text,
  p_limit integer,
  p_offset integer
) SET search_path = public;

ALTER FUNCTION public.get_combined_feed(
  p_household_id uuid,
  p_limit integer,
  p_offset integer
) SET search_path = public;

ALTER FUNCTION public.get_expense_balance(
  p_household_id uuid
) SET search_path = public;

ALTER FUNCTION public.pay_planned_expense(
  p_planned_id uuid,
  p_amount numeric,
  p_paid_at timestamp with time zone,
  p_paid_by uuid
) SET search_path = public;
