-- Restore the final TEXT contract immediately after the imported migration
-- and keep the two legacy functions valid with explicit UUID-to-TEXT casts.

alter table public.ledger_entries
  alter column reference_id type text
  using reference_id::text;

create or replace function public.object_task(
  p_task_id uuid,
  p_user_id uuid,
  p_reason text
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_task record;
begin
  select * into v_task
  from public.tasks
  where id = p_task_id;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Tarea no encontrada'
    );
  end if;

  if v_task.status <> 'verified' then
    return jsonb_build_object(
      'success', false,
      'message', 'Solo tareas verificadas'
    );
  end if;

  update public.tasks
  set status = 'objected',
      objection_reason = p_reason,
      objected_by = p_user_id,
      objected_at = now(),
      updated_at = now()
  where id = p_task_id;

  insert into public.ledger_entries (
    user_id,
    household_id,
    amount,
    currency,
    type,
    description,
    reference_type,
    reference_id
  ) values (
    v_task.completed_by,
    v_task.household_id,
    -v_task.coin_reward,
    'COIN',
    'coins_removed',
    'Tarea objetada',
    'task',
    p_task_id::text
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Coins removidos'
  );
end;
$function$;

create or replace function public.restore_task_coins(
  p_task_id uuid,
  p_user_id uuid
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_task record;
begin
  select * into v_task
  from public.tasks
  where id = p_task_id;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Tarea no encontrada'
    );
  end if;

  if v_task.status <> 'objected' then
    return jsonb_build_object(
      'success', false,
      'message', 'La tarea no está objetada'
    );
  end if;

  update public.tasks
  set status = 'verified',
      objection_reason = null,
      objected_by = null,
      objected_at = null,
      updated_at = now()
  where id = p_task_id;

  insert into public.ledger_entries (
    user_id,
    household_id,
    amount,
    currency,
    type,
    description,
    reference_type,
    reference_id
  ) values (
    v_task.completed_by,
    v_task.household_id,
    v_task.coin_reward,
    'COIN',
    'coins_restored',
    'Coins restaurados',
    'task',
    p_task_id::text
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Coins restaurados'
  );
end;
$function$;
