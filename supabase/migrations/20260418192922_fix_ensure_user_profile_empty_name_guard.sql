-- Reconstructed from remote migration history (version 20260418192922).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Fix ensure_user_profile to treat empty strings as NULL for full_name and avatar_url
-- Previously, passing full_name='' from Firebase displayName would overwrite a valid name
create or replace function public.ensure_user_profile(
  p_firebase_uid text,
  p_email text,
  p_full_name text default null,
  p_avatar_url text default null
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_user_id uuid;
  v_clean_name text := nullif(trim(coalesce(p_full_name, '')), '');
  v_clean_avatar text := nullif(trim(coalesce(p_avatar_url, '')), '');
begin
  select id into v_user_id
  from public.users
  where firebase_uid = p_firebase_uid;

  if v_user_id is not null then
    if v_clean_name is not null or v_clean_avatar is not null then
      update public.users set
        full_name = coalesce(v_clean_name, nullif(trim(full_name), '')),
        avatar_url = coalesce(v_clean_avatar, nullif(trim(avatar_url), '')),
        updated_at = now()
      where id = v_user_id;
    end if;
    return v_user_id;
  end if;

  select id into v_user_id
  from public.users
  where email = p_email;

  if v_user_id is not null then
    update public.users set
      firebase_uid = p_firebase_uid,
      full_name = coalesce(v_clean_name, nullif(trim(full_name), '')),
      avatar_url = coalesce(v_clean_avatar, nullif(trim(avatar_url), '')),
      updated_at = now()
    where id = v_user_id;
    return v_user_id;
  end if;

  insert into public.users (id, email, full_name, avatar_url, firebase_uid)
  values (gen_random_uuid(), p_email, v_clean_name, v_clean_avatar, p_firebase_uid)
  returning id into v_user_id;

  return v_user_id;
end;
$$;
;