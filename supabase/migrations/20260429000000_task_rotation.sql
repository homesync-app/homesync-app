-- Sprint 3 (Modo Padres): rotacion automatica de tareas.
--
-- Modelo:
--   - tasks.rotation_pool uuid[]: candidatos que se turnan. Vacio = rotacion off.
--   - tasks.rotation_strategy text: 'round_robin' (V1 unico).
--   - tasks.rotation_index integer: puntero a la posicion actual del pool.
--
-- Comportamiento:
--   - assigned_to siempre refleja "a quien le toca ahora" (lo lee la UI).
--   - Cuando una tarea recurrente con pool se completa exitosamente y se
--     reprograma, avanzamos rotation_index y reasignamos assigned_to al
--     siguiente del pool.
--   - Las tareas que requieren aprobacion NO avanzan en el momento de la
--     submision (eso seria injusto si despues se rechaza). Avanzan al
--     aprobar (verify_task_transaction).
--
-- Compatibilidad:
--   - Pool vacio + tareas existentes => sin cambios de comportamiento.
--   - Tareas one_time con pool no rotan (no hay reprogramacion).

-- 1. Columnas en tasks --------------------------------------------------------
alter table public.tasks
  add column if not exists rotation_pool uuid[]
    not null
    default '{}',
  add column if not exists rotation_strategy text
    not null
    default 'round_robin'
    check (rotation_strategy in ('round_robin')),
  add column if not exists rotation_index integer
    not null
    default 0;

-- Index parcial para encontrar rapido tareas con rotacion activa cuando un
-- miembro deja el hogar y hay que purgar su id de los pools.
create index if not exists idx_tasks_with_rotation
  on public.tasks(household_id)
  where array_length(rotation_pool, 1) > 0;

-- 2. Helper: advance_task_rotation ------------------------------------------
-- Avanza el puntero y reasigna. Devuelve el nuevo assignee. Si el pool esta
-- vacio o la tarea es one_time, no hace nada y devuelve null.
--
-- Idempotencia: la decision la toma el caller (solo se invoca una vez por
-- ciclo, despues de UPDATE de tasks). Aca solo aplicamos el avance.
create or replace function public.advance_task_rotation(p_task_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pool uuid[];
  v_index integer;
  v_type text;
  v_new_assignee uuid;
  v_new_index integer;
begin
  select rotation_pool, rotation_index, type
    into v_pool, v_index, v_type
  from public.tasks
  where id = p_task_id
  for update;

  if v_pool is null
     or array_length(v_pool, 1) is null
     or array_length(v_pool, 1) = 0
     or v_type <> 'recurring' then
    return null;
  end if;

  -- Postgres arrays son 1-based; usamos modulo sobre length para cerrar el
  -- ciclo. v_index avanza primero y luego se mapea a posicion 1..N.
  v_new_index := (coalesce(v_index, 0) + 1) % array_length(v_pool, 1);
  v_new_assignee := v_pool[v_new_index + 1];

  update public.tasks
  set
    rotation_index = v_new_index,
    assigned_to = v_new_assignee,
    updated_at = now()
  where id = p_task_id;

  return v_new_assignee;
end;
$$;

grant execute on function public.advance_task_rotation(uuid)
  to authenticated, service_role;

-- 3. complete_task_transaction: avanzar rotacion en el camino directo --------
-- Repetimos la firma exacta y reescribimos: solo difiere del Sprint 1 en que
-- al final del camino directo, si la tarea tiene rotation_pool, llamamos al
-- helper para avanzar y devolvemos `next_assignee` en el resultado.
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
  v_next_assignee uuid;
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
      'assigned', 'active', 'in_progress', 'objected',
      'pending_approval', 'pending_verification', 'verified'
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
        p_request_id, p_user_ids[1], p_household_id,
        'submit_task_for_approval', 'task_approval', v_approval_id,
        jsonb_build_object(
          'task_id', p_task_id,
          'performers', p_user_ids,
          'xp_reward', p_xp_reward,
          'coin_reward', p_coin_reward
        ),
        'Submitted for approval', 'rpc'
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

  -- ---- Camino directo (sin aprobacion) -------------------------------------
  v_next_due_at := public.calculate_next_task_due_at(
    v_due_at, v_rec_type, v_rec_interval
  );

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata
  ) values (
    p_household_id, p_user_ids[1], 'task_completed', p_task_title, v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', p_xp_reward,
      'coins_per_user', p_coin_reward,
      'performers', p_user_ids,
      'category', v_task_cat
    )
  ) returning id into v_activity_id;

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

  -- Avanzar rotacion si corresponde (solo recurrentes con pool no vacio).
  v_next_assignee := public.advance_task_rotation(p_task_id);

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
    p_request_id, p_user_ids[1], p_household_id,
    'complete_task', 'task', p_task_id,
    jsonb_build_object(
      'status', 'active',
      'activity_id', v_activity_id,
      'performers', p_user_ids,
      'next_due_at', v_next_due_at,
      'next_assignee', v_next_assignee
    ),
    'Completed and rescheduled if recurring',
    'rpc'
  );

  return v_result || jsonb_build_object(
    'activity_id', v_activity_id,
    'task_status', 'active',
    'next_due_at', v_next_due_at,
    'next_assignee', v_next_assignee,
    'xp_earned', p_xp_reward,
    'coins_earned', p_coin_reward,
    'requires_approval', false
  );
end;
$$;

grant execute on function public.complete_task_transaction(text, uuid[], uuid, uuid, integer, integer, text)
  to authenticated, service_role;

-- 4. verify_task_transaction: avanzar rotacion al aprobar --------------------
-- Misma firma; solo agregamos `advance_task_rotation` al final del path
-- exitoso para mantener la rotacion sincronizada con el ciclo aprobado.
create or replace function public.verify_task_transaction(
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
  v_next_assignee uuid;
begin
  select household_id, description, category, due_at, recurrence_type, recurrence_interval
    into v_task_household, v_task_desc, v_task_cat, v_due_at, v_rec_type, v_rec_interval
  from public.tasks
  where id = p_task_id
  for update;

  if not found then
    return jsonb_build_object(
      'success', false, 'message', 'Task not found', 'status', 'not_found'
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
      'success', false, 'message', 'Only admins can approve tasks', 'status', 'forbidden'
    );
  end if;

  select * into v_approval
  from public.task_approvals
  where task_id = p_task_id and status = 'pending'
  order by created_at desc
  limit 1
  for update;

  if not found then
    return jsonb_build_object(
      'success', false, 'message', 'No pending approval for task', 'status', 'not_found'
    );
  end if;

  v_next_due_at := public.calculate_next_task_due_at(
    v_due_at, v_rec_type, v_rec_interval
  );

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata
  ) values (
    v_task_household, v_approval.performers[1], 'task_completed',
    v_approval.task_title, v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', v_approval.xp_reward,
      'coins_per_user', v_approval.coin_reward,
      'performers', v_approval.performers,
      'category', v_task_cat,
      'approved_by', p_verified_by,
      'approval_id', v_approval.id
    )
  ) returning id into v_activity_id;

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

  -- Avanzar rotacion solo despues de aprobar (no en submission).
  v_next_assignee := public.advance_task_rotation(p_task_id);

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
  set status = 'approved', decided_by = p_verified_by, decided_at = now()
  where id = v_approval.id;

  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id
  ) values (
    v_task_household, v_approval.submitted_by, p_verified_by,
    'Tarea aprobada',
    '"' || v_approval.task_title || '" fue aprobada. Ganaste ' ||
      v_approval.coin_reward || ' coins.',
    'task_approved', 'task', p_task_id
  );

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id, p_verified_by, v_task_household,
    'verify_task', 'task_approval', v_approval.id,
    jsonb_build_object(
      'task_id', p_task_id,
      'activity_id', v_activity_id,
      'next_due_at', v_next_due_at,
      'next_assignee', v_next_assignee
    ),
    'Approved', 'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Task approved',
    'status', 'approved',
    'task_status', 'active',
    'approval_id', v_approval.id,
    'activity_id', v_activity_id,
    'next_due_at', v_next_due_at,
    'next_assignee', v_next_assignee,
    'xp_earned', v_approval.xp_reward,
    'coins_earned', v_approval.coin_reward
  );
end;
$$;

grant execute on function public.verify_task_transaction(text, uuid, uuid, uuid, timestamptz)
  to authenticated, service_role;

comment on column public.tasks.rotation_pool is
  'Sprint 3 Modo Padres: lista de user_id que se turnan. Vacio = sin rotacion.';
comment on column public.tasks.rotation_strategy is
  'Estrategia de rotacion. V1 solo round_robin.';
comment on column public.tasks.rotation_index is
  'Posicion 0-based del assignee actual dentro de rotation_pool.';
comment on function public.advance_task_rotation(uuid) is
  'Sprint 3 Modo Padres: avanza el puntero del pool y reasigna assigned_to. No-op si pool vacio o tarea one_time.';
