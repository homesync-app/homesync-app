-- RevenueCat tables are private service-role tables.
-- Explicit deny policies keep RLS intentional and silence the "RLS enabled
-- without policy" advisor while grants remain revoked from client roles.

create policy "RevenueCat webhook events are private"
  on public.revenuecat_webhook_events
  for all
  to anon, authenticated
  using (false)
  with check (false);

create policy "RevenueCat customer state is private"
  on public.revenuecat_customer_state
  for all
  to anon, authenticated
  using (false)
  with check (false);
