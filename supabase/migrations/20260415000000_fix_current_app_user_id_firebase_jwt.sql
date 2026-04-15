-- Fix current_app_user_id() for Firebase Third-Party Auth JWTs.
--
-- Problem: with accessToken mode, Supabase sends Firebase JWTs to PostgreSQL.
-- auth.uid() internally casts the JWT `sub` claim to UUID. Firebase UIDs are
-- 28-char alphanumeric strings (not UUIDs), so the cast throws:
--   "invalid input syntax for type uuid: 'yTNKo5xTfHfoAFp89BTaW4VjNX52'"
--
-- The fix wraps the auth.uid() call in an exception handler so that when the
-- sub claim is not a UUID (Firebase mode), we fall through to the firebase_uid
-- lookup against the users table (which is done inside SECURITY DEFINER context
-- via ensure_user_profile, so no RLS recursion).

create or replace function public.current_app_user_id()
returns uuid
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  claim_app_user_id text;
  v_auth_uid        uuid;
  claim_subject     text;
  resolved_user_id  uuid;
begin
  -- 1. Prefer explicit app_user_id JWT claim (UUID format check)
  claim_app_user_id := nullif(auth.jwt() ->> 'app_user_id', '');
  if claim_app_user_id is not null
     and claim_app_user_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  then
    return claim_app_user_id::uuid;
  end if;

  -- 2. Try auth.uid() — works for Supabase native JWTs where sub is a UUID.
  --    Firebase JWTs have a non-UUID sub, so the internal cast throws; catch it.
  begin
    v_auth_uid := auth.uid();
  exception when invalid_text_representation or others then
    v_auth_uid := null;
  end;

  if v_auth_uid is not null then
    return v_auth_uid;
  end if;

  -- 3. Firebase JWT fallback: look up Supabase UUID via firebase_uid mapping.
  --    SECURITY DEFINER means this inner SELECT bypasses RLS, avoiding
  --    the circular dependency where users-table RLS calls this function.
  claim_subject := nullif(auth.jwt() ->> 'sub', '');
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
  'Resolves the internal app UUID from auth claims. Handles Supabase native JWTs '
  '(auth.uid() is a UUID) and Firebase Third-Party Auth JWTs (sub is a Firebase UID, '
  'looked up via firebase_uid column). SECURITY DEFINER avoids RLS recursion.';
