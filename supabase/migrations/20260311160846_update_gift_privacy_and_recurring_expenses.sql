-- Reconstructed from remote migration history (version 20260311160846).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Fix Privacy Policies: Treat 'gift' as shared
DROP POLICY IF EXISTS "Users can view planned expenses of their household" ON public.planned_expenses;
CREATE POLICY "Users can view planned expenses of their household" ON public.planned_expenses
FOR SELECT USING (
  (household_id IN (SELECT household_id FROM public.household_members WHERE user_id = auth.uid()))
  AND 
  (split_type != 'personal' OR payer_default = auth.uid())
);

DROP POLICY IF EXISTS "Users can view templates of their household" ON public.expense_templates;
CREATE POLICY "Users can view templates of their household" ON public.expense_templates
FOR SELECT USING (
  (household_id IN (SELECT household_id FROM public.household_members WHERE user_id = auth.uid()))
  AND 
  (split_type != 'personal' OR payer_default = auth.uid())
);

-- Fix get_combined_feed to not exclude 'gift'
DROP FUNCTION IF EXISTS get_combined_feed(uuid, integer, integer);
CREATE OR REPLACE FUNCTION get_combined_feed(p_household_id UUID, p_limit INTEGER DEFAULT 20, p_offset INTEGER DEFAULT 0)
RETURNS TABLE (
    record_type TEXT,
    id UUID,
    title TEXT,
    amount NUMERIC,
    category TEXT,
    split_type TEXT,
    payer_id UUID,
    date TIMESTAMP WITH TIME ZONE,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Real Expenses
    SELECT 
        'expense'::TEXT as record_type,
        e.id,
        e.title,
        e.amount,
        e.category,
        e.split_type,
        e.paid_by as payer_id,
        e.paid_at as date,
        'paid'::TEXT as status
    FROM public.expenses e
    WHERE e.household_id = p_household_id 
      AND (e.type = 'expense' OR e.type = 'settlement')
      AND (e.is_shared = true OR e.paid_by = auth.uid())

    UNION ALL

    -- Planned Expenses (Pending or Skipped)
    SELECT 
        'planned'::TEXT as record_type,
        pe.id,
        pe.title,
        pe.amount,
        pe.category,
        pe.split_type,
        pe.payer_default as payer_id,
        pe.due_date::TIMESTAMP WITH TIME ZONE as date,
        pe.status
    FROM public.planned_expenses pe
    WHERE pe.household_id = p_household_id 
      AND pe.status != 'paid'
      AND (pe.split_type != 'personal' OR pe.payer_default = auth.uid())

    ORDER BY date DESC, id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 2. Schema changes for Recurring Expenses (Templates)
ALTER TABLE public.expense_templates
ADD COLUMN IF NOT EXISTS start_date DATE DEFAULT CURRENT_DATE,
ADD COLUMN IF NOT EXISTS next_execution_date DATE DEFAULT CURRENT_DATE;

-- Fill existing template next_execution_date if null
UPDATE public.expense_templates 
SET start_date = CURRENT_DATE, next_execution_date = CURRENT_DATE 
WHERE next_execution_date IS NULL;

-- 3. Create expense_template_history table
CREATE TABLE IF NOT EXISTS public.expense_template_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID NOT NULL REFERENCES public.expense_templates(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    start_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.expense_template_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view template history of their household" ON public.expense_template_history
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.expense_templates t 
    WHERE t.id = expense_template_history.template_id 
    AND t.household_id IN (SELECT household_id FROM public.household_members WHERE user_id = auth.uid())
  )
);

CREATE POLICY "Users can insert template history to their household" ON public.expense_template_history
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.expense_templates t 
    WHERE t.id = expense_template_history.template_id 
    AND t.household_id IN (SELECT household_id FROM public.household_members WHERE user_id = auth.uid())
  )
);

-- Insert initial history for all existing templates
INSERT INTO public.expense_template_history (template_id, amount, start_date)
SELECT id, default_amount, start_date
FROM public.expense_templates
ON CONFLICT DO NOTHING;
;