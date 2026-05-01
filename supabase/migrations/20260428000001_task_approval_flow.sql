-- Sprint 1 (Modo Padres): flujo de aprobacion de tareas.
--
-- Modelo:
--  - households.task_approval_mode controla si una tarea completada queda
--    en estado pendiente hasta que un admin la apruebe.
--  - household_members.requires_task_approval refina por miembro cuando
--    el hogar usa modo 'per_member'.
--  - task_approvals guarda la "submision" para no perder los datos del
--    intento (performers, rewards, snapshot del titulo) hasta que el admin
--    decida.
--
-- Compatibilidad:
--  - Por defecto task_approval_mode = 'off' => comportamiento actual intacto.
--  - El gating de premium NO se aplica a nivel SQL: las RPCs respetan el modo
--    aunque el hogar no tenga premium. El cliente bloquea la activacion del
--    toggle desde la UI; el backend es la red de seguridad si el flag ya
--    estaba seteado cuando expiro la suscripcion (no rompemos hogares que
--    ya estaban en premium).

-- 1. Columnas en households / household_members / tasks ----------------------
alter table public.households
  add column if not exists task_approval_mode text
    not null
    default 'off'
    check (task_approval_mode in ('off', 'all', 'children_only', 'per_member'));

alter table public.household_members
  add column if not exists requires_task_approval boolean
    not null
    default false;

alter table public.tasks
  add column if not exists rejection_reason text,
  add column if not exists rejected_at timestamptz,
  add column if not exists rejected_by uuid references public.users(id) on delete set null;

-- 2. Tabla task_approvals -----------------------------------------------------
create table if not exists public.task_approvals (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  household_id uuid not null references public.households(id) on delete cascade,
  submitted_by uuid not null references public.users(id) on delete cascade,
  performers uuid[] not null,
  task_title text not null,
  xp_reward integer not null default 0,
  coin_reward integer not null default 0,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  decided_by uuid references public.users(id) on delete set null,
  decided_at timestamptz,
  rejection_reason text,
  request_id text,
  created_at timestamptz not null default now()
);

create index if not exists idx_task_approvals_household_pending
  on public.task_approvals(household_id, created_at desc)
  where status = 'pending';

create index if not exists idx_task_approvals_task
  on public.task_approvals(task_id, created_at desc);

create unique index if not exists uniq_task_approvals_request_id
  on public.task_approvals(request_id)
  where request_id is not null;

alter table public.task_approvals enable row level security;

-- Lectura: cualquier miembro del hogar puede ver las aprobaciones de su hogar
-- (el hijo necesita ver su propia submision pendiente para el feedback UI).
drop policy if exists task_approvals_household_read on public.task_approvals;
create policy task_approvals_household_read
  on public.task_approvals
  for select
  using (public.is_current_household_member(household_id));

-- Escritura: solo via RPCs SECURITY DEFINER. Bloqueamos INSERT/UPDATE/DELETE
-- desde el cliente directo para evitar que un hijo se auto-apruebe.
drop policy if exists task_approvals_no_direct_write on public.task_approvals;
create policy task_approvals_no_direct_write
  on public.task_approvals
  for all
  using (false)
  with check (false);

-- 3. Helper: should_require_task_approval ------------------------------------
-- Decide si una completion debe pasar por aprobacion segun:
--  - modo del hogar
--  - flag por miembro (en modo per_member)
--  - tipo del miembro (en modo children_only)
--
-- Nota: las RPCs lo usan al momento de completar, asi que cambios al modo
-- afectan tareas futuras pero no las que ya estan en pending_approval.
create or replace function public.should_require_task_approval(
  p_household_id uuid,
  p_user_id uuid
)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_mode text;
  v_requires boolean;
  v_member_type text;
begin
  select task_approval_mode into v_mode
  from public.households
  where id = p_household_id;

  if v_mode is null or v_mode = 'off' then
    return false;
  end if;

  if v_mode = 'all' then
    return true;
  end if;

  select requires_task_approval, member_type
    into v_requires, v_member_type
  from public.household_members
  where household_id = p_household_id
    and user_id = p_user_id;

  if v_mode = 'children_only' then
    return coalesce(v_member_type in ('child', 'teen'), false);
  end if;

  if v_mode = 'per_member' then
    return coalesce(v_requires, false);
  end if;

  return false;
end;
$$;

grant execute on function public.should_require_task_approval(uuid, uuid)
  to authenticated, service_role;

-- 4. complete_task_transaction (branch by approval mode) ---------------------
-- Si la submision requiere aprobacion: crea task_approvals(pending), pone la
-- tarea en 'pending_approval', notifica a admins, NO acredita XP/coins, NO
-- reprograma recurrencia. La aprobacion (verify_task_transaction) hace todo
-- eso despues.
--
-- Si NO requiere aprobacion: ejecuta el flujo actual sin cambios visibles.
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
    -- Idempotencia: si ya existe una aprobacion para este request_id, devolver
    -- el mismo resultado (cliente reintento la misma submission).
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

      -- Notificacion a cada admin del hogar para que vea la pendiente.
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

  -- ---- Camino directo (comportamiento original) -----------------------------
  v_next_due_at := public.calculate_next_task_due_at(
    v_due_at, v_rec_type, v_rec_interval
  );

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata
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

-- 5. verify_task_transaction --------------------------------------------------
-- Aprueba la ultima submision pendiente para una tarea. Aca recien se crea la
-- activity, se acreditan XP/coins (idempotente por request_id) y se reprograma
-- la recurrencia.
--
-- Mantiene la firma esperada por task_rpc_service.dart:
--   p_request_id, p_user_id, p_task_id, p_verified_by, p_next_due_at
-- p_next_due_at se ignora — el server lo recalcula desde la recurrencia.
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
begin
  -- Verificador debe ser admin del hogar de la tarea.
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

  -- Toma la ultima aprobacion pendiente para la tarea.
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

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata
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
  where id = v_approval.id;

  -- Notificacion al que la submitio.
  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id
  ) values (
    v_task_household, v_approval.submitted_by, p_verified_by,
    'Tarea aprobada',
    '"' || v_approval.task_title || '" fue aprobada. Ganaste ' ||
      v_approval.coin_reward || ' coins.',
    'task_approved',
    'task',
    p_task_id
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

-- 6. reject_task_transaction --------------------------------------------------
-- Rechaza la ultima submision pendiente, vuelve la tarea a 'assigned' y
-- guarda el motivo. No acredita nada.
create or replace function public.reject_task_transaction(
  p_request_id text,
  p_user_id uuid,
  p_task_id uuid,
  p_rejected_by uuid,
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_approval public.task_approvals%rowtype;
  v_task_household uuid;
begin
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

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = v_task_household
      and hm.user_id = p_rejected_by
      and hm.role in ('owner', 'admin')
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Only admins can reject tasks',
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
    decided_by = p_rejected_by,
    decided_at = now(),
    rejection_reason = p_reason
  where id = v_approval.id;

  update public.tasks
  set
    status = 'assigned',
    completed_at = null,
    completed_by = null,
    rejection_reason = p_reason,
    rejected_at = now(),
    rejected_by = p_rejected_by,
    updated_at = now()
  where id = p_task_id;

  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id
  ) values (
    v_task_household, v_approval.submitted_by, p_rejected_by,
    'Tarea no aprobada',
    coalesce(p_reason, 'Tu tarea "' || v_approval.task_title || '" necesita ajustes.'),
    'task_rejected',
    'task',
    p_task_id
  );

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    p_rejected_by,
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
$$;

-- 7. get_pending_approvals ----------------------------------------------------
-- Para el dashboard parental: lista enriquecida de pendientes en el hogar.
create or replace function public.get_pending_approvals(p_household_id uuid)
returns table (
  approval_id uuid,
  task_id uuid,
  task_title text,
  submitted_by uuid,
  submitted_by_name text,
  performers uuid[],
  xp_reward integer,
  coin_reward integer,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    ta.id as approval_id,
    ta.task_id,
    ta.task_title,
    ta.submitted_by,
    coalesce(u.full_name, u.email, 'Miembro') as submitted_by_name,
    ta.performers,
    ta.xp_reward,
    ta.coin_reward,
    ta.created_at
  from public.task_approvals ta
  left join public.users u on u.id = ta.submitted_by
  where ta.household_id = p_household_id
    and ta.status = 'pending'
    and public.is_current_household_member(p_household_id)
  order by ta.created_at desc;
$$;

grant execute on function public.complete_task_transaction(text, uuid[], uuid, uuid, integer, integer, text)
  to authenticated, service_role;
grant execute on function public.verify_task_transaction(text, uuid, uuid, uuid, timestamptz)
  to authenticated, service_role;
grant execute on function public.reject_task_transaction(text, uuid, uuid, uuid, text)
  to authenticated, service_role;
grant execute on function public.get_pending_approvals(uuid)
  to authenticated, service_role;

comment on table public.task_approvals is
  'Sprint 1 Modo Padres: snapshot de la submision de una tarea (performers, rewards) hasta que un admin la aprueba o rechaza.';
comment on column public.households.task_approval_mode is
  'off | all | children_only | per_member. Cambiar via UI gateada por premium.';
comment on column public.household_members.requires_task_approval is
  'Solo se respeta cuando households.task_approval_mode = per_member.';
