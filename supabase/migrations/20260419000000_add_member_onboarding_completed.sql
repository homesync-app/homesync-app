-- Add onboarding_completed flag to household_members.
-- Existing members keep true (they already went through setup).
-- New members default to false and must complete MemberOnboardingScreen.

alter table public.household_members
  add column if not exists onboarding_completed boolean not null default true;

alter table public.household_members
  alter column onboarding_completed set default false;

-- ── Update join_household_by_code: new joiners need onboarding ──
create or replace function public.join_household_by_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
DECLARE
  v_invitation        household_invitations%ROWTYPE;
  v_old_household_id  uuid;
  v_member_count      int;
  v_uid               uuid := public.current_app_user_id();
BEGIN
  SELECT * INTO v_invitation
  FROM household_invitations
  WHERE upper(code) = upper(p_code)
    AND used_at IS NULL
    AND expires_at > now()
  LIMIT 1;

  IF v_invitation.id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_code',
      'message', 'El código no es válido o ya fue utilizado');
  END IF;

  IF v_invitation.household_id IN (
    SELECT household_id FROM household_members WHERE user_id = v_uid
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_member',
      'message', 'Ya eres miembro de este hogar');
  END IF;

  SELECT household_id INTO v_old_household_id
  FROM household_members
  WHERE user_id = v_uid
  LIMIT 1;

  IF v_old_household_id IS NOT NULL AND v_old_household_id != v_invitation.household_id THEN
    SELECT COUNT(*) INTO v_member_count
    FROM household_members
    WHERE household_id = v_old_household_id;

    DELETE FROM household_members WHERE household_id = v_old_household_id AND user_id = v_uid;

    IF v_member_count = 1 THEN
      BEGIN
        DELETE FROM tasks WHERE household_id = v_old_household_id;
        DELETE FROM expenses WHERE household_id = v_old_household_id;
        DELETE FROM shopping_items WHERE household_id = v_old_household_id;
        DELETE FROM household_activities WHERE household_id = v_old_household_id;
        DELETE FROM households WHERE id = v_old_household_id;
      EXCEPTION WHEN OTHERS THEN
      END;
    END IF;
  END IF;

  INSERT INTO household_members (household_id, user_id, role, onboarding_completed)
  VALUES (v_invitation.household_id, v_uid, 'member', false);

  UPDATE household_invitations
  SET used_at = now(), used_by = v_uid
  WHERE id = v_invitation.id;

  RETURN jsonb_build_object(
    'success', true,
    'household_id', v_invitation.household_id,
    'message', '¡Te uniste al hogar exitosamente!'
  );
END;
$$;

-- ── Recreate ensure_household_for_user: creator needs onboarding ──
DROP FUNCTION IF EXISTS public.ensure_household_for_user(text);

create or replace function public.ensure_household_for_user(p_household_type text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_household_id uuid;
begin
  v_user_id := public.current_app_user_id();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select household_id into v_household_id
  from public.household_members
  where user_id = v_user_id
  limit 1;

  if v_household_id is not null then
    update public.households
    set household_type = p_household_type
    where id = v_household_id and household_type != p_household_type;
    return v_household_id;
  end if;

  insert into public.households (name, household_type)
  values ('Mi Hogar', p_household_type)
  returning id into v_household_id;

  insert into public.household_members (household_id, user_id, role, onboarding_completed)
  values (v_household_id, v_user_id, 'owner', false);

  return v_household_id;
end;
$$;

-- ── New RPC: complete_member_onboarding ──
create or replace function public.complete_member_onboarding(
  p_member_type text default 'adult',
  p_display_role text default null
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

  update public.household_members
  set
    onboarding_completed = true,
    member_type = p_member_type,
    display_role = coalesce(p_display_role,
      case p_member_type
        when 'child' then 'Hijo/a'
        else 'Adulto'
      end)
  where user_id = v_uid
    and onboarding_completed = false;

  return found;
end;
$$;

comment on function public.complete_member_onboarding(text, text) is
  'Marks the current user onboarding as completed. Called after the member selects their role.';
