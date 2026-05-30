-- Reconstructed from remote migration history (version 20260305104936).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- CORRECCIâ”œÃ´N DE RPC Y TIPOS DE ENUM
-- Aseguramos que el cast a transaction_type funcione y que los splits se inserten correctamente.

-- 0. Dropear funciones previas para evitar conflictos de firma
DROP FUNCTION IF EXISTS public.save_expense_v4(uuid,uuid,text,numeric,text,uuid,timestamptz,text,text,boolean,text,jsonb);
DROP FUNCTION IF EXISTS public.save_expense_v4(uuid,uuid,text,decimal,text,uuid,timestamptz,text,text,boolean,text,jsonb);

-- 1. Funciâ”œâ”‚n save_expense_v4 mejorada con cast de enum
CREATE OR REPLACE FUNCTION public.save_expense_v4(
  p_id UUID,
  p_household_id UUID,
  p_title TEXT,
  p_amount DECIMAL,
  p_category TEXT,
  p_paid_by UUID,
  p_paid_at TIMESTAMPTZ,
  p_description TEXT,
  p_split_type TEXT,
  p_is_shared BOOLEAN,
  p_type TEXT,
  p_splits JSONB
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expense_id UUID;
  v_split RECORD;
  v_type_enum transaction_type;
BEGIN
  -- Convertir el texto a enum de forma segura
  BEGIN
    v_type_enum := p_type::transaction_type;
  EXCEPTION WHEN OTHERS THEN
    v_type_enum := 'expense'::transaction_type;
  END;

  -- Insertar o actualizar el gasto
  IF p_id IS NOT NULL THEN
    UPDATE public.expenses SET 
      title = p_title, 
      amount = p_amount, 
      category = p_category, 
      paid_by = p_paid_by,
      paid_at = p_paid_at, 
      description = p_description, 
      split_type = p_split_type,
      is_shared = p_is_shared, 
      type = v_type_enum, 
      updated_at = NOW()
    WHERE id = p_id;
    v_expense_id := p_id;
    DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
  ELSE
    INSERT INTO public.expenses (
      household_id, 
      created_by_id, 
      title, 
      amount, 
      category, 
      paid_by, 
      paid_at, 
      description, 
      split_type, 
      is_shared, 
      type
    ) VALUES (
      p_household_id, 
      auth.uid(), 
      p_title, 
      p_amount, 
      p_category, 
      p_paid_by, 
      p_paid_at, 
      p_description, 
      p_split_type, 
      p_is_shared, 
      v_type_enum
    ) RETURNING id INTO v_expense_id;
  END IF;

  -- Lâ”œâ”‚gica de inserciâ”œâ”‚n de splits: prioritizamos lo que mande la app, 
  -- pero si es compartido y mandan un solo split (error comâ”œâ•‘n de UI), lo repartimos nosotros.
  
  IF p_splits IS NOT NULL AND jsonb_array_length(p_splits) > 1 THEN
    -- El caso ideal: vienen mâ”œâ•‘ltiples splits (ej. 50/50 o fijos)
    FOR v_split IN SELECT * FROM jsonb_to_recordset(p_splits) AS x(user_id UUID, amount DECIMAL)
    LOOP
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, v_split.user_id, v_split.amount);
    END LOOP;
  ELSE
    -- Caso de recuperaciâ”œâ”‚n: p_splits es nulo, vacâ”œÂ¡o, o tiene un solo elemento 
    -- pero el gasto estâ”œÃ­ marcado como COMPARTIDO e IGUALITARIO (50/50).
    IF p_is_shared AND (p_split_type = 'equal' OR p_split_type = 'gift') THEN
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT v_expense_id, user_id, p_amount / NULLIF((SELECT count(*)::decimal FROM public.household_members WHERE household_id = p_household_id), 0)
      FROM public.household_members WHERE household_id = p_household_id;
    ELSE
      -- Si es personal o no hay otra lâ”œâ”‚gica, el pagador asume todo el gasto solo.
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, p_paid_by, p_amount);
    END IF;
  END IF;

  RETURN v_expense_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.save_expense_v4 TO authenticated;
;