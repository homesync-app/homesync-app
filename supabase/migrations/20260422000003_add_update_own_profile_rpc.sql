create or replace function public.update_own_profile(
  p_full_name text default null,
  p_avatar_url text default null
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := public.current_app_user_id();
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  if p_full_name is null and p_avatar_url is null then
    return false;
  end if;

  update public.users set
    full_name = coalesce(p_full_name, full_name),
    avatar_url = coalesce(p_avatar_url, avatar_url),
    updated_at = now()
  where id = v_uid;

  return found;
end;
$$;

comment on function public.update_own_profile(text, text) is
  'Updates the current user profile (name, avatar). Security-definer to avoid RLS issues with Firebase JWTs.';
