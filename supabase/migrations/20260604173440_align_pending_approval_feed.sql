-- Keep Home activity review cards aligned with approve_task_v1/reject_task_v1.
-- A task can be left in pending_approval after an old/manual approval cleanup,
-- but the actionable source of truth is task_approvals.status = 'pending'.

do $$
declare
  src text;
  old_cte text;
  new_cte text;
begin
  select pg_get_functiondef(
    'public.get_home_bootstrap(integer,integer,integer)'::regprocedure
  )
    into src;

  old_cte := $old$
  pending_approvals as (
    select
      ('pending-task-' || t.id::text) as id,
      'task_pending_approval'::text as type,
      coalesce(t.completed_at, now()) as created_at,
      t.completed_by as creator_id,
      jsonb_build_object(
        'user_name', coalesce(u.full_name, 'Alguien'),
        'avatar_url', u.avatar_url,
        'title', coalesce(t.title, 'Tarea del hogar'),
        'task_title', coalesce(t.title, 'Tarea del hogar'),
        'title_key', t.title_key,
        'task_id', t.id,
        'category', t.category,
        'xp_reward', t.xp_reward,
        'coins_reward', t.coin_reward,
        'approval_status', 'pending_approval',
        'task_status', 'pending_approval'
      ) as data
    from public.tasks t
    left join public.users u on u.id = t.completed_by
    where t.household_id = v_household_id
      and t.status = 'pending_approval'
      and (t.completed_at is null or t.completed_at >= v_activity_since)
    order by t.completed_at desc nulls last
    limit 20
  ),
$old$;

  new_cte := $new$
  pending_approvals as (
    select
      ('pending-task-' || ta.id::text) as id,
      'task_pending_approval'::text as type,
      ta.created_at as created_at,
      ta.submitted_by as creator_id,
      jsonb_build_object(
        'user_name', coalesce(u.full_name, 'Alguien'),
        'avatar_url', u.avatar_url,
        'title', coalesce(ta.task_title, t.title, 'Tarea del hogar'),
        'task_title', coalesce(ta.task_title, t.title, 'Tarea del hogar'),
        'title_key', t.title_key,
        'task_id', ta.task_id,
        'approval_id', ta.id,
        'category', t.category,
        'xp_reward', ta.xp_reward,
        'coins_reward', ta.coin_reward,
        'approval_status', 'pending_approval',
        'task_status', 'pending_approval'
      ) as data
    from public.task_approvals ta
    join public.tasks t on t.id = ta.task_id
    left join public.users u on u.id = ta.submitted_by
    where ta.household_id = v_household_id
      and ta.status = 'pending'
      and ta.created_at >= v_activity_since
    order by ta.created_at desc
    limit 20
  ),
$new$;

  -- Dollar-quoted function bodies preserve the migration file line endings.
  -- Normalize them so this textual patch works identically on LF and CRLF.
  src := replace(src, E'\r\n', E'\n');
  old_cte := replace(old_cte, E'\r\n', E'\n');
  new_cte := replace(new_cte, E'\r\n', E'\n');

  if position(old_cte in src) = 0 then
    raise exception 'get_home_bootstrap pending_approvals CTE not found';
  end if;

  execute replace(src, old_cte, new_cte);
end $$;
