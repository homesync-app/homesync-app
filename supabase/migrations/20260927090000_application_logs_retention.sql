-- application_logs: per-user insert limit, daily rollups and retention.
--
-- The table reached 212 MB of a 239 MB database. On the Free plan, going over
-- 500 MB puts the database in read-only mode. In March 2026, 6 test accounts
-- wrote 94,603 rows in one month through a logging loop, and nothing capped
-- or cleaned them.
--
-- 1. Per-user limit (BEFORE INSERT trigger): up to 30 rows every 10 minutes
--    and 300 per 24 hours. Rows over the limit are dropped without an error,
--    so a client loop can no longer fill the database. It also trims very long
--    messages, stack traces and diagnostic context.
-- 2. application_log_daily_rollups: event counts per UTC day, level, message
--    signature, first app stack frame and app version. It keeps the history
--    without keeping every row.
-- 3. prune_application_logs(p_keep_days): rolls up the rows that expire and
--    deletes them in the same transaction. It aborts if the rollup did not
--    cover exactly the deleted rows. A daily cron keeps 30 days of detail.

-- 1. Per-user insert limit ------------------------------------------------

-- The limit counts a user's recent rows on every insert.
create index if not exists idx_app_logs_user_time
  on public.application_logs (user_id, created_at desc);

-- SECURITY DEFINER: only admins can SELECT application_logs, so the count
-- has to run with the owner's rights to see the caller's own recent rows.
create or replace function public.application_logs_guard_insert()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_last_10_min integer;
  v_last_day integer;
begin
  new.message := left(new.message, 2000);
  if new.stack_trace is not null then
    new.stack_trace := left(new.stack_trace, 16000);
  end if;
  if new.context is not null and pg_column_size(new.context) > 16384 then
    new.context := (new.context - 'full_diagnostics' - 'stack_frames_head')
      || jsonb_build_object('context_trimmed', true);
  end if;

  if new.user_id is null then
    return new;
  end if;

  select
    count(*) filter (where created_at > now() - interval '10 minutes'),
    count(*)
  into v_last_10_min, v_last_day
  from public.application_logs
  where user_id = new.user_id
    and created_at > now() - interval '24 hours';

  if v_last_10_min >= 30 or v_last_day >= 300 then
    -- Over the limit: skip the row. The client insert still succeeds.
    return null;
  end if;

  return new;
end;
$function$;

revoke all on function public.application_logs_guard_insert()
  from public, anon, authenticated;

drop trigger if exists application_logs_guard_insert on public.application_logs;
create trigger application_logs_guard_insert
  before insert on public.application_logs
  for each row execute function public.application_logs_guard_insert();

-- 2. Daily rollups --------------------------------------------------------

create table if not exists public.application_log_daily_rollups (
  day date not null,
  level text not null,
  signature text not null,
  first_app_frame text not null default '',
  app_version text not null default '',
  events integer not null,
  users integer not null,
  first_seen_at timestamptz not null,
  last_seen_at timestamptz not null,
  primary key (day, level, signature, first_app_frame, app_version)
);

comment on table public.application_log_daily_rollups is
  'Daily summary of application_logs rows removed by prune_application_logs(). One row per UTC day, level, message signature, first app stack frame and app version.';

alter table public.application_log_daily_rollups enable row level security;

revoke all on table public.application_log_daily_rollups from anon, authenticated;
grant select on table public.application_log_daily_rollups to authenticated;

drop policy if exists "Admins can view log rollups"
  on public.application_log_daily_rollups;

create policy "Admins can view log rollups"
  on public.application_log_daily_rollups
  for select
  to authenticated
  using ((select public.is_current_app_admin()));

-- 3. Retention ------------------------------------------------------------

-- Rolls up every row older than p_keep_days full UTC days, then deletes them.
-- The cutoff is aligned to a day boundary so each day is rolled up in one run.
create or replace function public.prune_application_logs(p_keep_days integer default 30)
returns table (rolled_up_rows bigint, deleted_rows bigint, rollup_groups bigint)
language plpgsql
set search_path to 'public'
as $function$
declare
  v_keep_days integer := greatest(coalesce(p_keep_days, 30), 7);
  v_cutoff timestamptz :=
    date_trunc('day', now() at time zone 'UTC') at time zone 'UTC'
    - make_interval(days => v_keep_days);
  v_rows bigint;
  v_groups bigint;
  v_deleted bigint;
begin
  select count(*) into v_rows
  from public.application_logs
  where created_at < v_cutoff;

  if v_rows = 0 then
    return query select 0::bigint, 0::bigint, 0::bigint;
    return;
  end if;

  with expiring as (
    select
      (created_at at time zone 'UTC')::date as day,
      level,
      left(
        regexp_replace(
          regexp_replace(
            regexp_replace(
              regexp_replace(
                split_part(message, E'\n', 1),
                '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
                '<uuid>',
                'g'
              ),
              '#[0-9a-f]{5}\M',
              '#<id>',
              'g'
            ),
            '[0-9]+',
            '<n>',
            'g'
          ),
          '\s+',
          ' ',
          'g'
        ),
        200
      ) as signature,
      coalesce(
        (regexp_match(stack_trace, 'package:homesync_client/[^ )]+'))[1],
        ''
      ) as first_app_frame,
      coalesce(context->>'app_version', device_info->>'app_version', '') as app_version,
      user_id,
      created_at
    from public.application_logs
    where created_at < v_cutoff
  )
  insert into public.application_log_daily_rollups (
    day,
    level,
    signature,
    first_app_frame,
    app_version,
    events,
    users,
    first_seen_at,
    last_seen_at
  )
  select
    day,
    level,
    signature,
    first_app_frame,
    app_version,
    count(*)::integer,
    count(distinct user_id)::integer,
    min(created_at),
    max(created_at)
  from expiring
  group by day, level, signature, first_app_frame, app_version
  on conflict (day, level, signature, first_app_frame, app_version) do update
    set events = public.application_log_daily_rollups.events + excluded.events,
        users = greatest(public.application_log_daily_rollups.users, excluded.users),
        first_seen_at = least(public.application_log_daily_rollups.first_seen_at, excluded.first_seen_at),
        last_seen_at = greatest(public.application_log_daily_rollups.last_seen_at, excluded.last_seen_at);

  get diagnostics v_groups = row_count;

  delete from public.application_logs
  where created_at < v_cutoff;

  get diagnostics v_deleted = row_count;

  if v_deleted <> v_rows then
    raise exception
      'prune_application_logs: rolled up % rows but deleted %; rolling back',
      v_rows, v_deleted;
  end if;

  return query select v_rows, v_deleted, v_groups;
end;
$function$;

revoke all on function public.prune_application_logs(integer)
  from public, anon, authenticated;
grant execute on function public.prune_application_logs(integer) to service_role;

-- Daily at 06:40 UTC, off-peak for Argentina. A named job is an upsert, so
-- re-running this migration only reschedules it.
select cron.schedule(
  'prune-application-logs-daily',
  '40 6 * * *',
  $cron$select public.prune_application_logs(30);$cron$
);
