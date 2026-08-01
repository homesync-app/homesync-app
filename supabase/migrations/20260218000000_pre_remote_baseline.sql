-- Reconstruct the schema that existed before the first tracked Supabase migration.
-- This historical baseline is for clean local replays. On an existing hosted
-- project it must be marked as applied, never executed over live tables.

create extension if not exists "uuid-ossp";

create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.household_members (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  role text not null default 'member',
  joined_at timestamptz not null default now(),
  unique (household_id, user_id)
);

create index idx_household_members_household
  on public.household_members (household_id);
create index idx_household_members_user
  on public.household_members (user_id);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  assigned_to uuid references public.users(id) on delete set null,
  created_by_id uuid not null references public.users(id),
  title text not null,
  description text,
  category text,
  type text default 'one_time',
  difficulty text default 'medium',
  xp_reward integer default 0,
  coin_reward integer default 0,
  priority text default 'medium',
  status text not null default 'active',
  due_at timestamptz,
  last_completed_at timestamptz,
  last_verified_by uuid references public.users(id),
  next_due_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_tasks_household on public.tasks (household_id);
create index idx_tasks_assigned_to on public.tasks (assigned_to);
create index idx_tasks_status on public.tasks (status);
create index idx_tasks_created_at on public.tasks (created_at desc);
create index idx_tasks_created_by on public.tasks (created_by_id);

create table public.ledger_entries (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references public.users(id),
  type text not null,
  amount integer not null,
  currency text not null,
  reference_id text,
  reference_type text,
  description text,
  created_at timestamptz not null default now(),
  created_by text,
  source text default 'api'
);

create unique index idx_ledger_entries_unique
  on public.ledger_entries (reference_id, type, user_id);
create index idx_ledger_entries_household
  on public.ledger_entries (household_id);
create index idx_ledger_entries_user
  on public.ledger_entries (user_id);
create index idx_ledger_entries_created_at
  on public.ledger_entries (created_at desc);

create table public.idempotency_keys (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  idempotency_key uuid not null unique,
  operation text not null,
  request_body jsonb,
  response_body jsonb,
  status_code integer,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '24 hours')
);
create unique index idx_idempotency_keys_user_key
  on public.idempotency_keys (user_id, idempotency_key);
create index idx_idempotency_keys_expires
  on public.idempotency_keys (expires_at);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  created_by_id uuid not null references public.users(id),
  title text not null,
  description text,
  category text,
  amount decimal not null,
  currency text default 'EUR',
  paid_by uuid not null references public.users(id),
  paid_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_expenses_household on public.expenses (household_id);
create index idx_expenses_paid_by on public.expenses (paid_by);
create index idx_expenses_created_at on public.expenses (created_at desc);

create table public.expense_splits (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid not null references public.expenses(id) on delete cascade,
  user_id uuid not null references public.users(id),
  amount decimal not null,
  created_at timestamptz not null default now()
);

create unique index idx_expense_splits_unique
  on public.expense_splits (expense_id, user_id);
create index idx_expense_splits_expense
  on public.expense_splits (expense_id);
create index idx_expense_splits_user
  on public.expense_splits (user_id);

create table public.weekly_winners (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references public.users(id),
  week_start date not null,
  week_end date not null,
  xp_earned integer not null default 0,
  coins_awarded integer not null default 0,
  created_at timestamptz not null default now(),
  unique (household_id, week_start)
);
create table public.system_events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  request_id text,
  user_id uuid,
  event_type text not null,
  entity_type text not null,
  entity_id uuid,
  household_id uuid,
  operation text,
  result text,
  duration_ms integer,
  metadata jsonb default '{}',
  ip_address inet,
  user_agent text,
  source text
);

create index idx_system_events_request_id on public.system_events (request_id);
create index idx_system_events_user_id on public.system_events (user_id);
create index idx_system_events_entity on public.system_events (entity_type, entity_id);
create index idx_system_events_household on public.system_events (household_id);
create index idx_system_events_created_at on public.system_events (created_at desc);
create index idx_system_events_event_type on public.system_events (event_type);
create index idx_system_events_result on public.system_events (result);
create index idx_system_events_metadata on public.system_events using gin (metadata);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  request_id text,
  user_id uuid not null,
  household_id uuid,
  action text not null,
  entity_type text not null,
  entity_id uuid not null,
  old_value jsonb,
  new_value jsonb,
  reason text,
  ip_address inet,
  user_agent text,
  source text
);

create index idx_audit_logs_user_id on public.audit_logs (user_id);
create index idx_audit_logs_household on public.audit_logs (household_id);
create index idx_audit_logs_entity on public.audit_logs (entity_type, entity_id);
create index idx_audit_logs_action on public.audit_logs (action);
create index idx_audit_logs_created_at on public.audit_logs (created_at desc);
create index idx_audit_logs_request_id on public.audit_logs (request_id);
create table public.integrity_checks (
  id uuid primary key default gen_random_uuid(),
  check_type text not null,
  check_date timestamptz not null default now(),
  severity text not null,
  entity_type text,
  entity_id uuid,
  household_id uuid,
  issue_description text,
  metadata jsonb default '{}',
  resolved boolean default false,
  resolved_at timestamptz,
  resolved_by text,
  resolution_notes text
);

create index idx_integrity_checks_type on public.integrity_checks (check_type);
create index idx_integrity_checks_severity on public.integrity_checks (severity);
create index idx_integrity_checks_resolved on public.integrity_checks (resolved);
create index idx_integrity_checks_date on public.integrity_checks (check_date desc);

create table public.alerts (
  id text primary key,
  type text not null,
  severity text not null,
  title text not null,
  message text not null,
  source text not null,
  metadata jsonb default '{}',
  job_id text,
  resolved boolean default false,
  resolved_at timestamptz,
  resolved_by text,
  resolution_notes text,
  created_at timestamptz not null default now()
);

create index idx_alerts_severity on public.alerts (severity);
create index idx_alerts_resolved on public.alerts (resolved);
create index idx_alerts_type on public.alerts (type);
create index idx_alerts_job_id on public.alerts (job_id);
create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
set search_path = ''
as $function$
begin
  new.updated_at = now();
  return new;
end;
$function$;

create trigger update_users_updated_at
  before update on public.users
  for each row execute function public.update_updated_at_column();
create trigger update_households_updated_at
  before update on public.households
  for each row execute function public.update_updated_at_column();
create trigger update_tasks_updated_at
  before update on public.tasks
  for each row execute function public.update_updated_at_column();
create trigger update_expenses_updated_at
  before update on public.expenses
  for each row execute function public.update_updated_at_column();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  insert into public.users (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$function$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();