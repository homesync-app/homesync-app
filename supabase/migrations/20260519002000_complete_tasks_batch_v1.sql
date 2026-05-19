-- =============================================================================
-- complete_tasks_batch_v1: versioned, transactional, idempotent batch complete
-- =============================================================================
-- Bug latente que cierra esta migracion:
--   El cliente ya llamaba al RPC `complete_tasks_batch` (sin versionar) tanto
--   en el camino online (task_rpc_service.dart) como en la cola offline
--   (supabase_task_repository.dart), pero ese nombre NO existia en migraciones:
--   solo estaba `qa_admin_complete_tasks_batch` (helper de QA). En produccion
--   completar tareas en lote fallaba o dependia de una funcion de testing.
--
-- Estrategia (misma filosofia que 20260514120000_task_commands_v1.sql):
--   1. complete_tasks_batch_v1: itera task_ids y delega cada una a
--      complete_task_v1. El cliente solo manda ids, asi que el batch resuelve
--      title/xp_reward/coin_reward desde public.tasks por tarea.
--   2. Idempotencia: a cada tarea se le pasa un request_id derivado del batch
--      (`p_request_id || ':' || task_id`). complete_task_v1 ya namespacea y
--      deduplica por request_id, asi que reintentar el lote completo NO duplica
--      activities ni acredita XP/coins dos veces. Completar parcialmente y
--      reintentar tampoco re-acredita las ya hechas.
--   3. Transaccional: una funcion plpgsql corre en una sola transaccion; el
--      lote es atomico. complete_task_v1 devuelve success:false (no exception)
--      para tareas no completables, asi que una tarea omitida no hace rollback
--      del resto (mismo comportamiento que qa_admin_complete_tasks_batch).
--   4. Legacy wrapper `complete_tasks_batch` (sin versionar): REQUERIDO, no
--      opcional. Hay acciones offline ya persistidas en dispositivos con
--      target 'complete_tasks_batch'; el wrapper las mantiene funcionando.
--
-- Contrato documentado en docs/rpc_contracts.md.
-- =============================================================================

create or replace function public.complete_tasks_batch_v1(
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
  v_title text;
  v_xp integer;
  v_coin integer;
  v_result jsonb;
  v_results jsonb := '[]'::jsonb;
  v_success_count integer := 0;
  v_skipped_count integer := 0;
begin
  if p_user_ids is null or coalesce(array_length(p_user_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', false,
      'message', 'At least one performer is required',
      'status', 'invalid'
    );
  end if;

  if p_task_ids is null or coalesce(array_length(p_task_ids, 1), 0) = 0 then
    return jsonb_build_object(
      'success', true,
      'message', 'No tasks to complete',
      'results', '[]'::jsonb,
      'success_count', 0,
      'skipped_count', 0
    );
  end if;

  foreach v_task_id in array p_task_ids loop
    -- El cliente solo manda ids; resolvemos rewards/title desde la tabla.
    select title, xp_reward, coin_reward
      into v_title, v_xp, v_coin
    from public.tasks
    where id = v_task_id
      and household_id = p_household_id;

    if not found then
      v_result := jsonb_build_object(
        'success', false,
        'message', 'Task not found in household',
        'status', 'skipped',
        'task_id', v_task_id
      );
    else
      -- request_id por tarea derivado del batch -> idempotencia ante reintento
      -- del lote completo o parcial (complete_task_v1 deduplica por request_id).
      v_result := public.complete_task_v1(
        p_request_id || ':' || v_task_id::text,
        p_user_ids,
        v_task_id,
        p_household_id,
        coalesce(v_xp, 0),
        coalesce(v_coin, 0),
        coalesce(v_title, ''),
        p_completed_at
      );
    end if;

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

grant execute on function public.complete_tasks_batch_v1(text, uuid[], uuid[], uuid, timestamptz)
  to authenticated, service_role;


-- Legacy wrapper: clientes en vuelo + acciones offline ya encoladas en
-- dispositivos siguen llamando 'complete_tasks_batch'. Borrar despues de
-- 1-2 releases una vez que no queden colas viejas.
create or replace function public.complete_tasks_batch(
  p_request_id text,
  p_user_ids uuid[],
  p_task_ids uuid[],
  p_household_id uuid,
  p_completed_at timestamptz default null
)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select public.complete_tasks_batch_v1(
    p_request_id, p_user_ids, p_task_ids, p_household_id, p_completed_at
  );
$$;

grant execute on function public.complete_tasks_batch(text, uuid[], uuid[], uuid, timestamptz)
  to authenticated, service_role;
