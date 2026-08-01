-- RLS does not protect TRUNCATE and authenticated inherited broad table
-- privileges from the original CREATE TABLE/default grants. Keep only the
-- operations used by the app and authenticated admin workspace.

revoke all on table public.user_feedback
  from public, anon, authenticated;

grant insert, select, update on table public.user_feedback
  to authenticated;

grant all on table public.user_feedback
  to service_role;
