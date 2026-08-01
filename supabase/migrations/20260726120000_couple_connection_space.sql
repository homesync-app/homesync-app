-- Couple mode is collaborative, never transactional.
--
-- This migration:
--   1. Adds free, reversible proposals that cannot carry a price.
--   2. Turns weekly challenges into shared memories (no XP or coins).
--   3. Exposes a neutral weekly household summary without rankings.
--   4. Prevents every current or legacy code path from minting XP/coins for
--      couple households.

create table if not exists public.couple_proposals (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  created_by uuid not null references public.users(id) on delete cascade,
  title text not null
    check (char_length(btrim(title)) between 3 and 120),
  description text
    check (description is null or char_length(btrim(description)) <= 500),
  category text not null default 'talk'
    check (category in ('talk', 'plan', 'affection', 'support')),
  status text not null default 'pending'
    check (status in (
      'pending', 'accepted', 'deferred', 'declined', 'withdrawn', 'archived'
    )),
  responded_by uuid references public.users(id) on delete set null,
  responded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_couple_proposals_household_active
  on public.couple_proposals (household_id, created_at desc)
  where status in ('pending', 'accepted', 'deferred');

alter table public.couple_proposals enable row level security;

do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'couple_proposals'
  ) then
    alter publication supabase_realtime add table public.couple_proposals;
  end if;
end;
$$;

create policy restrict_to_valid_jwt_couple_proposals
  on public.couple_proposals
  as restrictive for all
  using ((select public.is_supabase_or_firebase_project_jwt()) is true)
  with check ((select public.is_supabase_or_firebase_project_jwt()) is true);

create policy "Couple members can view proposals"
  on public.couple_proposals for select
  using (public.is_current_household_member(household_id));

-- Mutations intentionally go through SECURITY DEFINER RPCs. That lets the
-- server enforce "the author cannot accept their own proposal" and prevents
-- clients from changing created_by/status directly.

create or replace function public.create_couple_proposal_v1(
  p_household_id uuid,
  p_title text,
  p_description text default null,
  p_category text default 'talk'
) returns public.couple_proposals
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_proposal public.couple_proposals;
begin
  if v_actor is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if not exists (
    select 1
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where hm.household_id = p_household_id
      and hm.user_id = v_actor
      and h.household_type = 'couple'
  ) then
    raise exception 'Only members of a couple household can create proposals'
      using errcode = '42501';
  end if;

  if char_length(btrim(coalesce(p_title, ''))) not between 3 and 120 then
    raise exception 'Proposal title must contain between 3 and 120 characters'
      using errcode = '22023';
  end if;

  if char_length(btrim(coalesce(p_description, ''))) > 500 then
    raise exception 'Proposal description is too long' using errcode = '22023';
  end if;

  if coalesce(p_category, '') not in ('talk', 'plan', 'affection', 'support') then
    raise exception 'Invalid proposal category' using errcode = '22023';
  end if;

  insert into public.couple_proposals (
    household_id, created_by, title, description, category
  ) values (
    p_household_id,
    v_actor,
    btrim(p_title),
    nullif(btrim(coalesce(p_description, '')), ''),
    p_category
  )
  returning * into v_proposal;

  return v_proposal;
end;
$function$;

create or replace function public.respond_couple_proposal_v1(
  p_proposal_id uuid,
  p_response text
) returns public.couple_proposals
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_proposal public.couple_proposals;
begin
  if v_actor is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if p_response is null
    or p_response not in ('accepted', 'deferred', 'declined')
  then
    raise exception 'Response must be accepted, deferred, or declined'
      using errcode = '22023';
  end if;

  select *
  into v_proposal
  from public.couple_proposals
  where id = p_proposal_id
  for update;

  if not found then
    raise exception 'Proposal not found' using errcode = 'P0002';
  end if;

  if not public.is_current_household_member(v_proposal.household_id) then
    raise exception 'Not a household member' using errcode = '42501';
  end if;

  if v_proposal.created_by = v_actor then
    raise exception 'The author cannot respond to their own proposal'
      using errcode = '42501';
  end if;

  if v_proposal.status not in ('pending', 'deferred') then
    return v_proposal;
  end if;

  update public.couple_proposals
  set status = p_response,
      responded_by = v_actor,
      responded_at = now(),
      updated_at = now()
  where id = p_proposal_id
  returning * into v_proposal;

  return v_proposal;
end;
$function$;

create or replace function public.withdraw_couple_proposal_v1(
  p_proposal_id uuid
) returns public.couple_proposals
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_proposal public.couple_proposals;
begin
  update public.couple_proposals
  set status = 'withdrawn',
      updated_at = now()
  where id = p_proposal_id
    and created_by = v_actor
    and status in ('pending', 'deferred')
    and public.is_current_household_member(household_id)
  returning * into v_proposal;

  if not found then
    raise exception 'Only the author can withdraw an open proposal'
      using errcode = '42501';
  end if;

  return v_proposal;
end;
$function$;

create or replace function public.archive_couple_proposal_v1(
  p_proposal_id uuid
) returns public.couple_proposals
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_proposal public.couple_proposals;
begin
  update public.couple_proposals
  set status = 'archived',
      updated_at = now()
  where id = p_proposal_id
    and status = 'accepted'
    and public.is_current_household_member(household_id)
  returning * into v_proposal;

  if not found then
    raise exception 'Accepted proposal not found' using errcode = 'P0002';
  end if;

  return v_proposal;
end;
$function$;

revoke execute on function public.create_couple_proposal_v1(
  uuid, text, text, text
) from public;
revoke execute on function public.respond_couple_proposal_v1(
  uuid, text
) from public;
revoke execute on function public.withdraw_couple_proposal_v1(uuid) from public;
revoke execute on function public.archive_couple_proposal_v1(uuid) from public;

grant execute on function public.create_couple_proposal_v1(
  uuid, text, text, text
) to authenticated;
grant execute on function public.respond_couple_proposal_v1(
  uuid, text
) to authenticated;
grant execute on function public.withdraw_couple_proposal_v1(uuid)
  to authenticated;
grant execute on function public.archive_couple_proposal_v1(uuid)
  to authenticated;

create or replace function public.get_couple_connection_summary_v1(
  p_household_id uuid
) returns jsonb
language plpgsql
stable
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_week_start timestamptz := date_trunc('week', now());
  v_week_end timestamptz := date_trunc('week', now()) + interval '7 days';
  v_tasks_done integer := 0;
  v_tasks_planned integer := 0;
  v_needs_attention integer := 0;
  v_special_moments integer := 0;
  v_distribution jsonb := '[]'::jsonb;
begin
  if v_actor is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if not exists (
    select 1
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where hm.household_id = p_household_id
      and hm.user_id = v_actor
      and h.household_type = 'couple'
  ) then
    raise exception 'Not a member of this couple household'
      using errcode = '42501';
  end if;

  select count(*)
  into v_tasks_done
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.event_type = 'task_completed'
    and coalesce((ha.metadata ->> 'is_couple_challenge')::boolean, false) is false
    and ha.created_at >= v_week_start
    and ha.created_at < v_week_end;

  select count(*)
  into v_tasks_planned
  from public.tasks t
  where t.household_id = p_household_id
    and (
      (t.due_at >= v_week_start and t.due_at < v_week_end)
      or (
        t.last_completed_at::timestamptz >= v_week_start
        and t.last_completed_at::timestamptz < v_week_end
      )
    );

  v_tasks_planned := greatest(v_tasks_planned, v_tasks_done);

  select count(*)
  into v_needs_attention
  from public.tasks t
  where t.household_id = p_household_id
    and t.status in ('active', 'assigned', 'objected')
    and t.due_at is not null
    and t.due_at < now();

  select count(*)
  into v_special_moments
  from public.couple_challenge_completions c
  where c.household_id = p_household_id;

  select coalesce(jsonb_agg(to_jsonb(member_row) order by member_row.joined_at), '[]'::jsonb)
  into v_distribution
  from (
    select
      hm.user_id,
      coalesce(u.full_name, split_part(u.email, '@', 1), 'Miembro') as name,
      u.avatar_url,
      hm.joined_at,
      count(ha.id)::integer as tasks_done
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    left join public.household_activities ha
      on ha.household_id = hm.household_id
      and ha.user_id = hm.user_id
      and ha.event_type = 'task_completed'
      and coalesce((ha.metadata ->> 'is_couple_challenge')::boolean, false) is false
      and ha.created_at >= v_week_start
      and ha.created_at < v_week_end
    where hm.household_id = p_household_id
    group by hm.user_id, u.full_name, u.email, u.avatar_url, hm.joined_at
  ) member_row;

  return jsonb_build_object(
    'household_id', p_household_id,
    'week_start', v_week_start,
    'week_end', v_week_end,
    'tasks_done', v_tasks_done,
    'tasks_planned', v_tasks_planned,
    'needs_attention', v_needs_attention,
    'special_moments', v_special_moments,
    'member_distribution', v_distribution
  );
end;
$function$;

revoke execute on function public.get_couple_connection_summary_v1(uuid)
  from public;
grant execute on function public.get_couple_connection_summary_v1(uuid)
  to authenticated;

-- Rewards are server-authoritative in every household mode. Keep the v1
-- signature for installed clients, but ignore caller-provided rewards/title
-- and load them from the locked task row. The session actor and every credited
-- performer must belong to the task's household.
create or replace function public.complete_task_v1(
  p_request_id text,
  p_user_ids uuid[],
  p_task_id uuid,
  p_household_id uuid,
  p_xp_reward integer,
  p_coin_reward integer,
  p_task_title text,
  p_completed_at timestamptz default null
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_user_id uuid;
  v_activity_id uuid;
  v_task_title text;
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
  v_xp_reward integer := 0;
  v_coin_reward integer := 0;
  v_household_type text;
  v_any_child boolean := false;
  v_result jsonb := '{"success": true, "message": "Task completed"}'::jsonb;
begin
  if v_actor is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'status', 'unauthenticated'
    );
  end if;

  if p_user_ids is null or coalesce(array_length(p_user_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', false,
      'message', 'At least one performer is required',
      'status', 'invalid'
    );
  end if;

  if not exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = v_actor
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Actor is not a household member',
      'status', 'forbidden'
    );
  end if;

  if exists (
    select 1
    from unnest(p_user_ids) as performer(user_id)
    where not exists (
      select 1
      from public.household_members hm
      where hm.household_id = p_household_id
        and hm.user_id = performer.user_id
    )
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Every performer must belong to the household',
      'status', 'forbidden'
    );
  end if;

  select
    t.title,
    t.description,
    t.category,
    t.due_at,
    t.recurrence_type,
    t.recurrence_interval,
    coalesce(t.xp_reward, 0),
    coalesce(t.coin_reward, 0),
    h.household_type
  into
    v_task_title,
    v_task_desc,
    v_task_cat,
    v_due_at,
    v_rec_type,
    v_rec_interval,
    v_xp_reward,
    v_coin_reward,
    v_household_type
  from public.tasks t
  join public.households h on h.id = t.household_id
  where t.id = p_task_id
    and t.household_id = p_household_id
    and t.status in (
      'assigned',
      'active',
      'in_progress',
      'objected',
      'pending_approval',
      'pending_verification',
      'verified'
    )
  for update of t;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Task not found or not in completable state',
      'status', 'skipped'
    );
  end if;

  if v_household_type = 'family' then
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
      v_task_title, v_xp_reward, v_coin_reward, p_request_id
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
        coalesce(v_actor_name, 'Alguien') || ' completo "' ||
          v_task_title || '"',
        'task_pending_approval',
        'task_approval',
        v_approval_id,
        jsonb_build_object(
          'actor_name', coalesce(v_actor_name, ''),
          'task_title', v_task_title
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
        'xp_reward', v_xp_reward,
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

  v_activity_request_id :=
    'complete:' || coalesce(p_request_id, gen_random_uuid()::text);

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
    v_task_title,
    v_task_desc,
    jsonb_build_object(
      'task_id', p_task_id,
      'xp_per_user', v_xp_reward,
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
    if v_xp_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'xp_earned',
        v_xp_reward, 'XP', v_activity_id::text, 'activity',
        'XP: ' || v_task_title, 'rpc', v_actor::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;

    if v_coin_reward > 0 then
      insert into public.ledger_entries (
        id, household_id, user_id, type, amount, currency,
        reference_id, reference_type, description, source, created_by
      ) values (
        gen_random_uuid(), p_household_id, v_user_id, 'coins_earned',
        v_coin_reward, 'COIN', v_activity_id::text, 'activity',
        'Coins: ' || v_task_title, 'rpc', v_actor::text
      ) on conflict (user_id, type, reference_id) do nothing;
    end if;
  end loop;

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    v_actor,
    p_household_id,
    'complete_task',
    'task',
    p_task_id,
    jsonb_build_object(
      'status', 'active',
      'activity_id', v_activity_id,
      'performers', p_user_ids,
      'next_due_at', v_next_due_at,
      'completed_at', v_completed_at,
      'authoritative_rewards', true
    ),
    'Completed and rescheduled if recurring',
    'rpc'
  );

  return v_result || jsonb_build_object(
    'activity_id', v_activity_id,
    'task_status', 'active',
    'next_due_at', v_next_due_at,
    'xp_earned', v_xp_reward,
    'coins_earned', v_coin_reward,
    'requires_approval', false,
    'completed_at', v_completed_at
  );
end;
$function$;

revoke execute on function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) from public, anon;
grant execute on function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) to authenticated, service_role;

-- Keep the v1 signature so already-installed clients remain compatible, but
-- intentionally ignore every caller-provided performer/reward value.
create or replace function public.complete_couple_challenge_v1(
  p_request_id text,
  p_household_id uuid,
  p_week_index integer,
  p_challenge_id text,
  p_user_ids uuid[],
  p_xp_reward integer,
  p_coin_reward integer,
  p_title text,
  p_description text default null,
  p_completed_by uuid default null
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_activity_id uuid;
  v_completer uuid := public.current_app_user_id();
  v_activity_request_id text;
begin
  if v_completer is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if not exists (
    select 1
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where hm.household_id = p_household_id
      and hm.user_id = v_completer
      and h.household_type = 'couple'
  ) then
    raise exception 'Not a member of this couple household'
      using errcode = '42501';
  end if;

  insert into public.couple_challenge_completions (
    household_id, week_index, challenge_id, completed_by
  ) values (
    p_household_id, p_week_index, p_challenge_id, v_completer
  )
  on conflict (household_id, week_index) do nothing;

  if not found then
    return jsonb_build_object(
      'success', true,
      'status', 'already_completed',
      'message', 'Challenge already completed this week',
      'duplicate', true,
      'xp_earned', 0,
      'coins_earned', 0
    );
  end if;

  v_activity_request_id :=
    'challenge:' || coalesce(p_request_id, gen_random_uuid()::text);

  insert into public.household_activities (
    household_id, user_id, event_type, title, description, metadata, request_id
  ) values (
    p_household_id,
    v_completer,
    'couple_challenge_completed',
    p_title,
    p_description,
    jsonb_build_object(
      'challenge_id', p_challenge_id,
      'week_index', p_week_index,
      'is_couple_challenge', true,
      'shared_memory', true
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

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    v_completer,
    p_household_id,
    'complete_couple_challenge',
    'couple_challenge',
    v_activity_id,
    jsonb_build_object(
      'challenge_id', p_challenge_id,
      'week_index', p_week_index,
      'activity_id', v_activity_id,
      'transactional_rewards', false
    ),
    'Couple challenge saved as a shared memory',
    'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'status', 'completed',
    'activity_id', v_activity_id,
    'xp_earned', 0,
    'coins_earned', 0
  );
end;
$function$;

-- Defense in depth for every current and legacy task/challenge/winner RPC.
-- Returning null from a BEFORE INSERT trigger safely skips the ledger entry.
create or replace function public.prevent_couple_gamification_ledger()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if new.currency in ('XP', 'COIN')
    and exists (
      select 1
      from public.households h
      where h.id = new.household_id
        and h.household_type = 'couple'
    )
  then
    return null;
  end if;

  return new;
end;
$function$;

drop trigger if exists prevent_couple_gamification_ledger_trigger
  on public.ledger_entries;
create trigger prevent_couple_gamification_ledger_trigger
before insert on public.ledger_entries
for each row execute function public.prevent_couple_gamification_ledger();

-- Older app versions may still try to close a weekly duel. Keep existing
-- history for audit, but reject new competitive records for couple homes.
create or replace function public.block_couple_competitive_rows()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    raise exception using
      errcode = '23514',
      message = 'Competitive rankings are not available for couple households';
  end if;

  return new;
end;
$function$;

drop trigger if exists block_couple_weekly_winners_trigger
  on public.weekly_winners;
create trigger block_couple_weekly_winners_trigger
before insert or update of household_id on public.weekly_winners
for each row execute function public.block_couple_competitive_rows();

drop trigger if exists block_couple_weekly_duel_history_trigger
  on public.weekly_duel_history;
create trigger block_couple_weekly_duel_history_trigger
before insert or update of household_id on public.weekly_duel_history
for each row execute function public.block_couple_competitive_rows();

-- Retire the old couple catalog while leaving its rows available for audit.
update public.rewards r
set is_active = false
from public.households h
where h.id = r.household_id
  and h.household_type = 'couple'
  and r.is_active = true;

create or replace function public.block_couple_reward_catalog_writes()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    if tg_op = 'INSERT' then
      raise exception using
        errcode = '23514',
        message = 'The reward catalog is not available for couple households';
    end if;

    new.is_active := false;
  end if;

  return new;
end;
$function$;

drop trigger if exists block_couple_reward_catalog_writes_trigger
  on public.rewards;
create trigger block_couple_reward_catalog_writes_trigger
before insert or update of household_id, is_active on public.rewards
for each row execute function public.block_couple_reward_catalog_writes();

-- The reward store remains a family feature. Any adult family administrator
-- (owner or admin), rather than only the household creator, can manage it.
create or replace function private.can_manage_family_rewards(
  p_household_id uuid
) returns boolean
language sql
stable
security definer
set search_path to 'public'
as $function$
  select exists (
    select 1
    from public.household_members hm
    join public.households h on h.id = hm.household_id
    where hm.household_id = p_household_id
      and hm.user_id = public.current_app_user_id()
      and hm.role in ('owner', 'admin')
      and coalesce(hm.member_type, 'parent')
        in ('parent', 'guardian', 'adult')
      and h.household_type = 'family'
  );
$function$;

revoke all on function private.can_manage_family_rewards(uuid)
  from public, anon;
grant usage on schema private to authenticated, service_role;
grant execute on function private.can_manage_family_rewards(uuid)
  to authenticated, service_role;

drop policy if exists "Owners can insert rewards" on public.rewards;
create policy "Adult family admins can insert rewards"
on public.rewards
for insert
to authenticated
with check (private.can_manage_family_rewards(household_id));

drop policy if exists "Owners can update rewards" on public.rewards;
create policy "Adult family admins can update rewards"
on public.rewards
for update
to authenticated
using (private.can_manage_family_rewards(household_id))
with check (private.can_manage_family_rewards(household_id));

drop policy if exists "Owners can delete rewards" on public.rewards;
create policy "Adult family admins can delete rewards"
on public.rewards
for delete
to authenticated
using (private.can_manage_family_rewards(household_id));

-- Legacy clients can still call the retired reward catalog RPC. Blocking the
-- redemption row makes that entire transaction fail instead of granting a
-- reward after the ledger debit above was intentionally skipped.
create or replace function public.block_couple_reward_redemptions()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    raise exception using
      errcode = '23514',
      message = 'The reward catalog is not available for couple households';
  end if;

  return new;
end;
$function$;

drop trigger if exists block_couple_reward_redemptions_trigger
  on public.reward_redemptions;
create trigger block_couple_reward_redemptions_trigger
before insert on public.reward_redemptions
for each row execute function public.block_couple_reward_redemptions();

-- Old task RPCs can include reward fields in activity metadata even when no
-- ledger entry is created. Strip those fields so historical feeds cannot
-- imply that a couple earned a currency that no longer exists.
create or replace function public.strip_couple_activity_rewards()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    new.metadata := coalesce(new.metadata, '{}'::jsonb)
      - 'xp_reward'
      - 'xp_per_user'
      - 'xp'
      - 'coins_reward'
      - 'coins_per_user'
      - 'coins'
      - 'reward_cost';
  end if;

  return new;
end;
$function$;

drop trigger if exists strip_couple_activity_rewards_trigger
  on public.household_activities;
create trigger strip_couple_activity_rewards_trigger
before insert or update of household_id, metadata
on public.household_activities
for each row execute function public.strip_couple_activity_rewards();

update public.household_activities ha
set metadata = coalesce(ha.metadata, '{}'::jsonb)
  - 'xp_reward'
  - 'xp_per_user'
  - 'xp'
  - 'coins_reward'
  - 'coins_per_user'
  - 'coins'
  - 'reward_cost'
from public.households h
where h.id = ha.household_id
  and h.household_type = 'couple'
  and coalesce(ha.metadata, '{}'::jsonb) ?| array[
    'xp_reward',
    'xp_per_user',
    'xp',
    'coins_reward',
    'coins_per_user',
    'coins',
    'reward_cost'
  ];

-- Approval rows are another reward-bearing boundary. Normalize them from the
-- task row so legacy command paths cannot persist forged values for a later
-- adult approval.
create or replace function public.normalize_task_approval_rewards_v1()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_household_type text;
  v_any_child boolean := false;
begin
  select
    t.title,
    coalesce(t.xp_reward, 0),
    coalesce(t.coin_reward, 0),
    h.household_type
  into
    new.task_title,
    new.xp_reward,
    new.coin_reward,
    v_household_type
  from public.tasks t
  join public.households h on h.id = t.household_id
  where t.id = new.task_id;

  if not found then
    raise exception 'Task not found for approval' using errcode = '23503';
  end if;

  if v_household_type = 'family' then
    select exists (
      select 1
      from public.household_members hm
      where hm.household_id = new.household_id
        and hm.user_id = any(new.performers)
        and hm.member_type = 'child'
    ) into v_any_child;

    if v_any_child and new.coin_reward < 1 then
      new.coin_reward := 1;
    end if;
  end if;

  return new;
end;
$function$;

drop trigger if exists normalize_task_approval_rewards_v1_trigger
  on public.task_approvals;
create trigger normalize_task_approval_rewards_v1_trigger
before insert or update of task_id, household_id, performers,
  xp_reward, coin_reward
on public.task_approvals
for each row execute function public.normalize_task_approval_rewards_v1();

-- Couple tasks have no convertible rewards. Other modes retain customizable
-- rewards within a bounded server-side range, so direct writes and old clients
-- cannot create tasks that mint arbitrary balances.
create or replace function public.normalize_task_rewards_v1()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if exists (
    select 1
    from public.households h
    where h.id = new.household_id
      and h.household_type = 'couple'
  ) then
    new.xp_reward := 0;
    new.coin_reward := 0;
  else
    new.xp_reward := least(greatest(coalesce(new.xp_reward, 0), 0), 50);
    new.coin_reward := least(greatest(coalesce(new.coin_reward, 0), 0), 5);
  end if;

  return new;
end;
$function$;

drop trigger if exists normalize_couple_task_rewards_trigger on public.tasks;
drop trigger if exists normalize_task_rewards_v1_trigger on public.tasks;
create trigger normalize_task_rewards_v1_trigger
before insert or update of household_id, xp_reward, coin_reward on public.tasks
for each row execute function public.normalize_task_rewards_v1();

-- Normalize existing rows so every read/completion path sees the same limits.
update public.tasks t
set xp_reward = case
      when h.household_type = 'couple' then 0
      else least(greatest(coalesce(t.xp_reward, 0), 0), 50)
    end,
    coin_reward = case
      when h.household_type = 'couple' then 0
      else least(greatest(coalesce(t.coin_reward, 0), 0), 5)
    end,
    updated_at = now()
from public.households h
where h.id = t.household_id
  and (
    (h.household_type = 'couple'
      and (t.xp_reward <> 0 or t.coin_reward <> 0))
    or t.xp_reward < 0
    or t.xp_reward > 50
    or t.coin_reward < 0
    or t.coin_reward > 5
  );

-- Re-evaluate already pending approvals after the task backfill above.
update public.task_approvals
set xp_reward = xp_reward
where status = 'pending';
