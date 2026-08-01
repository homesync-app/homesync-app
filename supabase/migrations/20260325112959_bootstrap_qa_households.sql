-- The imported QA migration resets four fixed households that previously
-- existed only as remote data. Bootstrap their parent rows for clean replays;
-- the following migration remains responsible for identities and members.

insert into public.households (
  id,
  name,
  household_type,
  display_name
) values
  (
    '11111111-1111-1111-1111-111111111111',
    'Testing: Solo',
    'solo',
    'Modo Solo QA'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Testing: Pareja',
    'couple',
    'Modo Pareja QA'
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Testing: Amigos',
    'friends',
    'Modo Amigos QA'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'Testing: Familia',
    'family',
    'Modo Familia QA'
  )
on conflict (id) do nothing;
