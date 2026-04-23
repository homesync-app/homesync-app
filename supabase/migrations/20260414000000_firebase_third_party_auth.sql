-- Firebase Third-Party Auth: fix remaining auth.uid() gaps,
-- add security helper, restrictive policies, and ensure_user_profile RPC.

begin;

-- ── 1. Security helper: validate JWT comes from our Supabase or Firebase project ──

create or replace function public.is_supabase_or_firebase_project_jwt()
returns bool
language sql
stable
set search_path = public
as $$
  select (
    auth.jwt()->>'iss' = 'https://tfavamqszdkoeabpyxms.supabase.co/auth/v1'
    or (
      auth.jwt()->>'iss' = 'https://securetoken.google.com/homesync-prod-r7-123'
      and auth.jwt()->>'aud' = 'homesync-prod-r7-123'
    )
  );
$$;

comment on function public.is_supabase_or_firebase_project_jwt() is
  'Returns true if the current JWT was issued by our Supabase project or our Firebase project.';

-- ── 2. Fix save_expense_v4: auth.uid() → current_app_user_id() ──

create or replace function public.save_expense_v4(
  p_household_id uuid,
  p_title text,
  p_amount numeric,
  p_category text,
  p_paid_by uuid,
  p_type text default 'expense',
  p_description text default null,
  p_split_type text default 'equal',
  p_splits jsonb default '[]',
  p_paid_at timestamptz default now(),
  p_id uuid default null,
  p_receipt_path text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_expense_id uuid;
  v_uid uuid;
begin
  v_uid := public.current_app_user_id();
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  v_expense_id := coalesce(p_id, gen_random_uuid());

  insert into public.expenses (
    id, household_id, title, amount, category, paid_by,
    type, description, split_type, paid_at, receipt_path
  ) values (
    v_expense_id, p_household_id, p_title, p_amount, p_category, p_paid_by,
    p_type, p_description, p_split_type, p_paid_at, p_receipt_path
  )
  on conflict (id) do update set
    title = excluded.title,
    amount = excluded.amount,
    category = excluded.category,
    description = excluded.description,
    split_type = excluded.split_type,
    paid_at = excluded.paid_at,
    receipt_path = excluded.receipt_path;

  if p_splits is not null and jsonb_array_length(p_splits) > 0 then
    delete from public.expense_splits where expense_id = v_expense_id;

    insert into public.expense_splits (expense_id, user_id, share_amount, share_percentage)
    select
      v_expense_id,
      (s->>'user_id')::uuid,
      (s->>'share_amount')::numeric,
      (s->>'share_percentage')::numeric
    from jsonb_array_elements(p_splits) s;
  end if;

  return v_expense_id;
end;
$$;

-- ── 3. Fix admin_get_all_households: auth.uid() → current_app_user_id() ──

create or replace function public.admin_get_all_households()
returns table (
  id uuid,
  name text,
  household_type text,
  owner_email text,
  member_count bigint,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
begin
  v_uid := public.current_app_user_id();
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  if not exists (select 1 from public.users where id = v_uid and is_admin = true) then
    raise exception 'Admin access required';
  end if;

  return query
  select
    h.id,
    h.name,
    h.household_type,
    u.email as owner_email,
    (select count(*) from public.household_members hm where hm.household_id = h.id) as member_count,
    h.created_at
  from public.households h
  join public.household_members hm on hm.household_id = h.id and hm.role = 'owner'
  join public.users u on u.id = hm.user_id
  order by h.created_at desc;
end;
$$;

-- ── 4. Fix storage policies for receipts bucket ──

drop policy if exists "Users can view receipts for their household" on storage.objects;
drop policy if exists "Users can upload receipts for their household" on storage.objects;
drop policy if exists "Users can delete receipts for their household" on storage.objects;

create policy "Users can view receipts for their household"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'receipts'
  and (select public.is_supabase_or_firebase_project_jwt()) is true
  and exists (
    select 1 from public.household_members hm
    where hm.household_id = split_part(name, '/', 1)::uuid
    and hm.user_id = public.current_app_user_id()
  )
);

create policy "Users can upload receipts for their household"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'receipts'
  and (select public.is_supabase_or_firebase_project_jwt()) is true
  and exists (
    select 1 from public.household_members hm
    where hm.household_id = split_part(name, '/', 1)::uuid
    and hm.user_id = public.current_app_user_id()
  )
);

create policy "Users can delete receipts for their household"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'receipts'
  and (select public.is_supabase_or_firebase_project_jwt()) is true
  and exists (
    select 1 from public.household_members hm
    where hm.household_id = split_part(name, '/', 1)::uuid
    and hm.user_id = public.current_app_user_id()
  )
);

-- ── 5. ensure_user_profile RPC ──
-- Creates or links a user profile from a Firebase UID to the internal app UUID.
-- Called by the Flutter client after every successful Firebase sign-in.

create or replace function public.ensure_user_profile(
  p_firebase_uid text,
  p_email text,
  p_full_name text default null,
  p_avatar_url text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
begin
  -- Try to find existing user by firebase_uid
  select id into v_user_id
  from public.users
  where firebase_uid = p_firebase_uid;

  if v_user_id is not null then
    -- Update stale fields if provided
    if p_full_name is not null or p_avatar_url is not null then
      update public.users set
        full_name = coalesce(p_full_name, full_name),
        avatar_url = coalesce(p_avatar_url, avatar_url),
        updated_at = now()
      where id = v_user_id;
    end if;
    return v_user_id;
  end if;

  -- Try to find existing user by email (Supabase native user migrating)
  select id into v_user_id
  from public.users
  where email = p_email;

  if v_user_id is not null then
    -- Link: set firebase_uid on existing record
    update public.users set
      firebase_uid = p_firebase_uid,
      full_name = coalesce(p_full_name, full_name),
      avatar_url = coalesce(p_avatar_url, avatar_url),
      updated_at = now()
    where id = v_user_id;
    return v_user_id;
  end if;

  -- New user: create profile with generated UUID
  insert into public.users (id, email, full_name, avatar_url, firebase_uid)
  values (gen_random_uuid(), p_email, p_full_name, p_avatar_url, p_firebase_uid)
  returning id into v_user_id;

  return v_user_id;
end;
$$;

comment on function public.ensure_user_profile(text, text, text, text) is
  'Creates or links a user profile from a Firebase UID. Called after Firebase sign-in.';

-- ── 6. Restrictive security policies on all public tables ──
-- These ensure only JWTs from our Supabase or Firebase project can access data.

do $$
declare
  tbl record;
  policy_name text;
begin
  for tbl in
    select table_schema, table_name
    from information_schema.tables
    where table_schema = 'public'
      and table_type = 'BASE TABLE'
      and table_name in (
        'users', 'households', 'household_members', 'tasks', 'expenses',
        'expense_splits', 'notifications', 'shopping_items', 'ledger_entries',
        'household_activities', 'planned_expenses', 'expense_templates',
        'expense_template_history', 'reward_redemptions', 'rewards',
        'application_logs', 'audit_logs', 'household_invitations',
        'idempotency_keys', 'mercadopago_connections', 'savings_contributions',
        'savings_goals', 'system_events', 'weekly_duel_history', 'weekly_winners',
        'user_fcm_tokens', 'love_notes', 'push_tokens', 'shopping_catalog_requests'
      )
  loop
    policy_name := 'restrict_to_valid_jwt_' || tbl.table_name;

    execute format(
      'drop policy if exists %I on %I.%I',
      policy_name, tbl.table_schema, tbl.table_name
    );

    execute format(
      'create policy %I on %I.%I as restrictive to authenticated using ((select public.is_supabase_or_firebase_project_jwt()) is true)',
      policy_name, tbl.table_schema, tbl.table_name
    );
  end loop;
end;
$$;

commit;
