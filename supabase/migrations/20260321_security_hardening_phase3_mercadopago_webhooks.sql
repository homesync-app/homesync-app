-- Security hardening phase 3
-- Keep mercadopago_webhooks table/config, but make RLS explicit and safe.
-- No access for anon/authenticated. Only service_role can operate if ever needed.

DROP POLICY IF EXISTS "service_role can manage mercadopago_webhooks" ON public.mercadopago_webhooks;

CREATE POLICY "service_role can manage mercadopago_webhooks"
ON public.mercadopago_webhooks
AS PERMISSIVE
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);
