-- Reconstructed from remote migration history (version 20260415122045).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

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
  claim_app_user_id := nullif(auth.jwt() ->> 'app_user_id', '');
  if claim_app_user_id is not null
     and claim_app_user_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  then
    return claim_app_user_id::uuid;
  end if;

  begin
    v_auth_uid := auth.uid();
  exception when invalid_text_representation or others then
    v_auth_uid := null;
  end;

  if v_auth_uid is not null then
    return v_auth_uid;
  end if;

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
