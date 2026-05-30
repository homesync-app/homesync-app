-- Reconstructed from remote migration history (version 20260219203932).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.household_members DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view household members" ON public.household_members;
DROP POLICY IF EXISTS "Users can join household" ON public.household_members;
DROP POLICY IF EXISTS "Users can update membership" ON public.household_members;
DROP POLICY IF EXISTS "Owners can add members" ON public.household_members;
DROP POLICY IF EXISTS "Owners can delete members" ON public.household_members;
DROP POLICY IF EXISTS "Users can delete own membership" ON public.household_members;

ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own membership"
ON public.household_members FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Users can insert own membership"
ON public.household_members FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own membership"
ON public.household_members FOR UPDATE
USING (user_id = auth.uid());

CREATE POLICY "Users can delete own membership"
ON public.household_members FOR DELETE
USING (user_id = auth.uid());
