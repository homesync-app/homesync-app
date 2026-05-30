-- Reconstructed from remote migration history (version 20260523003725).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Finance mutation RPCs are SECURITY DEFINER and must require an authenticated
-- app user. Remove inherited PUBLIC/anon execute grants while keeping app and
-- admin/service-role calls explicit.

revoke execute on function public.delete_expense_v1(uuid) from public, anon;
grant execute on function public.delete_expense_v1(uuid) to authenticated, service_role;

revoke execute on function public.settle_debt_v1(
  text, uuid, uuid, uuid, numeric
) from public, anon;
grant execute on function public.settle_debt_v1(
  text, uuid, uuid, uuid, numeric
) to authenticated, service_role;
