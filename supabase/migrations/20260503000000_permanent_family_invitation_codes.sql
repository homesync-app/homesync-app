-- Family/friends invitation codes are permanent and multi-use.
-- Couple invitation codes remain single-use and time-limited.

alter table public.household_invitations
  alter column expires_at drop not null;

update public.household_invitations hi
set expires_at = null
from public.households h
where h.id = hi.household_id
  and h.household_type in ('family', 'friends')
  and hi.used_at is null;

create or replace function public.generate_household_invitation(p_household_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_is_owner boolean;
  v_household_type text;
  v_member_count int;
  v_uid uuid := public.current_app_user_id();
begin
  select exists(
    select 1 from household_members
    where household_id = p_household_id
      and user_id = v_uid
      and role = 'owner'
  ) into v_is_owner;

  if not v_is_owner then
    raise exception 'Only household owners can generate invitation codes';
  end if;

  select h.household_type into v_household_type
  from households h
  where h.id = p_household_id;

  if v_household_type = 'couple' then
    select count(*) into v_member_count
    from household_members
    where household_id = p_household_id;

    if v_member_count >= 2 then
      raise exception 'Couple households are limited to 2 members';
    end if;
  end if;

  select code into v_code
  from household_invitations
  where household_id = p_household_id
    and used_at is null
    and (
      v_household_type in ('family', 'friends')
      or expires_at > now()
    )
  order by created_at desc
  limit 1;

  if v_code is null then
    insert into household_invitations (household_id, created_by, expires_at)
    values (
      p_household_id,
      v_uid,
      case
        when v_household_type in ('family', 'friends') then null
        else now() + interval '7 days'
      end
    )
    returning code into v_code;
  end if;

  return v_code;
end;
$$;

create or replace function public.join_household_by_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invitation        household_invitations%ROWTYPE;
  v_old_household_id  uuid;
  v_member_count      int;
  v_household_type    text;
  v_uid               uuid := public.current_app_user_id();
begin
  select hi.*
    into v_invitation
  from household_invitations hi
  join households h on h.id = hi.household_id
  where upper(hi.code) = upper(p_code)
    and hi.used_at is null
    and (
      h.household_type in ('family', 'friends')
      or hi.expires_at > now()
    )
  limit 1;

  if v_invitation.id is null then
    return jsonb_build_object(
      'success', false,
      'error', 'invalid_code',
      'message', 'El código no es válido o ya fue utilizado'
    );
  end if;

  select h.household_type into v_household_type
  from households h
  where h.id = v_invitation.household_id;

  if v_invitation.household_id in (
    select household_id from household_members where user_id = v_uid
  ) then
    return jsonb_build_object(
      'success', false,
      'error', 'already_member',
      'message', 'Ya eres miembro de este hogar'
    );
  end if;

  if v_household_type = 'couple' then
    select count(*) into v_member_count
    from household_members
    where household_id = v_invitation.household_id;

    if v_member_count >= 2 then
      return jsonb_build_object(
        'success', false,
        'error', 'household_full',
        'message', 'Este hogar de pareja ya tiene los 2 miembros'
      );
    end if;
  end if;

  select household_id into v_old_household_id
  from household_members
  where user_id = v_uid
  limit 1;

  if v_old_household_id is not null
     and v_old_household_id != v_invitation.household_id then
    select count(*) into v_member_count
    from household_members
    where household_id = v_old_household_id;

    delete from household_members
    where household_id = v_old_household_id
      and user_id = v_uid;

    if v_member_count = 1 then
      begin
        delete from tasks where household_id = v_old_household_id;
        delete from expenses where household_id = v_old_household_id;
        delete from shopping_items where household_id = v_old_household_id;
        delete from household_activities where household_id = v_old_household_id;
        delete from households where id = v_old_household_id;
      exception when others then
      end;
    end if;
  end if;

  insert into household_members (household_id, user_id, role, onboarding_completed)
  values (v_invitation.household_id, v_uid, 'member', false);

  if v_household_type = 'couple' then
    update household_invitations
    set used_at = now(), used_by = v_uid
    where id = v_invitation.id;
  end if;

  return jsonb_build_object(
    'success', true,
    'household_id', v_invitation.household_id,
    'message', '¡Te uniste al hogar exitosamente!'
  );
end;
$$;
