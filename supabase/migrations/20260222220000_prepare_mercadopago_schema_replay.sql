-- The two imported MercadoPago migrations create the same SELECT policy.
-- Remove the first definition so the later historical migration can replay.
-- On an existing hosted project this shim must be marked as applied, because
-- the migration that recreates the policy has already run there.

drop policy if exists "Users can view their own connections"
  on public.mercadopago_connections;
