-- Reconstructed from remote migration history (version 20260311154814).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Update planned_expenses RLS to handle personal/gift privacy
DROP POLICY IF EXISTS "Users can view planned expenses of their household" ON public.planned_expenses;

CREATE POLICY "Users can view planned expenses of their household" ON public.planned_expenses
FOR SELECT USING (
  (household_id IN (SELECT household_id FROM public.household_members WHERE user_id = auth.uid()))
  AND 
  (split_type NOT IN ('personal', 'gift') OR payer_default = auth.uid())
);

-- Update expense_templates RLS as well
DROP POLICY IF EXISTS "Users can view templates of their household" ON public.expense_templates;

CREATE POLICY "Users can view templates of their household" ON public.expense_templates
FOR SELECT USING (
  (household_id IN (SELECT household_id FROM public.household_members WHERE user_id = auth.uid()))
  AND 
  (split_type NOT IN ('personal', 'gift') OR payer_default = auth.uid())
);
;