-- Reconstructed from remote migration history (version 20260523003425).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Action RPCs are SECURITY DEFINER and must not be callable with only the
-- public anon key. Keep authenticated app users and service-role admin tools
-- explicit, and remove Postgres' default PUBLIC execute grant.

revoke execute on function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) from public, anon;
grant execute on function public.complete_task_v1(
  text, uuid[], uuid, uuid, integer, integer, text, timestamptz
) to authenticated, service_role;

revoke execute on function public.complete_task_transaction(
  text, uuid[], uuid, uuid, integer, integer, text
) from public, anon;
grant execute on function public.complete_task_transaction(
  text, uuid[], uuid, uuid, integer, integer, text
) to authenticated, service_role;

revoke execute on function public.approve_task_v1(
  text, uuid, uuid, uuid, timestamptz
) from public, anon;
grant execute on function public.approve_task_v1(
  text, uuid, uuid, uuid, timestamptz
) to authenticated, service_role;

revoke execute on function public.verify_task_transaction(
  text, uuid, uuid, uuid, timestamptz
) from public, anon;
grant execute on function public.verify_task_transaction(
  text, uuid, uuid, uuid, timestamptz
) to authenticated, service_role;

revoke execute on function public.reject_task_v1(
  text, uuid, uuid, uuid, text
) from public, anon;
grant execute on function public.reject_task_v1(
  text, uuid, uuid, uuid, text
) to authenticated, service_role;

revoke execute on function public.reject_task_transaction(
  text, uuid, uuid, uuid, text
) from public, anon;
grant execute on function public.reject_task_transaction(
  text, uuid, uuid, uuid, text
) to authenticated, service_role;

revoke execute on function public.undo_task_completion_v1(
  uuid, uuid
) from public, anon;
grant execute on function public.undo_task_completion_v1(
  uuid, uuid
) to authenticated, service_role;

revoke execute on function public.undo_task_completion(
  uuid, uuid
) from public, anon;
grant execute on function public.undo_task_completion(
  uuid, uuid
) to authenticated, service_role;

revoke execute on function public.delete_task_v1(uuid) from public, anon;
grant execute on function public.delete_task_v1(uuid) to authenticated, service_role;
