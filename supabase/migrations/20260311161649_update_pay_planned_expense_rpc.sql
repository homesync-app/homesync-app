-- Reconstructed from remote migration history (version 20260311161649).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.pay_planned_expense(
  p_planned_id UUID,
  p_amount NUMERIC,
  p_paid_by UUID,
  p_paid_at TIMESTAMPTZ DEFAULT NOW()
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_planned RECORD;
  v_expense_id UUID;
BEGIN
  -- Get planned expense
  SELECT * INTO v_planned FROM public.planned_expenses WHERE id = p_planned_id AND status = 'pending';
  
  IF v_planned.id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Gasto planeado no encontrado o ya pagado');
  END IF;

  -- Create the actual expense using save_expense_v4
  SELECT public.save_expense_v4(
    NULL, -- p_id
    v_planned.household_id, 
    v_planned.title, 
    p_amount, 
    v_planned.category, 
    p_paid_by, 
    COALESCE(p_paid_at, NOW()), 
    NULL, -- p_description
    v_planned.split_type, 
    true, -- p_is_shared (save_expense_v4 handles true logic for everything except personal)
    'expense', 
    NULL -- p_splits
  ) INTO v_expense_id;

  -- Update planned_expense
  UPDATE public.planned_expenses
  SET status = 'paid', expense_id = v_expense_id
  WHERE id = p_planned_id;

  -- Handle template updates if amount changed
  IF v_planned.template_id IS NOT NULL AND p_amount != v_planned.amount THEN
    -- Update template amount
    UPDATE public.expense_templates
    SET default_amount = p_amount
    WHERE id = v_planned.template_id;

    -- Update future pending expenses for this template
    UPDATE public.planned_expenses
    SET amount = p_amount
    WHERE template_id = v_planned.template_id AND status = 'pending';

    -- Insert into history
    INSERT INTO public.expense_template_history (template_id, amount, start_date)
    VALUES (v_planned.template_id, p_amount, CURRENT_DATE);
  END IF;

  RETURN jsonb_build_object('success', true, 'expense_id', v_expense_id);
END;
$$;
