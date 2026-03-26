-- Create Testing Households
-- Use fixed UUIDs for consistent testing

DO $$ 
DECLARE
    v_solo_id uuid := '00000000-0000-0000-0000-000000000001';
    v_pareja_id uuid := '00000000-0000-0000-0000-000000000002';
    v_amigos_id uuid := '00000000-0000-0000-0000-000000000003';
    v_familia_id uuid := '00000000-0000-0000-0000-000000000004';
    
    v_user_admin_id uuid := '00000000-0000-0000-0000-ffffffffffff';
BEGIN
    -- 1. Ensure Households exist
    INSERT INTO public.households (id, name, household_type)
    VALUES 
        (v_solo_id, 'Hogar: Solo (Testing)', 'solo'),
        (v_pareja_id, 'Hogar: Pareja (Testing)', 'couple'),
        (v_amigos_id, 'Hogar: Amigos (Testing)', 'friends'),
        (v_familia_id, 'Hogar: Familia (Testing)', 'family')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, household_type = EXCLUDED.household_type;

    -- 2. Ensure Admin User exists in public.users
    INSERT INTO public.users (id, email, full_name, is_admin)
    VALUES (v_user_admin_id, 'admin@homesync.test', 'Admin Testing', true)
    ON CONFLICT (id) DO UPDATE SET is_admin = true;

    -- 3. Create Mock Users and Memberships
    
    -- --- SOLO ---
    INSERT INTO public.users (id, email, full_name) VALUES ('s001-0001', 'solo@test.com', 'Usuario Solo') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_solo_id, 's001-0001', 'admin') ON CONFLICT DO NOTHING;

    -- --- PAREJA ---
    INSERT INTO public.users (id, email, full_name) VALUES ('p001-0001', 'pareja1@test.com', 'Pareja: User 1') ON CONFLICT DO NOTHING;
    INSERT INTO public.users (id, email, full_name) VALUES ('p001-0002', 'pareja2@test.com', 'Pareja: User 2') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_pareja_id, 'p001-0001', 'admin') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_pareja_id, 'p001-0002', 'member') ON CONFLICT DO NOTHING;

    -- --- AMIGOS ---
    INSERT INTO public.users (id, email, full_name) VALUES ('a001-0001', 'amigo1@test.com', 'Amigo 1') ON CONFLICT DO NOTHING;
    INSERT INTO public.users (id, email, full_name) VALUES ('a001-0002', 'amigo2@test.com', 'Amigo 2') ON CONFLICT DO NOTHING;
    INSERT INTO public.users (id, email, full_name) VALUES ('a001-0003', 'amigo3@test.com', 'Amigo 3') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_amigos_id, 'a001-0001', 'admin') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_amigos_id, 'a001-0002', 'member') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_amigos_id, 'a001-0003', 'member') ON CONFLICT DO NOTHING;

    -- --- FAMILIA ---
    INSERT INTO public.users (id, email, full_name) VALUES ('f001-0001', 'padre@test.com', 'Papá') ON CONFLICT DO NOTHING;
    INSERT INTO public.users (id, email, full_name) VALUES ('f001-0002', 'madre@test.com', 'Mamá') ON CONFLICT DO NOTHING;
    INSERT INTO public.users (id, email, full_name) VALUES ('f001-0003', 'hijo1@test.com', 'Hijo 1') ON CONFLICT DO NOTHING;
    INSERT INTO public.users (id, email, full_name) VALUES ('f001-0004', 'hijo2@test.com', 'Hijo 2') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_familia_id, 'f001-0001', 'admin') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_familia_id, 'f001-0002', 'admin') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_familia_id, 'f001-0003', 'member') ON CONFLICT DO NOTHING;
    INSERT INTO public.household_members (household_id, user_id, role) VALUES (v_familia_id, 'f001-0004', 'member') ON CONFLICT DO NOTHING;

END $$;
