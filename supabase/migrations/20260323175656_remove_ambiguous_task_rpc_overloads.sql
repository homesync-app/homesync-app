-- The next imported migration grants EXECUTE without argument lists.
-- Remove stale overloads first so those historical GRANT statements are
-- unambiguous and PostgREST exposes only the newly recreated contracts.

do $block$
declare
  v_function record;
begin
  for v_function in
    select format(
      '%I.%I(%s)',
      n.nspname,
      p.proname,
      pg_get_function_identity_arguments(p.oid)
    ) as signature
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'create_task',
        'complete_task_transaction',
        'complete_tasks_batch'
      )
  loop
    execute format('drop function %s', v_function.signature);
  end loop;
end;
$block$;
