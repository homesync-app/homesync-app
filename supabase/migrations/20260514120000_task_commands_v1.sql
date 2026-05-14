-- =============================================================================
-- Task commands v1: idempotent versioned RPCs
-- =============================================================================
-- Crea complete_task_v1 y approve_task_v1 como los nombres canonicos y
-- arregla un bug latente: las household_activities se duplicaban si el cliente
-- reintentaba la misma submission/aprobacion (los ledger_entries ya estaban
-- protegidos por on conflict, pero la activity no).
--
-- Estrategia:
--   1. Agregar columna request_id text a household_activities con unique index
--      parcial (where request_id is not null). Rows historicas quedan en null.
--   2. complete_task_v1 y approve_task_v1: nuevas funciones canonicas que
--      escriben request_id y usan on conflict do nothing para dedup.
--   3. Las funciones legacy (complete_task_transaction, verify_task_transaction)
--      pasan a ser wrappers que llaman a _v1. Esto mantiene compatibilidad con
--      clientes en vuelo durante el deploy y se pueden borrar despues de 1-2
--      releases.
--
-- Contrato documentado en docs/rpc_contracts.md.
-- =============================================================================

-- 1. Columna de idempotencia ---------------------------------------------------

alter table public.household_activities
  add column if not exists request_id text;

create unique index if not exists uq_household_activities_request_id
  on public.household_activities (request_id)
  where request_id is not null;


-- 2. complete_task_v1 ---------------------------------------------------------
-- Mismo contrato y comportamiento que complete_task_transaction, pero la
-- insercion de household_activities usa request_id con on conflict do nothing
-- para que el reintento no duplique. Si la activity ya existe, recuperamos su
-- id y seguimos (los ledger_entries ya tienen su propio on conflict).

create or replace function public.complete_task_v1(
  p_request_id text,
  p_user_ids uuid[],
  p_task_id uuid,
  p_household_id uuid,
  p_xp_reward integer,
  p_coin_reward integer,
  p_task_title text,
  p_completed_at timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
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
  v_result jsonb := '{"success": true, "message": "Task completed"}'::jsonb;
begin
  if p_user_ids is null or coalesce(array_length(p_user_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', false,
      'message', 'At least one performer is required',
      'status', 'invalid'
    );
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

  -- ---- Camino con aprobacion -------------------------------------------------
  if v_requires_approval then
    if p_request_id is not null then
      select id into v_approval_id
      from public.task_approvals
      where request_id = p_request_id;
    end if;

    if v_approval_id is null then
      insert into public.task_approvals (
        task_id, household_id, submitted_by, performers,
        task_title, xp_reward, coin_reward, request_id
      ) values (
        p_task_id, p_household_id, p_user_ids[1], p_user_ids,
        p_task_title, p_xp_reward, p_coin_reward, p_request_id
      ) returning id into v_approval_id;

      update public.tasks
      set
        status = 'pending_approval',
        completed_by = p_user_ids[1],
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
          title, body, type, related_entity_type, related_entity_id
        ) values (
          p_household_id, v_admin_id, p_user_ids[1],
          'Tarea pendiente de aprobacion',
          coalesce(v_actor_name, 'Alguien') || ' completo "' || p_task_title || '"',
          'task_pending_approval',
          'task_approval',
          v_approval_id
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
          'coin_reward', p_coin_reward
        ),
        'Submitted for approval',
        'rpc'
      );
    end if;

    return jsonb_build_object(
      'success', true,
      'message', 'Task submitted for approval',
      'status', 'pending_approval',
      'task_status', 'pending_approval',
      'approval_id', v_approval_id,
      'requires_approval', true
    );
  end if;

  -- ---- Camino directo (con guard de idempotencia) ---------------------------
  v_next_due_at := public.calculate_next_task_due_at(
    v_due_at, v_rec_type, v_rec_interval
  );

  -- request_id namespaceado para no chocar con approve_task_v1 que usa el
  -- mismo p_request_id en el otro camino.
  v_activity_request_id := 'complete:' || coalesce(p_request_id, gen_random_uuid()::text);

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata, request_id
  ) values (
    p_household_id,
    p_user_ids[1],
    'task_completed',
    p_task_title,
    v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', p_xp_reward,
      'coins_per_user', p_coin_reward,
      'performers', p_user_ids,
      'category', v_task_cat
    ),
    v_activity_request_id
  )
  on conflict (request_id) where request_id is not null do nothing
  returning id into v_activity_id;

  -- Si fue conflict, recuperamos el id existente para no duplicar ledger ni
  -- update redundante.
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
    completed_by = p_user_ids[1],
    last_completed_at = now(),
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

    if p_coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned',
        p_coin_reward, 'COIN', v_activity_id::text, 'activity',
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
      'next_due_at', v_next_due_at
    ),
    'Completed and rescheduled if recurring',
    'rpc'
  );

  return v_result || jsonb_build_object(
    'activity_id', v_activity_id,
    'task_status', 'active',
    'next_due_at', v_next_due_at,
    'xp_earned', p_xp_reward,
    'coins_earned', p_coin_reward,
    'requires_approval', false
  );
end;
$$;

grant execute on function public.complete_task_v1(text, uuid[], uuid, uuid, integer, integer, text, timestamptz)
  to authenticated, service_role;


-- 3. approve_task_v1 ----------------------------------------------------------
-- Reemplazo canonico de verify_task_transaction. Mismo contrato; agrega guard
-- de idempotencia sobre household_activities por request_id.

create or replace function public.approve_task_v1(
  p_request_id text,
  p_user_id uuid,
  p_task_id uuid,
  p_verified_by uuid,
  p_next_due_at timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
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

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_task_household
      and hm.user_id = p_verified_by
      and hm.role in ('owner', 'admin')
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Only admins can approve tasks',
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
      'approved_by', p_verified_by,
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
    verified_by = p_verified_by,
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
        'XP: ' || v_approval.task_title, 'rpc', p_verified_by::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;

    if v_approval.coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), v_task_household, v_uid, 'coins_earned',
        v_approval.coin_reward, 'COIN', v_activity_id::text, 'activity',
        'Coins: ' || v_approval.task_title, 'rpc', p_verified_by::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;
  end loop;

  update public.task_approvals
  set
    status = 'approved',
    decided_by = p_verified_by,
    decided_at = now()
  where id = v_approval.id
    and status = 'pending';

  -- Notificacion idempotente: solo si todavia no notificamos para esta approval.
  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id
  )
  select
    v_task_household, v_approval.submitted_by, p_verified_by,
    'Tarea aprobada',
    '"' || v_approval.task_title || '" fue aprobada. Ganaste ' ||
      v_approval.coin_reward || ' coins.',
    'task_approved',
    'task',
    p_task_id
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
    p_verified_by,
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
$$;

grant execute on function public.approve_task_v1(text, uuid, uuid, uuid, timestamptz)
  to authenticated, service_role;


-- 4. Wrappers legacy ----------------------------------------------------------
-- Mantenemos los nombres viejos como delegadores para no romper clientes en
-- vuelo durante el deploy. Despues de 1-2 releases podemos borrarlos.

create or replace function public.complete_task_transaction(
  p_request_id text,
  p_user_ids uuid[],
  p_task_id uuid,
  p_household_id uuid,
  p_xp_reward integer,
  p_coin_reward integer,
  p_task_title text
)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select public.complete_task_v1(
    p_request_id, p_user_ids, p_task_id, p_household_id,
    p_xp_reward, p_coin_reward, p_task_title, null::timestamptz
  );
$$;

grant execute on function public.complete_task_transaction(text, uuid[], uuid, uuid, integer, integer, text)
  to authenticated, service_role;

create or replace function public.verify_task_transaction(
  p_request_id text,
  p_user_id uuid,
  p_task_id uuid,
  p_verified_by uuid,
  p_next_due_at timestamptz default null
)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select public.approve_task_v1(
    p_request_id, p_user_id, p_task_id, p_verified_by, p_next_due_at
  );
$$;

grant execute on function public.verify_task_transaction(text, uuid, uuid, uuid, timestamptz)
  to authenticated, service_role;
