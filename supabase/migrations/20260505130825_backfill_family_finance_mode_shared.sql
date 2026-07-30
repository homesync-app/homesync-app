-- Reconstructed from remote migration history (version 20260505130825).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

alter table public.households disable trigger user;

update public.households
set finance_mode = 'shared'
where household_type = 'family';

alter table public.households enable trigger user;
