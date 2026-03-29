-- Fix auth.uid() usage in RPCs to support Firebase JWT fallback
CREATE OR REPLACE FUNCTION public.generate_household_invitation(p_household_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_code text;
  v_is_owner boolean;
  v_uid uuid := public.current_app_user_id();
BEGIN
  -- Verify the caller is an owner of the household
  SELECT EXISTS(
    SELECT 1 FROM household_members
    WHERE household_id = p_household_id
      AND user_id = v_uid
      AND role = 'owner'
  ) INTO v_is_owner;

  IF NOT v_is_owner THEN
    RAISE EXCEPTION 'Only household owners can generate invitation codes';
  END IF;

  -- Check for existing valid (unused, not expired) invitation
  SELECT code INTO v_code
  FROM household_invitations
  WHERE household_id = p_household_id
    AND used_at IS NULL
    AND expires_at > now()
  ORDER BY created_at DESC
  LIMIT 1;

  -- If no valid invitation exists, create one
  IF v_code IS NULL THEN
    INSERT INTO household_invitations (household_id, created_by)
    VALUES (p_household_id, v_uid)
    RETURNING code INTO v_code;
  END IF;

  RETURN v_code;
END;
$function$;

CREATE OR REPLACE FUNCTION public.join_household_by_code(p_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_invitation        household_invitations%ROWTYPE;
  v_old_household_id  uuid;
  v_member_count      int;
  v_uid               uuid := public.current_app_user_id();
BEGIN
  -- 1. Find the invitation
  SELECT * INTO v_invitation
  FROM household_invitations
  WHERE upper(code) = upper(p_code)
    AND used_at IS NULL
    AND expires_at > now()
  LIMIT 1;

  IF v_invitation.id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_code',
      'message', 'El código no es válido o ya fue utilizado');
  END IF;

  -- 2. Prevent joining same household
  IF v_invitation.household_id IN (
    SELECT household_id FROM household_members WHERE user_id = v_uid
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_member',
      'message', 'Ya eres miembro de este hogar');
  END IF;

  -- 3. Get user's current household
  SELECT household_id INTO v_old_household_id
  FROM household_members
  WHERE user_id = v_uid
  LIMIT 1;

  -- 4. Clean up old solo household FIRST (to avoid unique constraint on user_id)
  IF v_old_household_id IS NOT NULL AND v_old_household_id != v_invitation.household_id THEN
    SELECT COUNT(*) INTO v_member_count
    FROM household_members
    WHERE household_id = v_old_household_id;

    -- Remove user from old household
    DELETE FROM household_members WHERE household_id = v_old_household_id AND user_id = v_uid;

    IF v_member_count = 1 THEN
      -- User was the sole member, try to clean up their old stuff
      -- We'll wrap the household deletion in an exception block in case of unforeseen FKs
      BEGIN
        DELETE FROM tasks WHERE household_id = v_old_household_id;
        DELETE FROM expenses WHERE household_id = v_old_household_id;
        DELETE FROM shopping_items WHERE household_id = v_old_household_id;
        DELETE FROM household_activities WHERE household_id = v_old_household_id;
        DELETE FROM households WHERE id = v_old_household_id;
      EXCEPTION WHEN OTHERS THEN
        -- Ignore if it fails due to some foreign key, it's just an orphan household now
      END;
    END IF;
  END IF;

  -- 5. Add user to the new household as 'member'
  INSERT INTO household_members (household_id, user_id, role)
  VALUES (v_invitation.household_id, v_uid, 'member');

  -- 6. Mark invitation as used
  UPDATE household_invitations
  SET used_at = now(), used_by = v_uid
  WHERE id = v_invitation.id;

  RETURN jsonb_build_object(
    'success', true,
    'household_id', v_invitation.household_id,
    'message', '¡Te uniste al hogar exitosamente!'
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.reset_user_account()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := public.current_app_user_id();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'No autenticado');
  END IF;

  -- Delete all task associations (both created and assigned)
  DELETE FROM public.tasks WHERE created_by_id = v_user_id OR assigned_to = v_user_id;
  
  -- Delete expense participation (splits first, then whole expenses if they are the owner)
  -- Deleting expense_splits for user doesn't delete expenses they didn't create
  DELETE FROM public.expense_splits WHERE user_id = v_user_id;
  DELETE FROM public.expenses WHERE created_by_id = v_user_id OR paid_by = v_user_id;
  
  -- Reset progress (coins, xp, ledger history)
  DELETE FROM public.ledger_entries WHERE user_id = v_user_id;
  DELETE FROM public.reward_redemptions WHERE user_id = v_user_id;
  DELETE FROM public.notifications WHERE user_id = v_user_id;
  DELETE FROM public.household_activities WHERE user_id = v_user_id;
  DELETE FROM public.savings_contributions WHERE user_id = v_user_id;
  DELETE FROM public.weekly_winners WHERE user_id = v_user_id;
  DELETE FROM public.weekly_duel_history WHERE winner_user_id = v_user_id OR loser_user_id = v_user_id;

  -- Reset basic profile (optional)
  UPDATE public.users 
  SET full_name = 'Usuario', 
      avatar_url = NULL,
      mercadopago_alias = NULL
  WHERE id = v_user_id;

  RETURN jsonb_build_object('success', true, 'message', 'Cuenta reseteada correctamente');
END;
$function$;

CREATE OR REPLACE FUNCTION public.save_expense_v3(p_id uuid DEFAULT NULL::uuid, p_household_id uuid DEFAULT NULL::uuid, p_title text DEFAULT NULL::text, p_amount numeric DEFAULT NULL::numeric, p_category text DEFAULT NULL::text, p_paid_by uuid DEFAULT NULL::uuid, p_paid_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_description text DEFAULT NULL::text, p_split_type text DEFAULT NULL::text, p_is_shared boolean DEFAULT true, p_splits jsonb DEFAULT NULL::jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_expense_id UUID;
  v_split RECORD;
  v_uid UUID := public.current_app_user_id();
BEGIN
  IF p_id IS NULL THEN
    -- CREATE
    INSERT INTO public.expenses (
      household_id, created_by_id, title, amount, category, 
      paid_by, paid_at, description, split_type, is_shared, updated_at
    ) VALUES (
      p_household_id, v_uid, p_title, p_amount, p_category,
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
$function$;

CREATE OR REPLACE FUNCTION public.save_expense_v4(p_id uuid DEFAULT NULL::uuid, p_household_id uuid DEFAULT NULL::uuid, p_title text DEFAULT NULL::text, p_amount numeric DEFAULT NULL::numeric, p_category text DEFAULT NULL::text, p_paid_by uuid DEFAULT NULL::uuid, p_paid_at timestamp with time zone DEFAULT now(), p_description text DEFAULT NULL::text, p_split_type text DEFAULT 'equal'::text, p_is_shared boolean DEFAULT true, p_type text DEFAULT 'expense'::text, p_splits jsonb DEFAULT NULL::jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_uid UUID := public.current_app_user_id();
    v_expense_id UUID := p_id;
    v_is_shared BOOLEAN := p_is_shared;
    v_member_id UUID;
    v_member_count INT;
    v_household_id UUID := p_household_id;
    v_rows_updated INT := 0;
BEGIN
    IF v_uid IS NULL THEN
      RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Infer household from caller, never from client-supplied paid_by.
    IF v_household_id IS NULL THEN
      SELECT household_id
      INTO v_household_id
      FROM public.household_members
      WHERE user_id = v_uid
      LIMIT 1;
    END IF;

    IF v_household_id IS NULL THEN
      RAISE EXCEPTION 'Household not found for user';
    END IF;

    -- Caller must be member of the target household.
    IF NOT EXISTS (
      SELECT 1
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND hm.user_id = v_uid
    ) THEN
      RAISE EXCEPTION 'User is not member of household';
    END IF;

    -- paid_by must be a member of the same household.
    IF p_paid_by IS NULL OR NOT EXISTS (
      SELECT 1
      FROM public.household_members hm
      WHERE hm.household_id = v_household_id
        AND hm.user_id = p_paid_by
    ) THEN
      RAISE EXCEPTION 'paid_by must be a member of the household';
    END IF;

    -- Privacy rule: personal/gift are private (not shared).
    IF lower(coalesce(p_split_type, 'equal')) IN ('personal', 'gift') THEN
      v_is_shared := false;
    END IF;

    IF v_expense_id IS NULL THEN
      INSERT INTO public.expenses (
        household_id, created_by_id, title, description, category,
        amount, paid_by, paid_at, split_type, is_shared, type
      ) VALUES (
        v_household_id, v_uid, p_title, p_description, p_category,
        p_amount, p_paid_by, p_paid_at, p_split_type, v_is_shared, p_type::transaction_type
      ) RETURNING id INTO v_expense_id;
    ELSE
      UPDATE public.expenses
      SET
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
      WHERE id = v_expense_id
        AND created_by_id = v_uid;

      GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
      IF v_rows_updated = 0 THEN
        RAISE EXCEPTION 'Expense not found or not owned by user';
      END IF;

      DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
    END IF;

    -- Split generation
    IF lower(coalesce(p_split_type, 'equal')) IN ('gift', 'personal') THEN
      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      VALUES (v_expense_id, p_paid_by, p_amount);

    ELSIF lower(coalesce(p_split_type, 'equal')) = 'equal'
      AND (p_splits IS NULL OR jsonb_array_length(p_splits) <= 1) THEN
      SELECT COUNT(*) INTO v_member_count
      FROM public.household_members
      WHERE household_id = v_household_id;

      FOR v_member_id IN
        SELECT user_id FROM public.household_members WHERE household_id = v_household_id
      LOOP
        INSERT INTO public.expense_splits (expense_id, user_id, amount)
        VALUES (v_expense_id, v_member_id, p_amount / NULLIF(v_member_count, 0));
      END LOOP;

    ELSIF p_splits IS NOT NULL THEN
      -- Validate all split users belong to household
      IF EXISTS (
        SELECT 1
        FROM jsonb_array_elements(p_splits) s
        WHERE NOT EXISTS (
          SELECT 1
          FROM public.household_members hm
          WHERE hm.household_id = v_household_id
            AND hm.user_id = (s->>'user_id')::UUID
        )
      ) THEN
        RAISE EXCEPTION 'One or more split users are not household members';
      END IF;

      INSERT INTO public.expense_splits (expense_id, user_id, amount)
      SELECT v_expense_id, (s->>'user_id')::UUID, (s->>'amount')::DECIMAL
      FROM jsonb_array_elements(p_splits) AS s;
    END IF;

    RETURN v_expense_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_filtered_expenses(p_household_id uuid, p_type text DEFAULT 'all'::text, p_sharing text DEFAULT 'all'::text, p_limit integer DEFAULT 100, p_offset integer DEFAULT 0)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := public.current_app_user_id();
  v_result JSONB;
BEGIN
  IF v_uid IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN '[]'::jsonb;
  END IF;

  SELECT jsonb_agg(t) INTO v_result
  FROM (
    SELECT
      e.*,
      jsonb_build_object(
        'email', u.email,
        'full_name', u.full_name,
        'avatar_url', u.avatar_url
      ) AS payer,
      (
        SELECT jsonb_agg(s)
        FROM public.expense_splits s
        WHERE s.expense_id = e.id
      ) AS expense_splits
    FROM public.expenses e
    JOIN public.users u ON u.id = e.paid_by
    WHERE e.household_id = p_household_id
      AND (
        COALESCE(
          e.is_shared,
          CASE
            WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
            ELSE true
          END
        ) = true
        OR e.paid_by = v_uid
        OR e.created_by_id = v_uid
      )
      AND (
        p_type = 'all'
        OR e.type::TEXT = p_type
      )
      AND (
        p_sharing = 'all'
        OR (
          p_sharing = 'shared'
          AND COALESCE(
            e.is_shared,
            CASE
              WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
              ELSE true
            END
          ) = true
        )
        OR (
          p_sharing = 'mine'
          AND COALESCE(
            e.is_shared,
            CASE
              WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
              ELSE true
            END
          ) = false
          AND (e.paid_by = v_uid OR e.created_by_id = v_uid)
        )
      )
    ORDER BY e.paid_at DESC
    LIMIT p_limit
    OFFSET p_offset
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_combined_feed(p_household_id uuid, p_limit integer DEFAULT 20, p_offset integer DEFAULT 0)
 RETURNS TABLE(record_type text, transaction_type text, id uuid, title text, amount numeric, category text, split_type text, payer_id uuid, payer_email text, payer_full_name text, payer_avatar_url text, date timestamp with time zone, status text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := public.current_app_user_id();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    'expense'::TEXT AS record_type,
    e.type::TEXT AS transaction_type,
    e.id,
    e.title,
    e.amount,
    e.category,
    e.split_type,
    e.paid_by AS payer_id,
    u.email AS payer_email,
    u.full_name AS payer_full_name,
    u.avatar_url AS payer_avatar_url,
    e.paid_at AS date,
    'paid'::TEXT AS status
  FROM public.expenses e
  LEFT JOIN public.users u ON u.id = e.paid_by
  WHERE e.household_id = p_household_id
    AND e.type IN ('expense', 'income', 'settlement')
    AND (
      COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
      OR e.paid_by = v_uid
      OR e.created_by_id = v_uid
    )

  UNION ALL

  SELECT
    'planned'::TEXT AS record_type,
    'expense'::TEXT AS transaction_type,
    pe.id,
    pe.title,
    pe.amount,
    pe.category,
    pe.split_type,
    pe.payer_default AS payer_id,
    u.email AS payer_email,
    u.full_name AS payer_full_name,
    u.avatar_url AS payer_avatar_url,
    pe.due_date::TIMESTAMPTZ AS date,
    pe.status
  FROM public.planned_expenses pe
  LEFT JOIN public.users u ON u.id = pe.payer_default
  WHERE pe.household_id = p_household_id
    AND pe.status != 'paid'
    AND (
      lower(coalesce(pe.split_type, 'equal')) NOT IN ('personal', 'gift')
      OR pe.payer_default = v_uid
    )

  ORDER BY date DESC, id DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_expense_balance(p_household_id uuid)
 RETURNS TABLE(user_id uuid, user_email text, user_full_name text, balance numeric, avatar_url text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := public.current_app_user_id();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN;
  END IF;

  RETURN QUERY
  WITH members AS (
    SELECT u.id, u.email, u.full_name, u.avatar_url
    FROM public.users u
    JOIN public.household_members hm ON hm.user_id = u.id
    WHERE hm.household_id = p_household_id
  ),
  paid AS (
    SELECT e.paid_by AS user_id, SUM(e.amount) AS total_paid
    FROM public.expenses e
    WHERE e.household_id = p_household_id
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
    GROUP BY e.paid_by
  ),
  owed AS (
    SELECT es.user_id, SUM(es.amount) AS total_owed
    FROM public.expense_splits es
    JOIN public.expenses e ON e.id = es.expense_id
    WHERE e.household_id = p_household_id
      AND COALESCE(
        e.is_shared,
        CASE
          WHEN lower(coalesce(e.split_type, 'equal')) IN ('personal', 'gift') THEN false
          ELSE true
        END
      ) = true
    GROUP BY es.user_id
  )
  SELECT
    m.id AS user_id,
    m.email AS user_email,
    m.full_name AS user_full_name,
    COALESCE(p.total_paid, 0) - COALESCE(o.total_owed, 0) AS balance,
    m.avatar_url
  FROM members m
  LEFT JOIN paid p ON p.user_id = m.id
  LEFT JOIN owed o ON o.user_id = m.id
  ORDER BY balance DESC;
END;
$function$;

CREATE OR REPLACE FUNCTION public.pay_planned_expense(p_planned_id uuid, p_amount numeric, p_paid_at timestamp with time zone, p_paid_by uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := public.current_app_user_id();
  v_expense_id UUID;
  v_household_id UUID;
  v_title TEXT;
  v_category TEXT;
  v_split_type TEXT;
  v_is_shared BOOLEAN;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'Not authenticated');
  END IF;

  IF p_paid_by IS DISTINCT FROM v_uid THEN
    RETURN jsonb_build_object('success', false, 'message', 'You can only pay with your own user');
  END IF;

  SELECT household_id, title, category, split_type
  INTO v_household_id, v_title, v_category, v_split_type
  FROM public.planned_expenses
  WHERE id = p_planned_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Planned expense not found');
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = v_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'User is not a member of this household');
  END IF;

  v_is_shared := CASE
    WHEN lower(coalesce(v_split_type, 'equal')) IN ('personal', 'gift') THEN false
    ELSE true
  END;

  INSERT INTO public.expenses (
    household_id,
    created_by_id,
    title,
    amount,
    category,
    paid_by,
    paid_at,
    type,
    split_type,
    is_shared,
    planned_expense_id
  ) VALUES (
    v_household_id,
    v_uid,
    v_title,
    p_amount,
    v_category,
    p_paid_by,
    p_paid_at,
    'expense',
    coalesce(v_split_type, 'equal'),
    v_is_shared,
    p_planned_id
  ) RETURNING id INTO v_expense_id;

  UPDATE public.planned_expenses
  SET status = 'paid'
  WHERE id = p_planned_id;

  IF lower(coalesce(v_split_type, 'equal')) = 'equal' THEN
    INSERT INTO public.expense_splits (expense_id, user_id, amount)
    SELECT
      v_expense_id,
      hm.user_id,
      p_amount / NULLIF((SELECT count(*)::DECIMAL FROM public.household_members WHERE household_id = v_household_id), 0)
    FROM public.household_members hm
    WHERE hm.household_id = v_household_id;
  ELSE
    INSERT INTO public.expense_splits (expense_id, user_id, amount)
    VALUES (v_expense_id, p_paid_by, p_amount);
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'expense_id', v_expense_id,
    'message', 'Planned expense paid successfully'
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.handle_task_history_timestamps()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid UUID := public.current_app_user_id();
BEGIN
  -- Si la tarea cambia a un estado de completado/verificado y no tiene completed_at
  IF NEW.status IN ('pending_verification', 'verified', 'objected') AND NEW.completed_at IS NULL THEN
    NEW.completed_at := NOW();
  END IF;

  -- Si se completó pero no se sabe por quién, intentar inferirlo
  IF NEW.status IN ('pending_verification', 'verified', 'objected') AND NEW.completed_by IS NULL THEN
    -- Si es pending_verification, probablemente la completó el usuario actual
    IF v_uid IS NOT NULL THEN
      NEW.completed_by := v_uid;
    -- Si no, usar el asignado como fallback
    ELSIF NEW.assigned_to IS NOT NULL THEN
      NEW.completed_by := NEW.assigned_to;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.handle_task_notifications()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  creator_name TEXT;
  assignee_name TEXT;
  household_member_id UUID;
  v_uid UUID := public.current_app_user_id();
BEGIN
  -- We'll try to get names if possible
  SELECT full_name INTO creator_name FROM public.users WHERE id = NEW.created_by_id;
  
  -- If assigning a task to someone
  IF (TG_OP = 'INSERT' AND NEW.assigned_to IS NOT NULL AND NEW.assigned_to != NEW.created_by_id) OR
     (TG_OP = 'UPDATE' AND NEW.assigned_to IS NOT NULL AND OLD.assigned_to IS DISTINCT FROM NEW.assigned_to AND NEW.assigned_to != NEW.created_by_id) THEN
     
    INSERT INTO public.notifications (household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id)
    VALUES (
      NEW.household_id,
      NEW.assigned_to,
      NEW.created_by_id,
      'Nueva Tarea Asignada',
      COALESCE(creator_name, 'Alguien') || ' te asignó la tarea: ' || NEW.title,
      'task_assigned',
      'task',
      NEW.id
    );
  END IF;

  -- If completing a task
  IF (TG_OP = 'UPDATE' AND NEW.status IN ('pending_verification', 'verified') AND OLD.status NOT IN ('pending_verification', 'verified')) THEN
    -- Try to get the name of the user who completed the task
    -- Usually this is auth.uid(). As a fallback, use the assigned user.
    IF v_uid IS NOT NULL THEN
      SELECT full_name INTO assignee_name FROM public.users WHERE id = v_uid;
    ELSIF NEW.assigned_to IS NOT NULL THEN
      SELECT full_name INTO assignee_name FROM public.users WHERE id = NEW.assigned_to;
    ELSE
      assignee_name := 'Alguien';
    END IF;

    -- Also check that v_uid is not the creator themselves completing it
    IF v_uid IS NULL OR NEW.created_by_id != v_uid THEN  
      INSERT INTO public.notifications (household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id)
      VALUES (
        NEW.household_id,
        NEW.created_by_id,
        v_uid,
        'Tarea Completada',
        COALESCE(assignee_name, 'Alguien') || ' completó: ' || NEW.title,
        'task_completed',
        'task',
        NEW.id
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;
