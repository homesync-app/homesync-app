-- Harden Parent Mode approval RPCs.
--
-- Client UI gates Parent Mode to operational adults: owner/admin members whose
-- member_type is parent/guardian. These SECURITY DEFINER RPCs must enforce the
-- same rule server-side and must not trust caller-supplied user ids.

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
    title, body, type, related_entity_type, related_entity_id
  )
  select
    v_task_household, v_approval.submitted_by, v_current_user_id,
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
$$;

revoke execute on function public.approve_task_v1(text, uuid, uuid, uuid, timestamptz)
  from public, anon;
grant execute on function public.approve_task_v1(text, uuid, uuid, uuid, timestamptz)
  to authenticated, service_role;

create or replace function public.reject_task_v1(
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
    title, body, type, related_entity_type, related_entity_id
  ) values (
    v_task_household,
    v_approval.submitted_by,
    v_current_user_id,
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
$$;

revoke execute on function public.reject_task_v1(text, uuid, uuid, uuid, text)
  from public, anon;
grant execute on function public.reject_task_v1(text, uuid, uuid, uuid, text)
  to authenticated, service_role;

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
    and private.is_adult_household_admin(p_household_id, null)
  order by ta.created_at desc;
$$;

revoke execute on function public.get_pending_approvals(uuid)
  from public, anon;
grant execute on function public.get_pending_approvals(uuid)
  to authenticated, service_role;

create or replace function public.update_member_task_approval(
  p_household_member_id uuid,
  p_requires_task_approval boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller uuid := public.current_app_user_id();
  v_target record;
begin
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select
    hm.id,
    hm.user_id,
    hm.household_id,
    h.household_type
  into v_target
  from public.household_members hm
  join public.households h on h.id = hm.household_id
  where hm.id = p_household_member_id;

  if v_target.id is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Member not found',
      'status', 'not_found'
    );
  end if;

  if v_target.household_type <> 'family' then
    return jsonb_build_object(
      'success', false,
      'message', 'Only family households can use parent mode',
      'status', 'invalid_household_type'
    );
  end if;

  if not public.is_household_premium(v_target.household_id) then
    return jsonb_build_object(
      'success', false,
      'message', 'Parent mode requires household premium',
      'status', 'premium_required'
    );
  end if;

  if not private.is_adult_household_admin(v_target.household_id, v_target.user_id) then
    return jsonb_build_object(
      'success', false,
      'message', 'Only adult household admins can update task approval settings',
      'status', 'forbidden'
    );
  end if;

  update public.household_members
  set requires_task_approval = p_requires_task_approval
  where id = p_household_member_id;

  return jsonb_build_object(
    'success', true,
    'member_id', p_household_member_id,
    'requires_task_approval', p_requires_task_approval
  );
end;
$$;

revoke execute on function public.update_member_task_approval(uuid, boolean)
  from public, anon;
grant execute on function public.update_member_task_approval(uuid, boolean)
  to authenticated, service_role;

comment on function public.approve_task_v1(text, uuid, uuid, uuid, timestamptz) is
  'Approves a pending task approval. SECURITY DEFINER guard requires current_app_user_id to match supplied actor ids and be an adult owner/admin of the household.';
comment on function public.reject_task_v1(text, uuid, uuid, uuid, text) is
  'Rejects a pending task approval. SECURITY DEFINER guard requires current_app_user_id to match supplied actor ids and be an adult owner/admin of the household.';
comment on function public.get_pending_approvals(uuid) is
  'Lists pending task approvals only for adult owner/admin members of the household.';
comment on function public.update_member_task_approval(uuid, boolean) is
  'Modo Padres: adult owner/admin of a premium family household updates household_members.requires_task_approval via RPC.';
