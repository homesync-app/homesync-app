create or replace function public.qa_admin_delete_dummy_member(
  p_household_id uuid,
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_actor_id uuid;
  v_email text;
  v_is_admin boolean;
  v_memberships integer;
begin
  v_actor_id := public.qa_admin_require_access();

  select email, coalesce(is_admin, false)
    into v_email, v_is_admin
  from public.users
  where id = p_user_id;

  if v_email is null then
    raise exception 'El miembro QA no existe';
  end if;

  if v_is_admin then
    raise exception 'No se puede eliminar un usuario admin QA';
  end if;

  if v_email not like 'qa.%@homesync.local' then
    raise exception 'Solo se pueden eliminar miembros dummy QA';
  end if;

  delete from public.household_members
  where household_id = p_household_id
    and user_id = p_user_id;

  select count(*)
    into v_memberships
  from public.household_members
  where user_id = p_user_id;

  if v_memberships = 0 then
    delete from public.user_fcm_tokens where user_id = p_user_id;
    delete from public.mercadopago_connections where user_id = p_user_id;
    delete from public.application_logs where user_id = p_user_id;
    delete from public.users where id = p_user_id;
    delete from auth.users where id = p_user_id;
  end if;

  insert into public.system_events (
    user_id,
    event_type,
    entity_type,
    entity_id,
    household_id,
    operation,
    result,
    source,
    metadata
  )
  values (
    v_actor_id,
    'qa_dummy_member_deleted',
    'user',
    p_user_id,
    p_household_id,
    'delete',
    'success',
    'qa_admin',
    jsonb_build_object(
      'email', v_email,
      'deleted_fully', v_memberships = 0
    )
  );

  return jsonb_build_object(
    'success', true,
    'user_id', p_user_id,
    'household_id', p_household_id,
    'email', v_email,
    'deleted_fully', v_memberships = 0
  );
end;
$$;

grant execute on function public.qa_admin_delete_dummy_member(uuid, uuid) to authenticated;
