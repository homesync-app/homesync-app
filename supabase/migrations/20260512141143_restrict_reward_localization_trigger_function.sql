-- Reconstructed from remote migration history (version 20260512141143).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- The rewards localization trigger function is only meant to run as a trigger,
-- never as a client-callable RPC.

REVOKE EXECUTE ON FUNCTION public.set_reward_localization_keys() FROM anon, authenticated, public;
