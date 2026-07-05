-- Route batch task completion through the canonical task command so Parent
-- Mode approvals are enforced consistently from every UI entry point.

create or replace function public.complete_tasks_batch(
  p_request_id text,
  p_user_ids uuid[],
  p_task_ids uuid[],
  p_household_id uuid,
  p_completed_at timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_task_id uuid;
  v_task_title text;
  v_xp_reward integer;
  v_coin_reward integer;
  v_result jsonb;
  v_completed_count integer := 0;
  v_pending_count integer := 0;
  v_direct_count integer := 0;
  v_skipped_count integer := 0;
begin
  if p_user_ids is null or coalesce(array_length(p_user_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', false,
      'message', 'At least one performer is required',
      'completed_count', 0,
      'pending_count', 0,
      'direct_count', 0,
      'skipped_count', coalesce(array_length(p_task_ids, 1), 0)
    );
  end if;

  if p_task_ids is null or coalesce(array_length(p_task_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', true,
      'message', '0 tasks completed in batch',
      'completed_count', 0,
      'pending_count', 0,
      'direct_count', 0,
      'skipped_count', 0
    );
  end if;

  foreach v_task_id in array p_task_ids loop
    select title, xp_reward, coin_reward
      into v_task_title, v_xp_reward, v_coin_reward
    from public.tasks
    where id = v_task_id
      and household_id = p_household_id;

    if not found then
      v_skipped_count := v_skipped_count + 1;
      continue;
    end if;

    v_result := public.complete_task_v1(
      p_request_id || ':' || v_task_id::text,
      p_user_ids,
      v_task_id,
      p_household_id,
      coalesce(v_xp_reward, 0),
      coalesce(v_coin_reward, 0),
      v_task_title,
      p_completed_at
    );

    if coalesce((v_result->>'success')::boolean, false) then
      v_completed_count := v_completed_count + 1;
      if v_result->>'task_status' = 'pending_approval'
          or coalesce((v_result->>'requires_approval')::boolean, false) then
        v_pending_count := v_pending_count + 1;
      else
        v_direct_count := v_direct_count + 1;
      end if;
    else
      v_skipped_count := v_skipped_count + 1;
    end if;
  end loop;

  return jsonb_build_object(
    'success', true,
    'message', v_completed_count::text || ' tasks processed in batch',
    'completed_count', v_completed_count,
    'pending_count', v_pending_count,
    'direct_count', v_direct_count,
    'skipped_count', v_skipped_count
  );
end;
$$;

revoke execute on function public.complete_tasks_batch(
  text, uuid[], uuid[], uuid, timestamptz
) from anon;

grant execute on function public.complete_tasks_batch(
  text, uuid[], uuid[], uuid, timestamptz
) to authenticated, service_role;

notify pgrst, 'reload schema';
