-- QA identities no longer reset to a public password.
--
-- qa_admin_ensure_identity used to fall back to a hardcoded default password
-- and, on conflict, overwrite the stored hash with it. Resetting a QA scenario
-- therefore put every QA account (including the admin QA base session) back
-- on a password that is published in the repo.
--
-- Now:
--   * without p_password, an existing account keeps its current hash;
--   * a brand-new account without p_password gets a random, unknown password
--     (set a real one explicitly when that account needs to sign in);
--   * the function stays unreachable from the API (only other SECURITY
--     DEFINER QA helpers call it).

create or replace function public.qa_admin_ensure_identity(
  p_user_id uuid,
  p_email text,
  p_full_name text,
  p_avatar_url text default null,
  p_is_admin boolean default false,
  p_password text default null
)
returns void
language plpgsql
security definer
set search_path to 'public', 'auth', 'extensions'
as $function$
declare
  v_now timestamptz := timezone('utc', now());
  v_explicit_password text := nullif(p_password, '');
  v_password_hash text := extensions.crypt(
    coalesce(
      v_explicit_password,
      encode(extensions.gen_random_bytes(24), 'base64')
    ),
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
  )
  values (
    null,
    p_user_id,
    'authenticated',
    'authenticated',
    lower(p_email),
    v_password_hash,
    v_now,
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    jsonb_build_object('qa', true, 'full_name', p_full_name),
    v_now,
    v_now,
    false,
    false
  )
  on conflict (id) do update
    set email = excluded.email,
        encrypted_password = case
          when v_explicit_password is null then auth.users.encrypted_password
          else excluded.encrypted_password
        end,
        email_confirmed_at = coalesce(auth.users.email_confirmed_at, v_now),
        updated_at = v_now,
        raw_user_meta_data = coalesce(auth.users.raw_user_meta_data, '{}'::jsonb)
          || jsonb_build_object('qa', true, 'full_name', p_full_name);

  insert into public.users (
    id,
    email,
    full_name,
    avatar_url,
    is_admin,
    updated_at
  )
  values (
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

revoke execute on function public.qa_admin_ensure_identity(uuid, text, text, text, boolean, text)
  from public, anon, authenticated;
