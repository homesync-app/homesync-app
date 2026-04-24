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
  select id into v_user_id
  from public.users
  where firebase_uid = p_firebase_uid;

  if v_user_id is not null then
    update public.users set
      full_name = coalesce(full_name, p_full_name),
      avatar_url = coalesce(avatar_url, p_avatar_url),
      updated_at = now()
    where id = v_user_id;
    return v_user_id;
  end if;

  select id into v_user_id
  from public.users
  where email = p_email;

  if v_user_id is not null then
    update public.users set
      firebase_uid = p_firebase_uid,
      full_name = coalesce(full_name, p_full_name),
      avatar_url = coalesce(avatar_url, p_avatar_url),
      updated_at = now()
    where id = v_user_id;
    return v_user_id;
  end if;

  insert into public.users (id, email, full_name, avatar_url, firebase_uid)
  values (gen_random_uuid(), p_email, p_full_name, p_avatar_url, p_firebase_uid)
  returning id into v_user_id;

  return v_user_id;
end;
$$;

comment on function public.ensure_user_profile(text, text, text, text) is
  'Creates or links a Firebase profile without overwriting user-customized name or avatar on later syncs.';
