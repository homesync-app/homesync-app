-- Reconstructed from remote migration history (version 20260329212845).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

drop function if exists public.qa_admin_update_task_v1(uuid, uuid, text, text, text, uuid, timestamptz, text, integer, integer[], integer[], text);
