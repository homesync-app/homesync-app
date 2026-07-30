-- The following reconstructed hardening migration recreates this policy
-- without dropping the copy already applied earlier in the same history.

drop policy if exists "service_role can manage mercadopago_connections"
  on public.mercadopago_connections;
