-- ─────────────────────────────────────────────────────────────────────────────
-- Admin panel power tools: premium toggle, user search and active-user stats.
--
-- All three RPCs are SECURITY DEFINER + pinned search_path and gated by
-- public.is_current_app_admin() (already used by feedback/error-issue/user
-- visibility policies). They do NOT change any RLS policy. Premium writes work
-- because SECURITY DEFINER runs as the function owner (postgres), which the
-- existing reject_user_sensitive_updates / validate_household_update triggers
-- explicitly allow (current_user in postgres/service_role/supabase_admin).
--
-- "Active user" definition (household_activities is the real-usage signal:
-- task completed, expense added, reward redeemed, member joined):
--   active_Nd      = distinct users with >=1 activity in the last N days
--   recurrent_7d   = users active on >=3 DISTINCT days within the last 7 days
--                    (filters out the one-and-done visitor; signals a habit)
--   stickiness     = active_1d / active_30d (DAU/MAU, the retention thermometer)
--
-- APPLIED: 2026-05-30 to project tfavamqszdkoeabpyxms via the Supabase
-- Management API query endpoint (run as postgres), then registered in
-- supabase_migrations.schema_migrations. `supabase db push` could not be used
-- because of pre-existing migration-history drift (legacy date-only files such
-- as 20260321_*.sql duplicate already-applied 20260321xxxxxx_*.sql versions);
-- that drift is unrelated to this change and was left untouched.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Premium toggle for an arbitrary household (admin only) ────────────────
create or replace function public.admin_set_household_premium(
  p_household_id uuid,
  p_is_premium boolean,
  p_premium_until timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_household public.households%rowtype;
  v_until timestamptz;
  v_tier text;
begin
  if not public.is_current_app_admin() then
    raise exception 'Admin privileges required' using errcode = '42501';
  end if;

  select * into v_household
  from public.households
  where id = p_household_id;

  if not found then
    return jsonb_build_object('success', false, 'message', 'Hogar no encontrado');
  end if;

  v_until := case when p_is_premium then p_premium_until else null end;
  v_tier := case
    when not p_is_premium then 'free'
    when v_household.household_type = 'couple' then 'couple_premium'
    else 'group_premium'
  end;

  update public.households h
  set
    plan_tier = v_tier,
    premium_until = v_until,
    subscription_owner_user_id = case
      when p_is_premium then coalesce(h.subscription_owner_user_id, public.current_app_user_id())
      else null
    end
  where h.id = p_household_id;

  -- Keep the legacy per-user mirror in sync so older clients reading
  -- users.is_premium still behave correctly for every member of the household.
  update public.users u
  set
    is_premium = p_is_premium,
    premium_until = v_until
  where u.id in (
    select hm.user_id
    from public.household_members hm
    where hm.household_id = p_household_id
  );

  return jsonb_build_object(
    'success', true,
    'household_id', p_household_id,
    'is_premium', p_is_premium,
    'plan_tier', v_tier,
    'premium_until', v_until
  );
end;
$$;

comment on function public.admin_set_household_premium(uuid, boolean, timestamptz) is
  'Admin-only: sets a household plan_tier/premium_until and mirrors users.is_premium for all members. SECURITY DEFINER; gated by is_current_app_admin().';

revoke execute on function public.admin_set_household_premium(uuid, boolean, timestamptz) from public, anon;
grant execute on function public.admin_set_household_premium(uuid, boolean, timestamptz) to authenticated, service_role;

-- ── 2. Search users by email/name with their household + premium state ───────
create or replace function public.admin_search_users(
  p_query text,
  p_limit integer default 25
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_query text;
  v_limit integer;
  v_rows jsonb;
begin
  if not public.is_current_app_admin() then
    raise exception 'Admin privileges required' using errcode = '42501';
  end if;

  v_query := '%' || lower(trim(coalesce(p_query, ''))) || '%';
  v_limit := least(greatest(coalesce(p_limit, 25), 1), 100);

  select coalesce(jsonb_agg(row_to_json(t)::jsonb order by t.full_name nulls last), '[]'::jsonb)
  into v_rows
  from (
    select
      u.id            as user_id,
      u.email,
      u.full_name,
      u.avatar_url,
      coalesce(u.is_admin, false) as is_admin,
      (u.deleted_at is not null)  as is_deleted,
      hm.household_id,
      h.name          as household_name,
      h.household_type,
      h.plan_tier,
      h.premium_until,
      (h.plan_tier is not null and h.plan_tier <> 'free'
        and (h.premium_until is null or h.premium_until > now())) as household_is_premium,
      hm.role         as household_role
    from public.users u
    left join public.household_members hm on hm.user_id = u.id
    left join public.households h on h.id = hm.household_id
    where u.deleted_at is null
      and (
        lower(coalesce(u.email, '')) like v_query
        or lower(coalesce(u.full_name, '')) like v_query
      )
    order by u.full_name nulls last
    limit v_limit
  ) t;

  return v_rows;
end;
$$;

comment on function public.admin_search_users(text, integer) is
  'Admin-only: searches users by email/name and returns their household + premium state. SECURITY DEFINER; gated by is_current_app_admin().';

revoke execute on function public.admin_search_users(text, integer) from public, anon;
grant execute on function public.admin_search_users(text, integer) to authenticated, service_role;

-- ── 3. Active-user statistics ────────────────────────────────────────────────
create or replace function public.admin_get_active_user_stats()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total_users integer;
  v_active_1d integer;
  v_active_7d integer;
  v_active_30d integer;
  v_recurrent_7d integer;
  v_stickiness numeric;
  v_daily jsonb;
begin
  if not public.is_current_app_admin() then
    raise exception 'Admin privileges required' using errcode = '42501';
  end if;

  select count(*) into v_total_users
  from public.users
  where deleted_at is null;

  select count(distinct user_id) into v_active_1d
  from public.household_activities
  where user_id is not null and created_at >= now() - interval '1 day';

  select count(distinct user_id) into v_active_7d
  from public.household_activities
  where user_id is not null and created_at >= now() - interval '7 days';

  select count(distinct user_id) into v_active_30d
  from public.household_activities
  where user_id is not null and created_at >= now() - interval '30 days';

  -- Recurrent = activity on >= 3 distinct days within the last 7 days.
  select count(*) into v_recurrent_7d
  from (
    select user_id
    from public.household_activities
    where user_id is not null and created_at >= now() - interval '7 days'
    group by user_id
    having count(distinct date_trunc('day', created_at)) >= 3
  ) recurrent;

  v_stickiness := case
    when coalesce(v_active_30d, 0) = 0 then 0
    else round((v_active_1d::numeric / v_active_30d::numeric) * 100, 1)
  end;

  -- Last 14 days daily active users (for a sparkline).
  select coalesce(jsonb_agg(jsonb_build_object('day', d.day, 'active_users', coalesce(a.cnt, 0)) order by d.day), '[]'::jsonb)
  into v_daily
  from generate_series(
    (date_trunc('day', now()) - interval '13 days')::date,
    date_trunc('day', now())::date,
    interval '1 day'
  ) as d(day)
  left join (
    select date_trunc('day', created_at)::date as day, count(distinct user_id) as cnt
    from public.household_activities
    where user_id is not null and created_at >= now() - interval '14 days'
    group by 1
  ) a on a.day = d.day;

  return jsonb_build_object(
    'total_users', coalesce(v_total_users, 0),
    'active_1d', coalesce(v_active_1d, 0),
    'active_7d', coalesce(v_active_7d, 0),
    'active_30d', coalesce(v_active_30d, 0),
    'recurrent_7d', coalesce(v_recurrent_7d, 0),
    'stickiness_pct', v_stickiness,
    'daily', v_daily,
    'generated_at', now()
  );
end;
$$;

comment on function public.admin_get_active_user_stats() is
  'Admin-only: active-user metrics from household_activities (active 1/7/30d, recurrent >=3 days in 7d, DAU/MAU stickiness, 14d sparkline). SECURITY DEFINER; gated by is_current_app_admin().';

revoke execute on function public.admin_get_active_user_stats() from public, anon;
grant execute on function public.admin_get_active_user_stats() to authenticated, service_role;

notify pgrst, 'reload schema';
