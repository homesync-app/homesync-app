-- Task catalog rebalance + child coin floor.
--
-- 1) Tier heavy ahora paga 3 coins (pagaba 2, igual que big, y el esfuerzo
--    extra no se notaba en la moneda que compra recompensas).
-- 2) Jerarquías corregidas: una limpieza general vale más que sus subtareas
--    ("Limpieza general del dormitorio" > "Cambiar sábanas";
--     "Orden general de la casa" pasa a big).
-- 3) Se elimina el duplicado "Organizar placard" (ropa) — es la misma tarea
--    que "Ordenar placard" (dormitorio). Las tareas ya clonadas conservan su
--    title_key (el switch de localización del cliente mantiene la clave).
-- 4) Nuevos templates de catálogo (con translation_key para i18n).
-- 5) complete_task_v1: si algún performer es niño (member_type = 'child'),
--    la recompensa en coins nunca es 0 — piso de 1 coin. Cubre también el
--    flujo batch (complete_tasks_batch delega acá) y el flujo de aprobación
--    (el piso queda persistido en task_approvals.coin_reward).

begin;

-- ── 1) Heavy tier: 3 coins ──────────────────────────────────────────────────
update public.task_templates
set coin_reward = 3
where difficulty = 'heavy';

-- ── 2) Jerarquías ───────────────────────────────────────────────────────────
update public.task_templates
set difficulty = 'big', xp_reward = 35, coin_reward = 2
where translation_key in (
  'taskTemplateBedroomGeneralClean',
  'taskTemplateGeneralHouseTidying'
);

update public.task_templates
set difficulty = 'normal', xp_reward = 15, coin_reward = 1
where translation_key = 'taskTemplateChangeSheets';

-- ── 3) Duplicado ────────────────────────────────────────────────────────────
-- tasks.source_template_id es ON DELETE SET NULL, así que las tareas ya
-- clonadas no se ven afectadas.
delete from public.task_templates
where translation_key = 'taskTemplateOrganizeWardrobe';

-- ── 4) Nuevos templates ─────────────────────────────────────────────────────
insert into public.task_templates
  (title, category_id, difficulty, xp_reward, coin_reward, sort_order, translation_key)
values
  ('Limpiar microondas', 'cocina', 'small', 5, 0, 12, 'taskTemplateCleanMicrowave'),
  ('Lavar el auto', 'exterior', 'big', 35, 2, 6, 'taskTemplateWashCar'),
  ('Lavar tachos de basura', 'residuos', 'normal', 15, 1, 4, 'taskTemplateCleanTrashBins'),
  ('Preparar mochila del colegio', 'niños', 'small', 5, 0, 6, 'taskTemplatePackSchoolBag'),
  ('Cambiar agua de la mascota', 'mascotas', 'small', 5, 0, 6, 'taskTemplateGivePetWater')
on conflict do nothing;

-- ── 5) Piso de 1 coin para niños en complete_task_v1 ────────────────────────
create or replace function public.complete_task_v1(
  p_request_id text,
  p_user_ids uuid[],
  p_task_id uuid,
  p_household_id uuid,
  p_xp_reward integer,
  p_coin_reward integer,
  p_task_title text,
  p_completed_at timestamp with time zone default null::timestamp with time zone
)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
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

commit;
