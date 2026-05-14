-- The rewards localization trigger function is only meant to run as a trigger,
-- never as a client-callable RPC.

REVOKE EXECUTE ON FUNCTION public.set_reward_localization_keys() FROM anon, authenticated, public;
