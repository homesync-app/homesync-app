-- RevenueCat premium sync.
--
-- RevenueCat webhooks are processed by the `revenuecat-webhook` Edge Function
-- with the service role. These tables are intentionally not exposed to client
-- roles; they provide idempotency and a compact per-customer entitlement state.

create table if not exists public.revenuecat_webhook_events (
  event_id text primary key,
  event_type text not null,
  app_user_id text,
  product_id text,
  event_timestamp_ms bigint,
  payload jsonb not null,
  processed_at timestamptz not null default now()
);

alter table public.revenuecat_webhook_events enable row level security;

revoke all on table public.revenuecat_webhook_events from anon, authenticated;
grant all on table public.revenuecat_webhook_events to service_role;

create index if not exists idx_revenuecat_webhook_events_app_user_id
  on public.revenuecat_webhook_events(app_user_id);

create table if not exists public.revenuecat_customer_state (
  app_user_id uuid primary key references public.users(id) on delete cascade,
  is_premium boolean not null default false,
  product_id text,
  entitlement_ids text[] not null default '{}'::text[],
  expiration_at timestamptz,
  latest_event_type text,
  latest_event_id text,
  latest_event_timestamp_ms bigint not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.revenuecat_customer_state enable row level security;

revoke all on table public.revenuecat_customer_state from anon, authenticated;
grant all on table public.revenuecat_customer_state to service_role;

create index if not exists idx_revenuecat_customer_state_active
  on public.revenuecat_customer_state(is_premium, expiration_at)
  where is_premium = true;

comment on table public.revenuecat_webhook_events is
  'Idempotency/audit log for RevenueCat webhook events processed by the Edge Function.';

comment on table public.revenuecat_customer_state is
  'Latest RevenueCat premium state per app_user_id (HomeSync users.id). Used to recompute household premium.';
