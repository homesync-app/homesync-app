-- Close privileged RPC escalation paths while preserving authenticated app/admin APIs.
-- Internal QA helpers remain callable by their SECURITY DEFINER wrappers because
-- those wrappers execute as the function owner.

alter default privileges for role postgres in schema public
  revoke execute on functions from public;
alter default privileges for role postgres in schema public
  revoke execute on functions from anon;
alter default privileges for role postgres in schema public
  revoke execute on functions from authenticated;

do $migration$
declare
  v_function record;
begin
  for v_function in
    select p.oid, n.nspname, p.proname
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname like 'qa_admin_%'
  loop
    execute format(
      'revoke execute on function %I.%I(%s) from public, anon, service_role',
      v_function.nspname,
      v_function.proname,
      pg_get_function_identity_arguments(v_function.oid)
    );

    if v_function.proname = any (array[
      'qa_admin_require_access',
      'qa_admin_ensure_identity',
      'qa_admin_household_defaults',
      'qa_admin_seed_scenario_members',
      'qa_admin_reset_scenario_internal'
    ]) then
      execute format(
        'revoke execute on function %I.%I(%s) from authenticated',
        v_function.nspname,
        v_function.proname,
        pg_get_function_identity_arguments(v_function.oid)
      );
    end if;
  end loop;
end;
$migration$;

revoke execute on function public.set_premium_status(boolean, timestamptz)
  from public, anon, authenticated, service_role;
revoke execute on function public.toggle_premium_mock()
  from public, anon, authenticated, service_role;
grant execute on function public.toggle_premium_mock() to service_role;

comment on function public.set_premium_status(boolean, timestamptz) is
  'Internal premium mutation primitive. Clients must use purchase verification or the guarded admin RPC.';
comment on function public.toggle_premium_mock() is
  'Trusted-tooling-only premium mock. Not executable by authenticated app clients.';

-- Product readers derive identity from the JWT and remain app-accessible.
revoke execute on function public.get_effective_premium_status()
  from public, anon, service_role;
grant execute on function public.get_effective_premium_status() to authenticated;

revoke execute on function public.get_household_premium_status(uuid)
  from public, anon, service_role;
grant execute on function public.get_household_premium_status(uuid) to authenticated;

revoke execute on function public.is_household_premium(uuid)
  from public, anon, service_role;
grant execute on function public.is_household_premium(uuid) to authenticated;

-- The admin portal uses an authenticated admin session and never service_role.
revoke execute on function public.admin_search_users(text, integer)
  from public, anon, service_role;
revoke execute on function public.admin_set_household_premium(uuid, boolean, timestamptz)
  from public, anon, service_role;
revoke execute on function public.admin_get_active_user_stats()
  from public, anon, service_role;
revoke execute on function public.admin_get_all_households()
  from public, anon, service_role;
grant execute on function public.admin_search_users(text, integer) to authenticated;
grant execute on function public.admin_set_household_premium(uuid, boolean, timestamptz) to authenticated;
grant execute on function public.admin_get_active_user_stats() to authenticated;
grant execute on function public.admin_get_all_households() to authenticated;

-- Preserve the self-service reset contract with a pinned, empty search path.
alter function public.reset_user_account() set search_path = '';
revoke execute on function public.reset_user_account()
  from public, anon, service_role;
grant execute on function public.reset_user_account() to authenticated;

notify pgrst, 'reload schema';