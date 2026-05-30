-- Reconstructed from remote migration history (version 20260511113127).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

revoke execute on function public.clone_task_templates(uuid, uuid[]) from public;
revoke execute on function public.clone_task_templates(uuid, uuid[]) from anon;
grant execute on function public.clone_task_templates(uuid, uuid[]) to authenticated;
