-- Security hardening from the September 2026 review.
--
-- 1. application_logs: any signed-in user could read every row (messages,
--    stack traces, context and device info from every household). Reads are
--    now admin-only. Inserts and deleting your own rows stay as they were; the
--    admin workspace is the only reader in the app.
-- 2. get_system_diagnostics: SECURITY DEFINER with no guard, executable by any
--    signed-in user, and it returned the latest application_logs rows with a
--    caller-chosen limit (a way to dump the whole table). It is now admin-only
--    and the limit is clamped.
-- 3. Couple shared fund: the 1.5.0 client no longer shows the fund, so the
--    accrual trigger stops. The fund and challenge RPCs stay for older app
--    versions until 1.5.0 is adopted; a follow-up migration drops them.

-- 1. application_logs ------------------------------------------------------

drop policy if exists "Allow authenticated users to view logs"
  on public.application_logs;
drop policy if exists "Admins can view logs"
  on public.application_logs;

create policy "Admins can view logs"
  on public.application_logs
  for select
  to authenticated
  using ((select public.is_current_app_admin()));

-- 2. get_system_diagnostics ------------------------------------------------

create or replace function public.get_system_diagnostics(p_limit integer default 10)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_limit integer := least(greatest(coalesce(p_limit, 10), 1), 100);
  v_error_count integer;
  v_recent_errors jsonb;
  v_integrity_issues jsonb;
begin
  if not coalesce(public.is_current_app_admin(), false) then
    raise exception 'Admin access required' using errcode = '42501';
  end if;

  -- Recent failures in system_events.
  select count(*) into v_error_count
  from public.system_events
  where result = 'failure' and created_at > now() - interval '24 hours';

  -- Latest application logs.
  select jsonb_agg(t) into v_recent_errors from (
    select level, message, created_at
    from public.application_logs
    order by created_at desc
    limit v_limit
  ) t;

  -- Unresolved integrity issues.
  select jsonb_agg(t) into v_integrity_issues from (
    select check_type, severity, issue_description
    from public.integrity_checks
    where resolved = false
    limit v_limit
  ) t;

  return jsonb_build_object(
    'status', case when v_error_count > 5 then 'unstable' else 'healthy' end,
    'recent_system_failures_24h', v_error_count,
    'recent_app_logs', coalesce(v_recent_errors, '[]'::jsonb),
    'integrity_issues', coalesce(v_integrity_issues, '[]'::jsonb)
  );
end;
$function$;

revoke execute on function public.get_system_diagnostics(integer) from public, anon;
grant execute on function public.get_system_diagnostics(integer) to authenticated;

-- 3. Couple shared fund ----------------------------------------------------

drop trigger if exists accrue_couple_fund_on_activity_trigger
  on public.household_activities;
