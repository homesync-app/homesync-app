alter table public.user_feedback
  add column if not exists device_model text,
  add column if not exists os_version text,
  add column if not exists locale text,
  add column if not exists screen_name text,
  add column if not exists breadcrumbs jsonb,
  add column if not exists wants_email_response boolean not null default true,
  add column if not exists resolved boolean not null default false,
  add column if not exists status text not null default 'open'
    check (status in ('open', 'replied', 'resolved', 'closed')),
  add column if not exists last_response_at timestamptz,
  add column if not exists responded_at timestamptz,
  add column if not exists ack_sent_at timestamptz,
  add column if not exists response_count integer not null default 0;

create index if not exists user_feedback_status_created_at_idx
  on public.user_feedback (status, created_at desc);

drop policy if exists "admins can read feedback" on public.user_feedback;
create policy "admins can read feedback"
on public.user_feedback
for select
to authenticated
using (
  exists (
    select 1
    from public.users u
    where u.email = (auth.jwt() ->> 'email')
      and coalesce(u.is_admin, false)
  )
);

drop policy if exists "admins can update feedback" on public.user_feedback;
create policy "admins can update feedback"
on public.user_feedback
for update
to authenticated
using (
  exists (
    select 1
    from public.users u
    where u.email = (auth.jwt() ->> 'email')
      and coalesce(u.is_admin, false)
  )
)
with check (
  exists (
    select 1
    from public.users u
    where u.email = (auth.jwt() ->> 'email')
      and coalesce(u.is_admin, false)
  )
);

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

create policy "admins can read feedback responses"
on public.user_feedback_responses
for select
to authenticated
using (
  exists (
    select 1
    from public.users u
    where u.email = (auth.jwt() ->> 'email')
      and coalesce(u.is_admin, false)
  )
);

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

grant select on table public.user_feedback_responses to authenticated;
grant all on table public.user_feedback_responses to service_role;
