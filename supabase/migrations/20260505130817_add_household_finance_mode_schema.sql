-- Reconstructed from remote migration history (version 20260505130817).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

alter table public.households
  add column if not exists finance_mode text not null default 'divided';

alter table public.households
  drop constraint if exists households_finance_mode_chk;

alter table public.households
  add constraint households_finance_mode_chk
  check (finance_mode in ('shared', 'divided'));

alter table public.households
  alter column finance_mode set default 'shared';
