-- Reconstructed from remote migration history (version 20260321180453).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

BEGIN;

-- Keep UNIQUE/PK indexes, drop redundant non-unique duplicates.
DROP INDEX IF EXISTS public.idx_household_invitations_code;
DROP INDEX IF EXISTS public.idx_household_members_user;
DROP INDEX IF EXISTS public.idx_mp_id;
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_weekly_winners_household_week;

COMMIT;
