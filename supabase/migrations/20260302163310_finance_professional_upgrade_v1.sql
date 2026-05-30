-- Reconstructed from remote migration history (version 20260302163310).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Add is_shared column if it doesn't exist
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'is_shared') THEN
    ALTER TABLE public.expenses ADD COLUMN is_shared BOOLEAN DEFAULT TRUE;
  END IF;
END $$;

-- Update RLS Policies for Privacy
DROP POLICY IF EXISTS "Users can view household expenses" ON public.expenses;
CREATE POLICY "Users can view household expenses"
  ON public.expenses FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.household_members 
      WHERE user_id = auth.uid()
    )
    AND (is_shared = true OR created_by_id = auth.uid())
  );

DROP POLICY IF EXISTS "Users can view expense splits" ON public.expense_splits;
CREATE POLICY "Users can view expense splits"
  ON public.expense_splits FOR SELECT
  USING (
    expense_id IN (
      SELECT id FROM public.expenses 
      WHERE (is_shared = true OR created_by_id = auth.uid())
    )
  );

-- Professional Saving RPC (Atomic Transaction)
CREATE OR REPLACE FUNCTION public.save_expense_v3(
  p_id UUID DEFAULT NULL,
  p_household_id UUID DEFAULT NULL,
  p_title TEXT DEFAULT NULL,
  p_amount DECIMAL DEFAULT NULL,
  p_category TEXT DEFAULT NULL,
  p_paid_by UUID DEFAULT NULL,
  p_paid_at TIMESTAMPTZ DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_split_type TEXT DEFAULT NULL,
  p_is_shared BOOLEAN DEFAULT TRUE,
  p_splits JSONB DEFAULT NULL -- Array of {user_id: UUID, amount: DECIMAL}
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expense_id UUID;
  v_split RECORD;
BEGIN
  IF p_id IS NULL THEN
    -- CREATE
    INSERT INTO public.expenses (
      household_id, created_by_id, title, amount, category, 
      paid_by, paid_at, description, split_type, is_shared, updated_at
    ) VALUES (
      p_household_id, auth.uid(), p_title, p_amount, p_category,
      p_paid_by, COALESCE(p_paid_at, NOW()), p_description, p_split_type, p_is_shared, NOW()
    ) RETURNING id INTO v_expense_id;
  ELSE
    -- UPDATE
    v_expense_id := p_id;
    UPDATE public.expenses SET
      title = COALESCE(p_title, title),
      amount = COALESCE(p_amount, amount),
      category = COALESCE(p_category, category),
      paid_by = COALESCE(p_paid_by, paid_by),
      paid_at = COALESCE(p_paid_at, paid_at),
      description = p_description,
      split_type = COALESCE(p_split_type, split_type),
      is_shared = COALESCE(p_is_shared, is_shared),
      updated_at = NOW()
    WHERE id = v_expense_id;
    
    -- Clear old splits
    DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
  END IF;

  -- Insert splits
  IF p_splits IS NOT NULL AND jsonb_array_length(p_splits) > 0 THEN
    FOR v_split IN SELECT * FROM jsonb_to_recordset(p_splits) AS x(user_id UUID, amount DECIMAL)
    LOOP
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, v_split.user_id, v_split.amount);
    END LOOP;
  END IF;

  RETURN v_expense_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.save_expense_v3 TO authenticated;
;