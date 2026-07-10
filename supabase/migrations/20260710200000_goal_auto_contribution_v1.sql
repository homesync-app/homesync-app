-- Aporte automático a metas de ahorro (premium, motor de recurrentes).
--
-- Una plantilla recurrente puede quedar vinculada a una meta
-- (expense_templates.goal_id). El pipeline ya existente hace el resto:
-- plantilla → planificado mensual → recordatorios → "Pagar". Lo nuevo es que
-- pay_planned_expense, al pagar un planificado cuya plantilla apunta a una
-- meta VIVA (ni archivada ni completada), registra además la contribución en
-- savings_contributions — el trigger tr_update_goal_amount actualiza el
-- current_amount de la meta.
--
-- Ciclo de vida: al borrar/archivar/completar la meta se desactivan sus
-- plantillas vinculadas (no tiene sentido seguir aportando a una meta que ya
-- no existe o ya se cumplió).

ALTER TABLE public.expense_templates
  ADD COLUMN IF NOT EXISTS goal_id uuid
    REFERENCES public.savings_goals(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_expense_templates_goal
  ON public.expense_templates (goal_id)
  WHERE goal_id IS NOT NULL;

-- Al morir la meta (delete/archive/complete), la plantilla se apaga.
CREATE OR REPLACE FUNCTION public.deactivate_goal_linked_templates()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
BEGIN
  IF TG_OP = 'DELETE' THEN
    UPDATE public.expense_templates
    SET is_active = false,
        updated_at = timezone('utc'::text, now())
    WHERE goal_id = OLD.id
      AND is_active = true;
    RETURN OLD;
  END IF;

  IF (NEW.archived_at IS NOT NULL AND OLD.archived_at IS NULL)
     OR (NEW.completed_at IS NOT NULL AND OLD.completed_at IS NULL) THEN
    UPDATE public.expense_templates
    SET is_active = false,
        updated_at = timezone('utc'::text, now())
    WHERE goal_id = NEW.id
      AND is_active = true;
  END IF;
  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS tr_goal_linked_templates_lifecycle ON public.savings_goals;
CREATE TRIGGER tr_goal_linked_templates_lifecycle
  BEFORE DELETE OR UPDATE ON public.savings_goals
  FOR EACH ROW EXECUTE FUNCTION public.deactivate_goal_linked_templates();

-- pay_planned_expense: registra la contribución si la plantilla del
-- planificado está vinculada a una meta viva. Resto idéntico a la versión
-- de 20260710120000 (lock + guard de estado + type/title_key + backlink).
CREATE OR REPLACE FUNCTION public.pay_planned_expense(
  p_planned_id UUID,
  p_amount DECIMAL,
  p_paid_at TIMESTAMPTZ,
  p_paid_by TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := public.current_app_user_id();
  v_payer_uuid UUID;
  v_expense_id UUID;
  v_household_id UUID;
  v_household_type TEXT;
  v_title TEXT;
  v_title_key TEXT;
  v_category TEXT;
  v_split_type TEXT;
  v_type TEXT;
  v_status TEXT;
  v_template_id UUID;
  v_goal_id UUID;
  v_is_shared BOOLEAN;
  v_ratio NUMERIC;
  v_anchor UUID;
  v_split_member_count INT;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
  END IF;

  IF p_amount IS NULL OR p_amount <= 0 THEN
    RETURN jsonb_build_object('success', false, 'message', 'Amount must be greater than 0');
  END IF;

  SELECT pe.household_id, h.household_type, pe.title, pe.title_key, pe.category,
         pe.split_type, coalesce(pe.type, 'expense'), pe.status, pe.template_id
  INTO v_household_id, v_household_type, v_title, v_title_key, v_category,
       v_split_type, v_type, v_status, v_template_id
  FROM public.planned_expenses pe
  JOIN public.households h ON h.id = pe.household_id
  WHERE pe.id = p_planned_id
  FOR UPDATE OF pe;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Planned expense not found');
  END IF;

  IF v_status <> 'pending' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Planned expense already processed');
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = v_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'User is not a member of this household');
  END IF;

  SELECT hm.user_id
  INTO v_payer_uuid
  FROM public.household_members hm
  JOIN public.users u ON u.id = hm.user_id
  WHERE hm.household_id = v_household_id
    AND (u.id::text = p_paid_by OR u.firebase_uid = p_paid_by)
    AND (
      lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
      OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
    )
  LIMIT 1;

  IF v_payer_uuid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Payer is not an eligible adult member of this household');
  END IF;

  v_is_shared := CASE
    WHEN lower(coalesce(v_split_type, 'equal')) IN ('personal', 'gift') THEN false
    ELSE true
  END;

  INSERT INTO public.expenses (
    household_id, created_by_id, title, title_key, amount, category, paid_by,
    paid_at, type, split_type, is_shared, planned_expense_id
  ) VALUES (
    v_household_id, v_uid, v_title, v_title_key, p_amount, v_category,
    v_payer_uuid, p_paid_at, v_type::public.transaction_type,
    coalesce(v_split_type, 'equal'), v_is_shared, p_planned_id
  ) RETURNING id INTO v_expense_id;

  UPDATE public.planned_expenses
  SET status = 'paid',
      expense_id = v_expense_id
  WHERE id = p_planned_id;

  IF lower(coalesce(v_split_type, 'equal')) IN ('personal', 'gift') THEN
    INSERT INTO public.expense_splits (expense_id, user_id, amount)
    VALUES (v_expense_id, v_payer_uuid, p_amount);
  ELSE
    SELECT default_split_ratio, split_ratio_anchor_id
    INTO v_ratio, v_anchor
    FROM public.households
    WHERE id = v_household_id;

    WITH split_members AS (
      SELECT hm.user_id
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND (
          lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
          OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
        )
    )
    SELECT count(*) INTO v_split_member_count
    FROM split_members;

    IF v_split_member_count = 2
       AND v_anchor IS NOT NULL
       AND v_ratio IS NOT NULL
       AND v_ratio <> 0.5
       AND EXISTS (
         SELECT 1
         FROM public.household_members hm
         WHERE hm.household_id = v_household_id
           AND hm.user_id = v_anchor
           AND (
             lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
             OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
           )
       ) THEN
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT
        v_expense_id,
        hm.user_id,
        CASE WHEN hm.user_id = v_anchor
             THEN p_amount * v_ratio
             ELSE p_amount * (1 - v_ratio)
        END
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND (
          lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
          OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
        );
    ELSE
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT
        v_expense_id,
        hm.user_id,
        p_amount / NULLIF(v_split_member_count, 0)
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND (
          lower(coalesce(v_household_type, 'couple')) IN ('friends', 'roommates')
          OR coalesce(hm.member_type, 'parent') IN ('parent', 'guardian', 'adult')
        );
    END IF;
  END IF;

  -- Aporte automático: plantilla vinculada a una meta viva → contribución.
  IF v_template_id IS NOT NULL AND v_type = 'expense' THEN
    SELECT et.goal_id INTO v_goal_id
    FROM public.expense_templates et
    JOIN public.savings_goals sg ON sg.id = et.goal_id
    WHERE et.id = v_template_id
      AND sg.archived_at IS NULL
      AND sg.completed_at IS NULL;

    IF v_goal_id IS NOT NULL THEN
      INSERT INTO public.savings_contributions (
        goal_id, user_id, amount, note, split_type, participants
      ) VALUES (
        v_goal_id, v_payer_uuid, p_amount, v_title, 'personal', '[]'::jsonb
      );
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'expense_id', v_expense_id,
    'goal_id', v_goal_id,
    'message', 'Planned expense paid successfully'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.pay_planned_expense(UUID, DECIMAL, TIMESTAMPTZ, TEXT) TO authenticated;
