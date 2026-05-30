-- Reconstructed from remote migration history (version 20260323173458).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Create or replace function to provision the mapping between Firebase UID and internal App User ID
-- This solves the "weak sync contract" by explicit first-registration sync.
create or replace function public.provision_firebase_user()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  jwt_subject text;
  jwt_email text;
  resolved_id uuid;
begin
  -- 1. Extract claims from the current auth token (assumed to be a Firebase JWT)
  jwt_subject := coalesce(
    nullif(auth.jwt() ->> 'sub', ''),
    auth.uid()::text
  );
  jwt_email := nullif(auth.jwt() ->> 'email', '');

  if jwt_subject is null then
    raise exception 'No authentication subject found in audit headers.';
  end if;

  -- 2. Check if we already have this mapping
  select id into resolved_id from public.users where firebase_uid = jwt_subject limit 1;
  if resolved_id is not null then
    return resolved_id;
  end if;

  -- 3. If not, find by email to merge accounts (common scenario)
  if jwt_email is not null then
    update public.users
    set firebase_uid = jwt_subject
    where email = jwt_email
      and firebase_uid is null
    returning id into resolved_id;
  end if;

  -- 4. If still not found, create a new user profile
  -- (This user won't belong to any household yet, but we'll have the identity)
  if resolved_id is null then
    insert into public.users (email, firebase_uid)
    values (jwt_email, jwt_subject)
    returning id into resolved_id;
  end if;

  return resolved_id;
end;
$$;

comment on function public.provision_firebase_user() is
  'Explicitly maps a Firebase Identity (from JWT subject) to an internal app user ID by email matching or creation. Use this during the first login of a Firebase-authenticated user.';
;