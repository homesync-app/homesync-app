-- Mirror of MCP-applied migration: deduplicate_redundant_unique_covering_indexes
BEGIN;

ALTER TABLE public.household_members
  DROP CONSTRAINT IF EXISTS household_members_household_user_unique;

DROP INDEX IF EXISTS public.idx_household_members_household_user;
DROP INDEX IF EXISTS public.idx_household_invitations_code;
DROP INDEX IF EXISTS public.idx_household_members_user;
DROP INDEX IF EXISTS public.idx_mp_id;
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_weekly_winners_household_week;

COMMIT;