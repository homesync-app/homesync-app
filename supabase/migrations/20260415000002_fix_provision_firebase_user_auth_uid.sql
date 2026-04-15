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
  v_auth_uid_text text;
begin
  jwt_subject := nullif(auth.jwt() ->> 'sub', '');

  if jwt_subject is null then
    begin
      v_auth_uid_text := auth.uid()::text;
    exception when invalid_text_representation or others then
      v_auth_uid_text := null;
    end;
    jwt_subject := v_auth_uid_text;
  end if;

  jwt_email := nullif(auth.jwt() ->> 'email', '');

  if jwt_subject is null then
    raise exception 'No authentication subject found in auth headers.';
  end if;

  select id into resolved_id from public.users where firebase_uid = jwt_subject limit 1;
  if resolved_id is not null then
    return resolved_id;
  end if;

  if jwt_email is not null then
    update public.users
    set firebase_uid = jwt_subject
    where email = jwt_email
      and firebase_uid is null
    returning id into resolved_id;
  end if;

  if resolved_id is null then
    insert into public.users (email, firebase_uid)
    values (jwt_email, jwt_subject)
    returning id into resolved_id;
  end if;

  return resolved_id;
end;
$$;
