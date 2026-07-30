-- Reconstructed from remote migration history (version 20260401123307).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

create or replace function public.qa_admin_seed_scenario_members(
  p_household_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_household_id = '11111111-1111-1111-1111-111111111111'::uuid then
    perform public.qa_admin_ensure_identity(
      '11110000-0000-0000-0000-000000000001'::uuid,
      'qa.solo.luna@homesync.local',
      'Luna',
      'Â­Æ’ÂºÃ¿'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values (p_household_id, '11110000-0000-0000-0000-000000000001'::uuid, 'owner', 'Usuario Solo')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;

  elsif p_household_id = '22222222-2222-2222-2222-222222222222'::uuid then
    perform public.qa_admin_ensure_identity(
      '22220000-0000-0000-0000-000000000001'::uuid,
      'qa.couple.alex@homesync.local',
      'Alex',
      'Â­Æ’ÂªÃ¨'
    );
    perform public.qa_admin_ensure_identity(
      '22220000-0000-0000-0000-000000000002'::uuid,
      'qa.couple.mora@homesync.local',
      'Mora',
      'Â­Æ’Ã‰â–‘'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values
      (p_household_id, '22220000-0000-0000-0000-000000000001'::uuid, 'owner', 'Pareja A'),
      (p_household_id, '22220000-0000-0000-0000-000000000002'::uuid, 'member', 'Pareja B')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;

  elsif p_household_id = '33333333-3333-3333-3333-333333333333'::uuid then
    perform public.qa_admin_ensure_identity(
      '33330000-0000-0000-0000-000000000001'::uuid,
      'qa.friends.nico@homesync.local',
      'Nico',
      'Â­Æ’Ã¿Ã„'
    );
    perform public.qa_admin_ensure_identity(
      '33330000-0000-0000-0000-000000000002'::uuid,
      'qa.friends.cami@homesync.local',
      'Cami',
      'Â­Æ’Ã®â•—'
    );
    perform public.qa_admin_ensure_identity(
      '33330000-0000-0000-0000-000000000003'::uuid,
      'qa.friends.juli@homesync.local',
      'Juli',
      'Â­Æ’Ã„Âº'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values
      (p_household_id, '33330000-0000-0000-0000-000000000001'::uuid, 'owner', 'Amigo 1'),
      (p_household_id, '33330000-0000-0000-0000-000000000002'::uuid, 'member', 'Amigo 2'),
      (p_household_id, '33330000-0000-0000-0000-000000000003'::uuid, 'member', 'Amigo 3')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;

  elsif p_household_id = '44444444-4444-4444-4444-444444444444'::uuid then
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000001'::uuid,
      'qa.family.blas@homesync.local',
      'Blas',
      'Â­Æ’ÂºÃ¶'
    );
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000002'::uuid,
      'qa.family.ana@homesync.local',
      'Ana',
      'Â­Æ’Ã¦Â®'
    );
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000003'::uuid,
      'qa.family.tomi@homesync.local',
      'Tomi',
      'Â­Æ’ÂºÃ†'
    );
    perform public.qa_admin_ensure_identity(
      '44440000-0000-0000-0000-000000000004'::uuid,
      'qa.family.mili@homesync.local',
      'Mili',
      'Â­Æ’Ã¦Âº'
    );

    insert into public.household_members (household_id, user_id, role, display_role)
    values
      (p_household_id, '44440000-0000-0000-0000-000000000001'::uuid, 'owner', 'Papâ”œÃ­'),
      (p_household_id, '44440000-0000-0000-0000-000000000002'::uuid, 'member', 'Mamâ”œÃ­'),
      (p_household_id, '44440000-0000-0000-0000-000000000003'::uuid, 'member', 'Hijo 1'),
      (p_household_id, '44440000-0000-0000-0000-000000000004'::uuid, 'member', 'Hija 1')
    on conflict (household_id, user_id) do update
      set role = excluded.role,
          display_role = excluded.display_role;
  else
    raise exception 'El hogar % no es un escenario QA conocido', p_household_id;
  end if;
end;
$$;

select public.qa_admin_seed_scenario_members('44444444-4444-4444-4444-444444444444'::uuid);
