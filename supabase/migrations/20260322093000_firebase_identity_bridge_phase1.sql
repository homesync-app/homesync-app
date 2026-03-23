alter table public.users
  add column if not exists firebase_uid text;

comment on column public.users.firebase_uid is
  'Firebase Authentication UID mapped to the internal app user UUID.';

create unique index if not exists users_firebase_uid_unique_idx
  on public.users (firebase_uid)
  where firebase_uid is not null;

create or replace function public.current_auth_subject()
returns text
language sql
stable
set search_path = public
as $$
  select coalesce(
    nullif(auth.jwt() ->> 'sub', ''),
    auth.uid()::text
  );
$$;

comment on function public.current_auth_subject() is
  'Returns the current authentication subject, supporting both Supabase Auth and Firebase JWTs.';

create or replace function public.current_app_user_id()
returns uuid
language plpgsql
stable
set search_path = public
as $$
declare
  claim_app_user_id text;
  claim_subject text;
  resolved_user_id uuid;
begin
  claim_app_user_id := nullif(auth.jwt() ->> 'app_user_id', '');

  if claim_app_user_id is not null
     and claim_app_user_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    return claim_app_user_id::uuid;
  end if;

  if auth.uid() is not null then
    return auth.uid();
  end if;

  claim_subject := public.current_auth_subject();
  if claim_subject is null then
    return null;
  end if;

  select u.id
    into resolved_user_id
  from public.users u
  where u.firebase_uid = claim_subject
  limit 1;

  return resolved_user_id;
end;
$$;

comment on function public.current_app_user_id() is
  'Resolves the internal app user UUID from auth claims. Prefers app_user_id, falls back to auth.uid() and finally firebase_uid mapping.';

create or replace function public.is_current_app_user(user_id uuid)
returns boolean
language sql
stable
set search_path = public
as $$
  select public.current_app_user_id() = user_id;
$$;

comment on function public.is_current_app_user(uuid) is
  'Checks whether the provided internal app user UUID matches the current authenticated subject.';
