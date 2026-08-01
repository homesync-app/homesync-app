-- Put the existing task-completion implementation behind an authorization
-- boundary. The internal function keeps all completion/reward semantics while
-- the public legacy signature validates actor, household, assignment and
-- performers before delegating.

alter function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) rename to _complete_task_v1_unchecked;

revoke execute on function public._complete_task_v1_unchecked(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) from public, anon, authenticated, service_role;

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
set search_path = ''
as $function$
declare
  v_actor uuid := public.current_app_user_id();
  v_task_household_id uuid;
  v_assigned_to uuid;
  v_household_type text;
  v_actor_role text;
  v_actor_member_type text;
  v_is_family_admin_adult boolean := false;
begin
  if v_actor is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Not authenticated',
      'status', 'unauthenticated'
    );
  end if;

  if p_user_ids is null or cardinality(p_user_ids) = 0 then
    return jsonb_build_object(
      'success', false,
      'message', 'At least one performer is required',
      'status', 'invalid'
    );
  end if;

  if exists (
    select 1
    from unnest(p_user_ids) as performer(user_id)
    where performer.user_id is null
  ) or cardinality(p_user_ids) <> (
    select count(distinct performer.user_id)
    from unnest(p_user_ids) as performer(user_id)
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Performers must be unique non-null users',
      'status', 'invalid'
    );
  end if;

  select t.household_id, t.assigned_to, h.household_type
    into v_task_household_id, v_assigned_to, v_household_type
  from public.tasks t
  join public.households h on h.id = t.household_id
  where t.id = p_task_id
  for update of t;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Task not found',
      'status', 'skipped'
    );
  end if;

  if v_task_household_id <> p_household_id then
    return jsonb_build_object(
      'success', false,
      'message', 'Task does not belong to the requested household',
      'status', 'forbidden'
    );
  end if;

  select hm.role, hm.member_type
    into v_actor_role, v_actor_member_type
  from public.household_members hm
  where hm.household_id = v_task_household_id
    and hm.user_id = v_actor;

  if not found then
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
      where hm.household_id = v_task_household_id
        and hm.user_id = performer.user_id
    )
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Every performer must belong to the household',
      'status', 'forbidden'
    );
  end if;

  v_is_family_admin_adult :=
    v_household_type = 'family'
    and v_actor_role in ('owner', 'admin')
    and coalesce(v_actor_member_type, 'parent')
      in ('parent', 'guardian', 'adult');

  if cardinality(p_user_ids) = 1 and p_user_ids[1] = v_actor then
    null;
  elsif v_is_family_admin_adult and not exists (
    select 1
    from unnest(p_user_ids) as performer(user_id)
    join public.household_members hm
      on hm.household_id = v_task_household_id
     and hm.user_id = performer.user_id
    where coalesce(hm.member_type, '') not in ('child', 'teen')
  ) then
    null;
  else
    return jsonb_build_object(
      'success', false,
      'message', 'Actor cannot complete tasks for these performers',
      'status', 'forbidden'
    );
  end if;

  if v_assigned_to is not null and not (v_assigned_to = any(p_user_ids)) then
    return jsonb_build_object(
      'success', false,
      'message', 'The assigned member must be included as a performer',
      'status', 'forbidden'
    );
  end if;

  return public._complete_task_v1_unchecked(
    p_request_id,
    p_user_ids,
    p_task_id,
    v_task_household_id,
    p_xp_reward,
    p_coin_reward,
    p_task_title,
    p_completed_at
  );
end;
$function$;

revoke execute on function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) from public, anon;
grant execute on function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) to authenticated, service_role;

comment on function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) is 'Authorizes task performers before delegating to the server-authoritative completion implementation.';
