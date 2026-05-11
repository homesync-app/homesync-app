create table if not exists public.error_issues (
  id uuid primary key default gen_random_uuid(),
  fingerprint text not null unique,
  title text not null,
  level text not null default 'error' check (level in ('critical', 'error', 'warning', 'info')),
  status text not null default 'open' check (status in ('open', 'investigating', 'fixed', 'ignored')),
  first_seen timestamptz not null,
  last_seen timestamptz not null,
  occurrences integer not null default 0,
  affected_users integer not null default 0,
  sample_log_id uuid,
  sample_message text,
  sample_stack_trace_head text,
  app_frame text,
  screens text[] not null default '{}',
  environments text[] not null default '{}',
  first_seen_build text,
  last_seen_build text,
  fixed_in_build text,
  fixed_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.error_issues enable row level security;

create index if not exists error_issues_status_last_seen_idx
  on public.error_issues (status, last_seen desc);

create index if not exists error_issues_level_occurrences_idx
  on public.error_issues (level, occurrences desc);

create or replace function public.touch_error_issue_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();

  if new.status = 'fixed' and old.status is distinct from 'fixed' then
    new.fixed_at = coalesce(new.fixed_at, now());
  elsif new.status is distinct from 'fixed' then
    new.fixed_at = null;
  end if;

  return new;
end;
$$;

drop trigger if exists touch_error_issues_updated_at on public.error_issues;
create trigger touch_error_issues_updated_at
before update on public.error_issues
for each row
execute function public.touch_error_issue_updated_at();

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
drop policy if exists "admins can read error issues" on public.error_issues;
create policy "admins can read error issues"
  on public.error_issues
  for select
  to authenticated
  using ((select public.is_error_issue_admin()));

drop policy if exists "authenticated users can upsert error issues" on public.error_issues;
drop policy if exists "admins can upsert error issues" on public.error_issues;
create policy "admins can upsert error issues"
  on public.error_issues
  for insert
  to authenticated
  with check ((select public.is_error_issue_admin()));

drop policy if exists "authenticated users can update error issues" on public.error_issues;
drop policy if exists "admins can update error issues" on public.error_issues;
create policy "admins can update error issues"
  on public.error_issues
  for update
  to authenticated
  using ((select public.is_error_issue_admin()))
  with check ((select public.is_error_issue_admin()));

grant select, insert, update on public.error_issues to authenticated;
grant execute on function public.is_error_issue_admin() to authenticated;
grant all on public.error_issues to service_role;
