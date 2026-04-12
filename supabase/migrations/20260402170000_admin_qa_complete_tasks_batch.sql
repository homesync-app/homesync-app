create or replace function public.qa_admin_complete_tasks_batch(
  p_household_id uuid,
  p_user_ids uuid[],
  p_tasks jsonb,
  p_completed_at timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_task jsonb;
  v_result jsonb;
  v_results jsonb := '[]'::jsonb;
  v_success_count integer := 0;
  v_skipped_count integer := 0;
begin
  perform public.qa_admin_require_access();

  if p_tasks is null or jsonb_typeof(p_tasks) <> 'array' then
    raise exception 'Debe informarse un arreglo de tareas';
  end if;

  for v_task in
    select value
    from jsonb_array_elements(p_tasks)
  loop
    v_result := public.qa_admin_complete_task(
      p_household_id,
      p_user_ids,
      (v_task->>'task_id')::uuid,
      coalesce((v_task->>'xp_reward')::integer, 0),
      coalesce((v_task->>'coin_reward')::integer, 0),
      coalesce(v_task->>'task_title', ''),
      p_completed_at
    );

    v_results := v_results || jsonb_build_array(v_result);

    if coalesce((v_result->>'success')::boolean, false) then
      v_success_count := v_success_count + 1;
    else
      v_skipped_count := v_skipped_count + 1;
    end if;
  end loop;

  return jsonb_build_object(
    'success', true,
    'message', format(
      'Tareas procesadas: %s ok, %s omitidas',
      v_success_count,
      v_skipped_count
    ),
    'results', v_results,
    'success_count', v_success_count,
    'skipped_count', v_skipped_count
  );
end;
$$;

grant execute on function public.qa_admin_complete_tasks_batch(uuid, uuid[], jsonb, timestamptz) to authenticated;
