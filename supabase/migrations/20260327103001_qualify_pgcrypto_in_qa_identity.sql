-- Keep the QA identity helper valid without exposing pgcrypto wrappers in the
-- public schema.

create or replace function public.qa_admin_ensure_identity(
  p_user_id uuid,
  p_email text,
  p_full_name text,
  p_avatar_url text default null,
  p_is_admin boolean default false,
  p_password text default 'qapass123'
) returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_now timestamptz := timezone('utc', now());
  v_password_hash text := extensions.crypt(
    coalesce(nullif(p_password, ''), 'qapass123'),
    extensions.gen_salt('bf')
  );
begin
  insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    is_sso_user,
    is_anonymous
  ) values (
    null,
    p_user_id,
    'authenticated',
    'authenticated',
    lower(p_email),
    v_password_hash,
    v_now,
    jsonb_build_object(
      'provider', 'email',
      'providers', jsonb_build_array('email')
    ),
    jsonb_build_object('qa', true, 'full_name', p_full_name),
    v_now,
    v_now,
    false,
    false
  )
  on conflict (id) do update
    set email = excluded.email,
        encrypted_password = excluded.encrypted_password,
        email_confirmed_at = coalesce(auth.users.email_confirmed_at, v_now),
        updated_at = v_now,
        raw_user_meta_data = coalesce(
          auth.users.raw_user_meta_data,
          '{}'::jsonb
        ) || jsonb_build_object(
          'qa', true,
          'full_name', p_full_name
        );

  insert into public.users (
    id,
    email,
    full_name,
    avatar_url,
    is_admin,
    updated_at
  ) values (
    p_user_id,
    lower(p_email),
    p_full_name,
    p_avatar_url,
    p_is_admin,
    v_now
  )
  on conflict (id) do update
    set email = excluded.email,
        full_name = excluded.full_name,
        avatar_url = excluded.avatar_url,
        is_admin = excluded.is_admin,
        updated_at = v_now;
end;
$function$;

drop function public.crypt(text, text);
drop function public.gen_salt(text);
