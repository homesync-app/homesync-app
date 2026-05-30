-- Reconstructed from remote migration history (version 20260219203646).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view household members" ON public.household_members;
DROP POLICY IF EXISTS "Users can join household" ON public.household_members;
DROP POLICY IF EXISTS "Users can update membership" ON public.household_members;
DROP POLICY IF EXISTS "Owners can add members" ON public.household_members;
DROP POLICY IF EXISTS "Owners can remove members" ON public.household_members;

CREATE POLICY "Users can view household members"
ON public.household_members FOR SELECT
USING (
  household_id IN (
    SELECT hm.household_id 
    FROM household_members hm 
    WHERE hm.user_id = auth.uid()
  )
);

CREATE POLICY "Users can join household"
ON public.household_members FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update membership"
ON public.household_members FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own membership"
ON public.household_members FOR DELETE
USING (user_id = auth.uid());

CREATE POLICY "Owners can add members"
ON public.household_members FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM household_members hm
    WHERE hm.household_id = household_members.household_id
    AND hm.user_id = auth.uid()
    AND hm.role = 'owner'
  )
);

CREATE POLICY "Owners can delete members"
ON public.household_members FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM household_members hm
    WHERE hm.household_id = household_members.household_id
    AND hm.user_id = auth.uid()
    AND hm.role = 'owner'
  )
);
