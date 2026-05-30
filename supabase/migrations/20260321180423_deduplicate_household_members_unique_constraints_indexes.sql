-- Reconstructed from remote migration history (version 20260321180423).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

BEGIN;

-- Keep canonical unique: household_members_household_id_user_id_key
-- Drop accidental duplicate unique constraint/index from previous hardening pass.
ALTER TABLE public.household_members
  DROP CONSTRAINT IF EXISTS household_members_household_user_unique;

-- Drop redundant non-unique index; canonical unique index already covers (household_id, user_id).
DROP INDEX IF EXISTS public.idx_household_members_household_user;

COMMIT;
