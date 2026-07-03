-- Notificaciones localizables (fase servidor).
--
-- Problema: los RPCs/triggers escriben title/body en español fijo y el
-- cliente los renderiza crudos — un usuario EN ve notificaciones en español.
-- Fase 1 (esta migración): columna `params jsonb` + todos los escritores de
-- notifications guardan datos estructurados (actor, título, monto, etc.).
-- El title/body en español se sigue escribiendo como fallback para filas
-- legadas y para el push FCM (localizar el push requiere locale por usuario;
-- pendiente).
-- Fase 2 (cliente): mapea type+params -> claves ARB con fallback a title/body.
--
-- Las funciones se recrean desde las definiciones EXACTAS de prod
-- (pg_get_functiondef, 2026-07-03) con el agregado de params.

alter table public.notifications
  add column if not exists params jsonb;


CREATE OR REPLACE FUNCTION public.handle_expense_notifications()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  creator_name TEXT;
  member_id UUID;
  action_verb TEXT;
  display_title TEXT;
  v_is_visible BOOLEAN;
BEGIN
  -- Do not send household-wide notifications for private expenses,
  -- except to members who are explicitly allowed to see them.

  SELECT split_part(full_name, ' ', 1)
  INTO creator_name
  FROM public.users
  WHERE id = NEW.created_by_id;

  IF creator_name IS NULL OR creator_name = '' THEN
    creator_name := 'Alguien';
  END IF;

  IF NEW.category = 'groceries' THEN
    action_verb := 'compró en';
  ELSE
    action_verb := 'gastó en';
  END IF;

  IF NEW.title = 'Liquidacion de deuda' THEN
    display_title := '¡Deuda saldada!';
    action_verb := 'saldó la deuda con';
  ELSE
    display_title := 'Nuevo movimiento';
  END IF;

  FOR member_id IN
    SELECT user_id
    FROM public.household_members
    WHERE household_id = NEW.household_id
      AND user_id <> NEW.created_by_id
  LOOP
    v_is_visible := (
      coalesce(NEW.is_shared, true) = true
      OR member_id = NEW.paid_by
      OR member_id = NEW.created_by_id
    );

    IF v_is_visible THEN
      INSERT INTO public.notifications (
        household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id, params
      ) VALUES (
        NEW.household_id,
        member_id,
        NEW.created_by_id,
        display_title,
        CASE
          WHEN NEW.title = 'Liquidacion de deuda' THEN creator_name || ' saldó su deuda de $ ' || NEW.amount
          ELSE creator_name || ' ' || action_verb || ' ' || NEW.title || ' ($ ' || NEW.amount || ')'
        END,
        'expense_added',
        'expense',
        NEW.id,
        jsonb_build_object(
          'actor_name', creator_name,
          'expense_title', NEW.title,
          'amount', NEW.amount,
          'kind', CASE
            WHEN NEW.title = 'Liquidacion de deuda' THEN 'settlement'
            WHEN NEW.category = 'groceries' THEN 'groceries'
            ELSE 'expense'
          END
        )
      );
    END IF;
  END LOOP;

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
     
    INSERT INTO public.notifications (household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id, params)
    VALUES (
      NEW.household_id,
      NEW.assigned_to,
      NEW.created_by_id,
      'Nueva Tarea Asignada',
      COALESCE(creator_name, 'Alguien') || ' te asignó la tarea: ' || NEW.title,
      'task_assigned',
      'task',
      NEW.id,
      jsonb_build_object(
        'actor_name', COALESCE(creator_name, ''),
        'task_title', NEW.title
      )
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
      INSERT INTO public.notifications (household_id, user_id, created_by_id, title, body, type, related_entity_type, related_entity_id, params)
      VALUES (
        NEW.household_id,
        NEW.created_by_id,
        v_uid,
        'Tarea Completada',
        COALESCE(assignee_name, 'Alguien') || ' completó: ' || NEW.title,
        'task_completed',
        'task',
        NEW.id,
        jsonb_build_object(
          'actor_name', COALESCE(assignee_name, ''),
          'task_title', NEW.title
        )
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.dispatch_weekly_family_summary_notifications()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_inserted integer := 0;
  v_now timestamptz := now();
begin
  insert into public.notifications (
    household_id,
    user_id,
    created_by_id,
    title,
    body,
    type,
    related_entity_type,
    related_entity_id,
    params
  )
  select distinct
    hm.household_id,
    hm.user_id,
    hm.user_id,
    'Tu resumen semanal esta listo',
    'Mira como cerro la semana del hogar: cumplimiento, MVP y gastos.',
    'weekly_summary_ready',
    'household',
    hm.household_id,
    '{}'::jsonb
  from public.household_members hm
  join public.households h on h.id = hm.household_id
  where h.household_type = 'family'
    and h.plan_tier <> 'free'
    and (h.premium_until is null or h.premium_until > v_now)
    and hm.role in ('owner', 'admin')
    and extract(dow from timezone(h.timezone, v_now)) = 0
    and extract(hour from timezone(h.timezone, v_now)) = 20
    and not exists (
      select 1
      from public.notifications n
      where n.household_id = hm.household_id
        and n.user_id = hm.user_id
        and n.type = 'weekly_summary_ready'
        and n.related_entity_type = 'household'
        and n.related_entity_id = hm.household_id
        and n.created_at >= (
          date_trunc('week', timezone(h.timezone, v_now))
          at time zone h.timezone
        )
    );

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$function$;

CREATE OR REPLACE FUNCTION public.complete_task_v1(p_request_id text, p_user_ids uuid[], p_task_id uuid, p_household_id uuid, p_xp_reward integer, p_coin_reward integer, p_task_title text, p_completed_at timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user_id uuid;
  v_activity_id uuid;
  v_task_desc text;
  v_task_cat text;
  v_due_at timestamptz;
  v_rec_type text;
  v_rec_interval integer;
  v_next_due_at timestamptz;
  v_requires_approval boolean;
  v_approval_id uuid;
  v_admin_id uuid;
  v_actor_name text;
  v_activity_request_id text;
  v_completed_at timestamptz := coalesce(p_completed_at, now());
  v_coin_reward integer := p_coin_reward;
  v_any_child boolean := false;
  v_result jsonb := '{"success": true, "message": "Task completed"}'::jsonb;
begin
  if p_user_ids is null or coalesce(array_length(p_user_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', false,
      'message', 'At least one performer is required',
      'status', 'invalid'
    );
  end if;

  -- Los niños siempre ganan al menos 1 coin por completar una tarea, incluso
  -- en tareas small cuyo catálogo paga 0. Si hay performers mixtos (adulto +
  -- niño) el piso aplica a todos para mantener la recompensa pareja.
  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = any(p_user_ids)
      and hm.member_type = 'child'
  ) into v_any_child;

  if v_any_child and v_coin_reward < 1 then
    v_coin_reward := 1;
  end if;

  select description, category, due_at, recurrence_type, recurrence_interval
    into v_task_desc, v_task_cat, v_due_at, v_rec_type, v_rec_interval
  from public.tasks
  where id = p_task_id
    and household_id = p_household_id
    and status in (
      'assigned',
      'active',
      'in_progress',
      'objected',
      'pending_approval',
      'pending_verification',
      'verified'
    )
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Task not found or not in completable state',
      'status', 'skipped'
    );
  end if;

  v_requires_approval := public.should_require_task_approval(
    p_household_id, p_user_ids[1]
  );

  if v_requires_approval then
    if p_request_id is not null then
      select id into v_approval_id
      from public.task_approvals
      where request_id = p_request_id;
    end if;

    if v_approval_id is null then
      select id into v_approval_id
      from public.task_approvals
      where task_id = p_task_id
        and household_id = p_household_id
        and status = 'pending'
      order by created_at desc
      limit 1;
    end if;

    if v_approval_id is not null then
      update public.tasks
      set
        status = 'pending_approval',
        completed_by = p_user_ids[1],
        completed_at = v_completed_at,
        last_completed_at = v_completed_at,
        rejection_reason = null,
        rejected_at = null,
        rejected_by = null,
        updated_at = now()
      where id = p_task_id;

      return jsonb_build_object(
        'success', true,
        'message', 'Task already submitted for approval',
        'status', 'pending_approval',
        'task_status', 'pending_approval',
        'approval_id', v_approval_id,
        'requires_approval', true,
        'duplicate', true
      );
    end if;

    insert into public.task_approvals (
      task_id, household_id, submitted_by, performers,
      task_title, xp_reward, coin_reward, request_id
    ) values (
      p_task_id, p_household_id, p_user_ids[1], p_user_ids,
      p_task_title, p_xp_reward, v_coin_reward, p_request_id
    ) returning id into v_approval_id;

    update public.tasks
    set
      status = 'pending_approval',
      completed_by = p_user_ids[1],
      completed_at = v_completed_at,
      last_completed_at = v_completed_at,
      rejection_reason = null,
      rejected_at = null,
      rejected_by = null,
      updated_at = now()
    where id = p_task_id;

    select coalesce(full_name, email, 'Alguien')
      into v_actor_name
    from public.users
    where id = p_user_ids[1];

    for v_admin_id in
      select hm.user_id
      from public.household_members hm
      where hm.household_id = p_household_id
        and hm.role in ('owner', 'admin')
        and hm.user_id <> p_user_ids[1]
    loop
      insert into public.notifications (
        household_id, user_id, created_by_id,
        title, body, type, related_entity_type, related_entity_id, params
      ) values (
        p_household_id, v_admin_id, p_user_ids[1],
        'Tarea pendiente de aprobacion',
        coalesce(v_actor_name, 'Alguien') || ' completo "' || p_task_title || '"',
        'task_pending_approval',
        'task_approval',
        v_approval_id,
        jsonb_build_object(
          'actor_name', coalesce(v_actor_name, ''),
          'task_title', p_task_title
        )
      );
    end loop;

    insert into public.audit_logs (
      request_id, user_id, household_id, action, entity_type, entity_id,
      new_value, reason, source
    ) values (
      p_request_id,
      p_user_ids[1],
      p_household_id,
      'submit_task_for_approval',
      'task_approval',
      v_approval_id,
      jsonb_build_object(
        'task_id', p_task_id,
        'performers', p_user_ids,
        'xp_reward', p_xp_reward,
        'coin_reward', v_coin_reward,
        'completed_at', v_completed_at
      ),
      'Submitted for approval',
      'rpc'
    );

    return jsonb_build_object(
      'success', true,
      'message', 'Task submitted for approval',
      'status', 'pending_approval',
      'task_status', 'pending_approval',
      'approval_id', v_approval_id,
      'requires_approval', true,
      'completed_at', v_completed_at
    );
  end if;

  v_next_due_at := public.calculate_next_task_due_at(
    v_due_at, v_rec_type, v_rec_interval
  );

  v_activity_request_id := 'complete:' || coalesce(p_request_id, gen_random_uuid()::text);

  insert into public.household_activities (
    household_id,
    user_id,
    event_type,
    title,
    description,
    metadata,
    request_id,
    created_at
  ) values (
    p_household_id,
    p_user_ids[1],
    'task_completed',
    p_task_title,
    v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', p_xp_reward,
      'coins_per_user', v_coin_reward,
      'performers', p_user_ids,
      'category', v_task_cat,
      'completed_at', v_completed_at,
      'last_completed_at', v_completed_at
    ),
    v_activity_request_id,
    now()
  )
  on conflict (request_id) where request_id is not null do nothing
  returning id into v_activity_id;

  if v_activity_id is null then
    select id into v_activity_id
    from public.household_activities
    where request_id = v_activity_request_id;
  end if;

  update public.tasks
  set
    status = 'active',
    due_at = coalesce(v_next_due_at, due_at),
    completed_at = v_completed_at,
    completed_by = p_user_ids[1],
    last_completed_at = v_completed_at,
    last_verified_by = null,
    verified_by = null,
    verified_at = null,
    rejection_reason = null,
    rejected_at = null,
    rejected_by = null,
    updated_at = now()
  where id = p_task_id;

  foreach v_user_id in array p_user_ids loop
    if p_xp_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned',
        p_xp_reward, 'XP', v_activity_id::text, 'activity',
        'XP: ' || p_task_title, 'rpc', v_user_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;

    if v_coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned',
        v_coin_reward, 'COIN', v_activity_id::text, 'activity',
        'Coins: ' || p_task_title, 'rpc', v_user_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;
  end loop;

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    p_user_ids[1],
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object(
      'status', 'active',
      'activity_id', v_activity_id,
      'performers', p_user_ids,
      'next_due_at', v_next_due_at,
      'completed_at', v_completed_at
    ),
    'Completed and rescheduled if recurring',
    'rpc'
  );

  return v_result || jsonb_build_object(
    'activity_id', v_activity_id,
    'task_status', 'active',
    'next_due_at', v_next_due_at,
    'xp_earned', p_xp_reward,
    'coins_earned', v_coin_reward,
    'requires_approval', false,
    'completed_at', v_completed_at
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.approve_task_v1(p_request_id text, p_user_id uuid, p_task_id uuid, p_verified_by uuid, p_next_due_at timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_current_user_id uuid := public.current_app_user_id();
  v_approval public.task_approvals%rowtype;
  v_task_household uuid;
  v_task_desc text;
  v_task_cat text;
  v_due_at timestamptz;
  v_rec_type text;
  v_rec_interval integer;
  v_next_due_at timestamptz;
  v_activity_id uuid;
  v_uid uuid;
  v_activity_request_id text;
begin
  if v_current_user_id is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'status', 'unauthenticated'
    );
  end if;

  if p_user_id is distinct from v_current_user_id
      or p_verified_by is distinct from v_current_user_id then
    return jsonb_build_object(
      'success', false,
      'message', 'User mismatch',
      'status', 'forbidden'
    );
  end if;

  select household_id, description, category, due_at, recurrence_type, recurrence_interval
    into v_task_household, v_task_desc, v_task_cat, v_due_at, v_rec_type, v_rec_interval
  from public.tasks
  where id = p_task_id
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Task not found',
      'status', 'not_found'
    );
  end if;

  if not private.is_adult_household_admin(v_task_household, null) then
    return jsonb_build_object(
      'success', false,
      'message', 'Only adult household admins can approve tasks',
      'status', 'forbidden'
    );
  end if;

  select * into v_approval
  from public.task_approvals
  where task_id = p_task_id
    and status = 'pending'
  order by created_at desc
  limit 1
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'No pending approval for task',
      'status', 'not_found'
    );
  end if;

  v_next_due_at := public.calculate_next_task_due_at(
    v_due_at, v_rec_type, v_rec_interval
  );

  v_activity_request_id := 'approve:' || coalesce(p_request_id, v_approval.id::text);

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata, request_id
  ) values (
    v_task_household,
    v_approval.performers[1],
    'task_completed',
    v_approval.task_title,
    v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', v_approval.xp_reward,
      'coins_per_user', v_approval.coin_reward,
      'performers', v_approval.performers,
      'category', v_task_cat,
      'approved_by', v_current_user_id,
      'approval_id', v_approval.id
    ),
    v_activity_request_id
  )
  on conflict (request_id) where request_id is not null do nothing
  returning id into v_activity_id;

  if v_activity_id is null then
    select id into v_activity_id
    from public.household_activities
    where request_id = v_activity_request_id;
  end if;

  update public.tasks
  set
    status = 'active',
    due_at = coalesce(v_next_due_at, due_at),
    completed_at = now(),
    completed_by = v_approval.performers[1],
    last_completed_at = now(),
    verified_by = v_current_user_id,
    verified_at = now(),
    rejection_reason = null,
    rejected_at = null,
    rejected_by = null,
    updated_at = now()
  where id = p_task_id;

  foreach v_uid in array v_approval.performers loop
    if v_approval.xp_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), v_task_household, v_uid, 'xp_earned',
        v_approval.xp_reward, 'XP', v_activity_id::text, 'activity',
        'XP: ' || v_approval.task_title, 'rpc', v_current_user_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;

    if v_approval.coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), v_task_household, v_uid, 'coins_earned',
        v_approval.coin_reward, 'COIN', v_activity_id::text, 'activity',
        'Coins: ' || v_approval.task_title, 'rpc', v_current_user_id::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;
  end loop;

  update public.task_approvals
  set
    status = 'approved',
    decided_by = v_current_user_id,
    decided_at = now()
  where id = v_approval.id
    and status = 'pending';

  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id, params
  )
  select
    v_task_household, v_approval.submitted_by, v_current_user_id,
    'Tarea aprobada',
    '"' || v_approval.task_title || '" fue aprobada. Ganaste ' ||
      v_approval.coin_reward || ' coins.',
    'task_approved',
    'task',
    p_task_id,
    jsonb_build_object(
      'task_title', v_approval.task_title,
      'coin_reward', v_approval.coin_reward,
      'xp_reward', v_approval.xp_reward
    )
  where not exists (
    select 1 from public.notifications n
    where n.related_entity_type = 'task'
      and n.related_entity_id = p_task_id
      and n.type = 'task_approved'
      and n.user_id = v_approval.submitted_by
      and n.created_at >= v_approval.created_at
  );

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    v_current_user_id,
    v_task_household,
    'verify_task',
    'task_approval',
    v_approval.id,
    jsonb_build_object(
      'task_id', p_task_id,
      'activity_id', v_activity_id,
      'next_due_at', v_next_due_at
    ),
    'Approved',
    'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Task approved',
    'status', 'approved',
    'task_status', 'active',
    'approval_id', v_approval.id,
    'activity_id', v_activity_id,
    'next_due_at', v_next_due_at,
    'xp_earned', v_approval.xp_reward,
    'coins_earned', v_approval.coin_reward
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.reject_task_v1(p_request_id text, p_user_id uuid, p_task_id uuid, p_rejected_by uuid, p_reason text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_current_user_id uuid := public.current_app_user_id();
  v_approval public.task_approvals%rowtype;
  v_task_household uuid;
begin
  if v_current_user_id is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'status', 'unauthenticated'
    );
  end if;

  if p_user_id is distinct from v_current_user_id
      or p_rejected_by is distinct from v_current_user_id then
    return jsonb_build_object(
      'success', false,
      'message', 'User mismatch',
      'status', 'forbidden'
    );
  end if;

  if p_request_id is not null then
    select * into v_approval
    from public.task_approvals
    where decision_request_id = p_request_id
      and status = 'rejected';

    if found then
      return jsonb_build_object(
        'success', true,
        'message', 'Task rejected',
        'status', 'rejected',
        'task_status', 'assigned',
        'approval_id', v_approval.id,
        'idempotent_replay', true
      );
    end if;
  end if;

  select household_id into v_task_household
  from public.tasks
  where id = p_task_id
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Task not found',
      'status', 'not_found'
    );
  end if;

  if not private.is_adult_household_admin(v_task_household, null) then
    return jsonb_build_object(
      'success', false,
      'message', 'Only adult household admins can reject tasks',
      'status', 'forbidden'
    );
  end if;

  select * into v_approval
  from public.task_approvals
  where task_id = p_task_id
    and status = 'pending'
  order by created_at desc
  limit 1
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'No pending approval for task',
      'status', 'not_found'
    );
  end if;

  update public.task_approvals
  set
    status = 'rejected',
    decided_by = v_current_user_id,
    decided_at = now(),
    rejection_reason = p_reason,
    decision_request_id = p_request_id
  where id = v_approval.id;

  update public.tasks
  set
    status = 'assigned',
    completed_at = null,
    completed_by = null,
    rejection_reason = p_reason,
    rejected_at = now(),
    rejected_by = v_current_user_id,
    updated_at = now()
  where id = p_task_id;

  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id, params
  ) values (
    v_task_household,
    v_approval.submitted_by,
    v_current_user_id,
    'Tarea no aprobada',
    coalesce(p_reason, 'Tu tarea "' || v_approval.task_title || '" necesita ajustes.'),
    'task_rejected',
    'task',
    p_task_id,
    jsonb_build_object(
      'task_title', v_approval.task_title,
      'reason', p_reason
    )
  );

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    v_current_user_id,
    v_task_household,
    'reject_task',
    'task_approval',
    v_approval.id,
    jsonb_build_object('task_id', p_task_id, 'reason', p_reason),
    coalesce(p_reason, 'Rejected'),
    'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Task rejected',
    'status', 'rejected',
    'task_status', 'assigned',
    'approval_id', v_approval.id
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.generate_planned_payment_reminders_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_upcoming integer := 0;
  v_due integer := 0;
begin
  with premium_households as (
    select h.id
    from public.households h
    where h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
    union
    select hm.household_id
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    where coalesce(u.is_premium, false) = true
      and (u.premium_until is null or u.premium_until > now())
  ),
  candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join premium_households ph on ph.id = pe.household_id
    where pe.status = 'pending'
      and pe.due_date = current_date + 3
  ),
  recipients as (
    select c.id, c.household_id, c.title, c.amount, c.due_date, hm.user_id
    from candidates c
    join public.household_members hm on hm.household_id = c.household_id
    where coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
      and (c.payer_default is null or hm.user_id = c.payer_default)
  ),
  inserted as (
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id, params
    )
    select
      r.household_id,
      r.user_id,
      'Pago proximo: ' || r.title,
      'Vence el ' || to_char(r.due_date, 'DD/MM')
        || ' - $' || to_char(r.amount, 'FM999999990'),
      'planned_payment_upcoming',
      'planned_expense',
      r.id,
      jsonb_build_object(
        'expense_title', r.title,
        'amount', r.amount,
        'due_date', r.due_date
      )
    from recipients r
    where not exists (
      select 1
      from public.notifications n
      where n.type = 'planned_payment_upcoming'
        and n.related_entity_id = r.id
        and n.user_id = r.user_id
    )
    returning 1
  )
  select count(*) into v_upcoming from inserted;

  with premium_households as (
    select h.id
    from public.households h
    where h.plan_tier <> 'free'
      and (h.premium_until is null or h.premium_until > now())
    union
    select hm.household_id
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    where coalesce(u.is_premium, false) = true
      and (u.premium_until is null or u.premium_until > now())
  ),
  candidates as (
    select
      pe.id,
      pe.household_id,
      pe.title,
      pe.amount,
      pe.due_date,
      pe.payer_default
    from public.planned_expenses pe
    join premium_households ph on ph.id = pe.household_id
    where pe.status = 'pending'
      and pe.due_date = current_date
  ),
  recipients as (
    select c.id, c.household_id, c.title, c.amount, c.due_date, hm.user_id
    from candidates c
    join public.household_members hm on hm.household_id = c.household_id
    where coalesce(hm.member_type, 'parent') in ('parent', 'guardian', 'adult')
      and (c.payer_default is null or hm.user_id = c.payer_default)
  ),
  inserted as (
    insert into public.notifications (
      household_id, user_id, title, body, type,
      related_entity_type, related_entity_id, params
    )
    select
      r.household_id,
      r.user_id,
      'Vence hoy: ' || r.title,
      'Registralo desde Finanzas cuando lo pagues - $'
        || to_char(r.amount, 'FM999999990'),
      'planned_payment_due',
      'planned_expense',
      r.id,
      jsonb_build_object(
        'expense_title', r.title,
        'amount', r.amount,
        'due_date', r.due_date
      )
    from recipients r
    where not exists (
      select 1
      from public.notifications n
      where n.type = 'planned_payment_due'
        and n.related_entity_id = r.id
        and n.user_id = r.user_id
    )
    returning 1
  )
  select count(*) into v_due from inserted;

  return jsonb_build_object(
    'success', true,
    'upcoming', v_upcoming,
    'due_today', v_due,
    'run_date', current_date
  );
end;
$function$;
