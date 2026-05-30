-- Reconstructed from remote migration history (version 20260519162911).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Align production feedback schema with the app/admin contract and let
-- authenticated admin users inspect app activity from the web panel.

alter table public.user_feedback
  add column if not exists device_model text,
  add column if not exists os_version text,
  add column if not exists locale text,
  add column if not exists screen_name text,
  add column if not exists breadcrumbs jsonb default '[]'::jsonb,
  add column if not exists wants_email_response boolean not null default true,
  add column if not exists resolved boolean not null default false,
  add column if not exists status text not null default 'open',
  add column if not exists last_response_at timestamptz,
  add column if not exists responded_at timestamptz,
  add column if not exists ack_sent_at timestamptz,
  add column if not exists response_count integer not null default 0;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'user_feedback_status_check'
      and conrelid = 'public.user_feedback'::regclass
  ) then
    alter table public.user_feedback
      add constraint user_feedback_status_check
      check (status in ('open', 'replied', 'resolved', 'closed'));
  end if;
end $$;

update public.user_feedback
set status = case
  when resolved then 'resolved'
  else coalesce(nullif(status, ''), 'open')
end;

create index if not exists user_feedback_status_created_at_idx
  on public.user_feedback (status, created_at desc);

create or replace function public.is_current_app_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.users u
    where coalesce(u.is_admin, false)
      and (
        u.id = public.current_app_user_id()
        or lower(u.email) = lower(auth.jwt() ->> 'email')
      )
  );
$$;

revoke execute on function public.is_current_app_admin() from public, anon;
grant execute on function public.is_current_app_admin() to authenticated, service_role;

drop policy if exists "admin can read all feedback" on public.user_feedback;
drop policy if exists "admin can update feedback" on public.user_feedback;
drop policy if exists "admins can read feedback" on public.user_feedback;
drop policy if exists "admins can update feedback" on public.user_feedback;

create policy "admins can read feedback"
on public.user_feedback
for select
to authenticated
using (public.is_current_app_admin());

create policy "admins can update feedback"
on public.user_feedback
for update
to authenticated
using (public.is_current_app_admin())
with check (public.is_current_app_admin());

drop policy if exists "admins can read users" on public.users;
create policy "admins can read users"
on public.users
for select
to authenticated
using (public.is_current_app_admin());

drop policy if exists "admins can read household members" on public.household_members;
create policy "admins can read household members"
on public.household_members
for select
to authenticated
using (public.is_current_app_admin());

drop policy if exists "admins can read households" on public.households;
create policy "admins can read households"
on public.households
for select
to authenticated
using (public.is_current_app_admin());

create table if not exists public.user_feedback_responses (
  id uuid primary key default gen_random_uuid(),
  feedback_id uuid not null references public.user_feedback(id) on delete cascade,
  responder_user_id uuid references public.users(id) on delete set null,
  responder_email text,
  recipient_email text not null,
  subject text not null,
  body text not null,
  provider text not null default 'resend',
  provider_message_id text,
  sent_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.user_feedback_responses enable row level security;

create index if not exists user_feedback_responses_feedback_id_idx
  on public.user_feedback_responses (feedback_id, created_at desc);

drop policy if exists "admins can read feedback responses" on public.user_feedback_responses;
create policy "admins can read feedback responses"
on public.user_feedback_responses
for select
to authenticated
using (public.is_current_app_admin());

drop policy if exists "users can read own feedback responses" on public.user_feedback_responses;
create policy "users can read own feedback responses"
on public.user_feedback_responses
for select
to authenticated
using (
  exists (
    select 1
    from public.user_feedback f
    where f.id = user_feedback_responses.feedback_id
      and f.user_id = (public.current_app_user_id())::text
  )
);

grant insert, select, update on table public.user_feedback to authenticated;
grant select on table public.user_feedback_responses to authenticated;
grant all on table public.user_feedback to service_role;
grant all on table public.user_feedback_responses to service_role;

notify pgrst, 'reload schema';
