create or replace function public.is_error_issue_admin()
returns boolean
language sql
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.users u
    where u.id = public.current_app_user_id()
      and coalesce(u.is_admin, false) = true
  );
$$;

drop policy if exists "authenticated users can read error issues" on public.error_issues;
drop policy if exists "authenticated users can upsert error issues" on public.error_issues;
drop policy if exists "authenticated users can update error issues" on public.error_issues;

drop policy if exists "admins can read error issues" on public.error_issues;
create policy "admins can read error issues"
  on public.error_issues
  for select
  to authenticated
  using ((select public.is_error_issue_admin()));

drop policy if exists "admins can upsert error issues" on public.error_issues;
create policy "admins can upsert error issues"
  on public.error_issues
  for insert
  to authenticated
  with check ((select public.is_error_issue_admin()));

drop policy if exists "admins can update error issues" on public.error_issues;
create policy "admins can update error issues"
  on public.error_issues
  for update
  to authenticated
  using ((select public.is_error_issue_admin()))
  with check ((select public.is_error_issue_admin()));

grant execute on function public.is_error_issue_admin() to authenticated;
