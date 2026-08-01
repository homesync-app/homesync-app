-- Reconstructed from remote migration history (version 20260415131508).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


alter table public.users
  drop constraint if exists users_id_fkey;
;