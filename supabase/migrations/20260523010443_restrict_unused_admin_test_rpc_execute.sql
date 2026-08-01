-- Reconstructed from remote migration history (version 20260523010443).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- These admin/test RPCs are not called by the current app or admin console.
-- Keep service-role access for operator scripts, but remove them from the
-- authenticated PostgREST surface.

revoke execute on function public.admin_get_all_households()
  from public, anon, authenticated;
grant execute on function public.admin_get_all_households()
  to service_role;

revoke execute on function public.admin_add_member_to_household(uuid, text, text)
  from public, anon, authenticated;
grant execute on function public.admin_add_member_to_household(uuid, text, text)
  to service_role;

revoke execute on function public.test_finalize_weekly_duel(uuid)
  from public, anon, authenticated;
grant execute on function public.test_finalize_weekly_duel(uuid)
  to service_role;
