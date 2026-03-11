-- 1. Create expense_templates table
CREATE TABLE IF NOT EXISTS public.expense_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    default_amount NUMERIC NOT NULL,
    category TEXT,
    frequency TEXT DEFAULT 'monthly',
    day_of_month INTEGER NOT NULL CHECK (day_of_month >= 1 AND day_of_month <= 31),
    split_type TEXT NOT NULL,
    payer_default UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create planned_expenses table
CREATE TABLE IF NOT EXISTS public.planned_expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    template_id UUID REFERENCES public.expense_templates(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    category TEXT,
    split_type TEXT NOT NULL,
    payer_default UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    due_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'skipped')),
    expense_id UUID REFERENCES public.expenses(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Modify expenses table
ALTER TABLE public.expenses
ADD COLUMN IF NOT EXISTS planned_expense_id UUID REFERENCES public.planned_expenses(id) ON DELETE SET NULL;

-- 4. Add constraints and indexes
ALTER TABLE public.planned_expenses
DROP CONSTRAINT IF EXISTS unique_template_due_date;

ALTER TABLE public.planned_expenses
ADD CONSTRAINT unique_template_due_date UNIQUE (template_id, due_date);

CREATE INDEX IF NOT EXISTS idx_planned_expenses_feed ON public.planned_expenses (household_id, due_date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_feed ON public.expenses (household_id, paid_at DESC);

-- 5. Enable RLS
ALTER TABLE public.expense_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.planned_expenses ENABLE ROW LEVEL SECURITY;

-- 6. Add Policies (Drop first to avoid errors if they exist)
DROP POLICY IF EXISTS "Users can view templates of their household" ON public.expense_templates;
CREATE POLICY "Users can view templates of their household" ON public.expense_templates
    FOR SELECT USING (auth.uid() IN (SELECT user_id FROM public.household_members WHERE household_id = public.expense_templates.household_id));

DROP POLICY IF EXISTS "Users can insert templates to their household" ON public.expense_templates;
CREATE POLICY "Users can insert templates to their household" ON public.expense_templates
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT user_id FROM public.household_members WHERE household_id = public.expense_templates.household_id));

DROP POLICY IF EXISTS "Users can update templates of their household" ON public.expense_templates;
CREATE POLICY "Users can update templates of their household" ON public.expense_templates
    FOR UPDATE USING (auth.uid() IN (SELECT user_id FROM public.household_members WHERE household_id = public.expense_templates.household_id));


DROP POLICY IF EXISTS "Users can view planned expenses of their household" ON public.planned_expenses;
CREATE POLICY "Users can view planned expenses of their household" ON public.planned_expenses
    FOR SELECT USING (auth.uid() IN (SELECT user_id FROM public.household_members WHERE household_id = public.planned_expenses.household_id));

DROP POLICY IF EXISTS "Users can insert planned expenses to their household" ON public.planned_expenses;
CREATE POLICY "Users can insert planned expenses to their household" ON public.planned_expenses
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT user_id FROM public.household_members WHERE household_id = public.planned_expenses.household_id));

DROP POLICY IF EXISTS "Users can update planned expenses of their household" ON public.planned_expenses;
CREATE POLICY "Users can update planned expenses of their household" ON public.planned_expenses
    FOR UPDATE USING (auth.uid() IN (SELECT user_id FROM public.household_members WHERE household_id = public.planned_expenses.household_id));


-- 7. Combined Feed Function
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
    WHERE e.household_id = p_household_id AND (e.type = 'expense' OR e.type = 'settlement')

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
    WHERE pe.household_id = p_household_id AND pe.status != 'paid'

    ORDER BY date DESC, id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
