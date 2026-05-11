-- Security hardening: tasks approval, notifications, Mercado Pago surface and
-- atomic monthly custom-avatar generation reservations.

create table if not exists public.custom_avatar_monthly_usage (
  user_id uuid not null references public.users(id) on delete cascade,
  generation_month date not null,
  created_at timestamptz not null default now(),
  primary key (user_id, generation_month)
);

alter table public.custom_avatar_monthly_usage enable row level security;

drop policy if exists "users can view own avatar monthly usage"
  on public.custom_avatar_monthly_usage;

create policy "users can view own avatar monthly usage"
on public.custom_avatar_monthly_usage
for select
to authenticated
using (user_id = public.current_app_user_id());

create or replace function public.reject_sensitive_task_updates()
returns trigger
language plpgsql
volatile
set search_path = public
as $$
declare
  v_caller uuid;
  v_is_admin boolean;
  v_old_safe jsonb;
  v_new_safe jsonb;
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then
    return NEW;
  end if;

  v_caller := public.current_app_user_id();
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if NEW.household_id is distinct from OLD.household_id then
    raise exception 'Tasks cannot be moved between households'
      using errcode = '42501';
  end if;

  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = OLD.household_id
      and hm.user_id = v_caller
      and hm.role in ('owner', 'admin')
  ) into v_is_admin;

  v_old_safe := to_jsonb(OLD)
    - 'title'
    - 'description'
    - 'category'
    - 'type'
    - 'difficulty'
    - 'xp_reward'
    - 'coin_reward'
    - 'priority'
    - 'assigned_to'
    - 'due_at'
    - 'recurrence_type'
    - 'recurrence_interval'
    - 'recurrence_weekdays'
    - 'recurrence_month_days'
    - 'rotation_pool'
    - 'rotation_strategy'
    - 'rotation_index'
    - 'updated_at';
  v_new_safe := to_jsonb(NEW)
    - 'title'
    - 'description'
    - 'category'
    - 'type'
    - 'difficulty'
    - 'xp_reward'
    - 'coin_reward'
    - 'priority'
    - 'assigned_to'
    - 'due_at'
    - 'recurrence_type'
    - 'recurrence_interval'
    - 'recurrence_weekdays'
    - 'recurrence_month_days'
    - 'rotation_pool'
    - 'rotation_strategy'
    - 'rotation_index'
    - 'updated_at';

  if v_new_safe is distinct from v_old_safe and not v_is_admin then
    raise exception 'Task completion and approval fields require RPC/admin flow'
      using errcode = '42501';
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_reject_sensitive_task_updates on public.tasks;

create trigger trg_reject_sensitive_task_updates
  before update on public.tasks
  for each row
  execute function public.reject_sensitive_task_updates();

comment on function public.reject_sensitive_task_updates() is
  'Blocks direct member updates to task completion/approval fields and cross-household moves; completion must go through RPCs.';

drop policy if exists "Users can update tasks" on public.tasks;

create policy "Users can update tasks"
on public.tasks
for update
to authenticated
using (public.is_current_household_member(household_id))
with check (public.is_current_household_member(household_id));

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
  v_verified_by uuid := public.current_app_user_id();
begin
  if v_verified_by is null or p_verified_by is distinct from v_verified_by then
    return jsonb_build_object(
      'success', false, 'message', 'Verifier mismatch', 'status', 'forbidden'
    );
  end if;

  if p_user_id is distinct from v_verified_by then
    return jsonb_build_object(
      'success', false, 'message', 'User mismatch', 'status', 'forbidden'
    );
  end if;

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
      and hm.user_id = v_verified_by
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
      'approved_by', v_verified_by,
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
    last_verified_by = v_verified_by,
    rejection_reason = null,
    rejected_at = null,
    rejected_by = null,
    updated_at = now()
  where id = p_task_id;

  v_next_assignee := public.advance_task_rotation(p_task_id);

  foreach v_uid in array v_approval.performers loop
    if v_approval.xp_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), v_task_household, v_uid, 'xp_earned',
        v_approval.xp_reward, 'XP', v_activity_id::text, 'activity',
        'XP: ' || v_approval.task_title, 'rpc', v_verified_by::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;

    if v_approval.coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), v_task_household, v_uid, 'coins_earned',
        v_approval.coin_reward, 'COIN', v_activity_id::text, 'activity',
        'Coins: ' || v_approval.task_title, 'rpc', v_verified_by::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;
  end loop;

  update public.task_approvals
  set status = 'approved', decided_by = v_verified_by, decided_at = now()
  where id = v_approval.id;

  insert into public.notifications (
    household_id, user_id, created_by_id,
    title, body, type, related_entity_type, related_entity_id
  ) values (
    v_task_household, v_approval.submitted_by, v_verified_by,
    'Tarea aprobada',
    '"' || v_approval.task_title || '" fue aprobada. Ganaste ' ||
      v_approval.coin_reward || ' coins.',
    'task_approved', 'task', p_task_id
  );

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id, v_verified_by, v_task_household,
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

revoke execute on function public.is_household_premium(uuid) from anon;

drop policy if exists "Users can view their own connections" on public.mercadopago_connections;
drop policy if exists "Users can update their own connections" on public.mercadopago_connections;
drop policy if exists "Users can insert their own connections" on public.mercadopago_connections;
drop policy if exists "Users can manage their own connections" on public.mercadopago_connections;

create policy "service_role can manage mercadopago_connections"
on public.mercadopago_connections
for all
to service_role
using (true)
with check (true);
