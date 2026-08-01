-- Reconstructed from remote migration history (version 20260311161030).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- 1. Fix save_expense_v4 to not make 'gift' private
CREATE OR REPLACE FUNCTION public.save_expense_v4(
    p_id UUID DEFAULT NULL,
    p_household_id UUID DEFAULT NULL,
    p_title TEXT DEFAULT NULL,
    p_amount DECIMAL DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_paid_by UUID DEFAULT NULL,
    p_paid_at TIMESTAMPTZ DEFAULT NOW(),
    p_description TEXT DEFAULT NULL,
    p_split_type TEXT DEFAULT 'equal',
    p_is_shared BOOLEAN DEFAULT true,
    p_type TEXT DEFAULT 'expense',
    p_splits JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_expense_id UUID := p_id;
    v_is_shared BOOLEAN := p_is_shared;
    v_member_id UUID;
    v_member_count INT;
    v_household_id UUID := p_household_id;
BEGIN
    -- Infer household_id if not provided
    IF v_household_id IS NULL THEN
        SELECT household_id INTO v_household_id FROM public.household_members WHERE user_id = p_paid_by LIMIT 1;
    END IF;

    -- Logic for is_shared
    -- 'personal' is NOT shared. 'gift' IS shared so the partner can see it.
    IF p_split_type = 'personal' THEN
        v_is_shared := false;
    END IF;

    -- Upsert Expense
    IF v_expense_id IS NULL THEN
        INSERT INTO public.expenses (
            household_id, created_by_id, title, description, category, 
            amount, paid_by, paid_at, split_type, is_shared, type
        ) VALUES (
            v_household_id, p_paid_by, p_title, p_description, p_category, 
            p_amount, p_paid_by, p_paid_at, p_split_type, v_is_shared, p_type::transaction_type
        ) RETURNING id INTO v_expense_id;
    ELSE
        UPDATE public.expenses SET
            title = p_title,
            description = p_description,
            category = p_category,
            amount = p_amount,
            paid_by = p_paid_by,
            paid_at = p_paid_at,
            split_type = p_split_type,
            is_shared = v_is_shared,
            type = p_type::transaction_type,
            updated_at = NOW()
        WHERE id = v_expense_id;
        
        DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
    END IF;

    -- Handle Splits logic
    IF p_split_type = 'gift' THEN
        -- Gift: Payer pays everything. No one else owes him.
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, p_paid_by, p_amount);
        
    ELSIF p_split_type = 'personal' THEN
        -- Personal: Only for the payer.
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, p_paid_by, p_amount);
        
    ELSIF p_split_type = 'equal' AND (p_splits IS NULL OR jsonb_array_length(p_splits) <= 1) THEN
        -- Auto-split among all household members
        SELECT COUNT(*) INTO v_member_count FROM public.household_members WHERE household_id = v_household_id;
        FOR v_member_id IN SELECT user_id FROM public.household_members WHERE household_id = v_household_id LOOP
            INSERT INTO public.expense_splits (expense_id, user_id, amount)
            VALUES (v_expense_id, v_member_id, p_amount / NULLIF(v_member_count, 0));
        END LOOP;
        
    ELSIF p_splits IS NOT NULL THEN
        -- Use provided splits
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        SELECT v_expense_id, (s->>'user_id')::UUID, (s->>'amount')::DECIMAL
        FROM jsonb_array_elements(p_splits) AS s;
    END IF;

    RETURN v_expense_id;
END;
$$;


-- 2. process_recurring_expenses RPC
CREATE OR REPLACE FUNCTION public.process_recurring_expenses(p_household_id UUID DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_template RECORD;
  v_count INTEGER := 0;
  v_next_month DATE;
  v_next_date DATE;
BEGIN
  FOR v_template IN 
    SELECT * FROM public.expense_templates 
    WHERE is_active = true 
      AND next_execution_date <= CURRENT_DATE
      AND (p_household_id IS NULL OR household_id = p_household_id)
  LOOP
    -- Insert the planned expense
    INSERT INTO public.planned_expenses (
      household_id, template_id, title, amount, category, 
      split_type, payer_default, due_date, status
    ) VALUES (
      v_template.household_id, v_template.id, v_template.title, 
      v_template.default_amount, v_template.category, 
      v_template.split_type, v_template.payer_default, 
      v_template.next_execution_date, 'pending'
    ) ON CONFLICT (template_id, due_date) DO NOTHING;

    -- Calculate next execution date based on frequency
    IF v_template.frequency = 'monthly' THEN
      v_next_month := v_template.next_execution_date + INTERVAL '1 month';
      -- Keep the same day of month, bounding it to the last valid day of the target month
      v_next_date := make_date(
        EXTRACT(year FROM v_next_month)::int,
        EXTRACT(month FROM v_next_month)::int,
        LEAST(v_template.day_of_month, EXTRACT(day FROM (date_trunc('month', v_next_month) + INTERVAL '1 month - 1 day'))::int)
      );
    ELSIF v_template.frequency = 'weekly' THEN
      v_next_date := v_template.next_execution_date + INTERVAL '1 week';
    ELSIF v_template.frequency = 'yearly' THEN
      v_next_date := v_template.next_execution_date + INTERVAL '1 year';
    ELSE
      v_next_date := v_template.next_execution_date + INTERVAL '1 month';
    END IF;

    -- Update template
    UPDATE public.expense_templates 
    SET next_execution_date = v_next_date 
    WHERE id = v_template.id;

    v_count := v_count + 1;
  END LOOP;

  RETURN jsonb_build_object('success', true, 'processed_count', v_count);
END;
$$;


-- 3. pay_planned_expense RPC
CREATE OR REPLACE FUNCTION public.pay_planned_expense(
  p_planned_id UUID,
  p_amount NUMERIC,
  p_paid_by UUID
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
    NOW(), 
    NULL, -- p_description
    v_planned.split_type, 
    true, -- p_is_shared (save_expense_v4 handles this)
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

GRANT EXECUTE ON FUNCTION public.process_recurring_expenses(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.pay_planned_expense(UUID, NUMERIC, UUID) TO authenticated;
;