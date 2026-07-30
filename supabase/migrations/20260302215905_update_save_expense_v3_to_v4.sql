-- Reconstructed from remote migration history (version 20260302215905).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.save_expense_v4(
  p_id uuid DEFAULT NULL::uuid, 
  p_household_id uuid DEFAULT NULL::uuid, 
  p_title text DEFAULT NULL::text, 
  p_amount numeric DEFAULT NULL::numeric, 
  p_category text DEFAULT NULL::text, 
  p_paid_by uuid DEFAULT NULL::uuid, 
  p_paid_at timestamp with time zone DEFAULT NULL::timestamp with time zone, 
  p_description text DEFAULT NULL::text, 
  p_split_type text DEFAULT NULL::text, 
  p_is_shared boolean DEFAULT true, 
  p_type text DEFAULT 'expense',
  p_splits jsonb DEFAULT NULL::jsonb
)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_expense_id UUID;
  v_split RECORD;
BEGIN
  IF p_id IS NULL THEN
    -- CREATE
    INSERT INTO public.expenses (
      household_id, created_by_id, title, amount, category, 
      paid_by, paid_at, description, split_type, is_shared, type, updated_at
    ) VALUES (
      p_household_id, auth.uid(), p_title, p_amount, p_category,
      p_paid_by, COALESCE(p_paid_at, NOW()), p_description, p_split_type, p_is_shared, p_type::public.transaction_type, NOW()
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
      type = COALESCE(p_type::public.transaction_type, type),
      updated_at = NOW()
    WHERE id = v_expense_id;
    
    -- Clear old splits
    DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
  END IF;

  -- Insert splits (Only if it's an expense and shared, or if explicitly provided)
  IF p_splits IS NOT NULL AND jsonb_array_length(p_splits) > 0 THEN
    FOR v_split IN SELECT * FROM jsonb_to_recordset(p_splits) AS x(user_id UUID, amount DECIMAL)
    LOOP
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, v_split.user_id, v_split.amount);
    END LOOP;
  END IF;

  RETURN v_expense_id;
END;
$function$;
;