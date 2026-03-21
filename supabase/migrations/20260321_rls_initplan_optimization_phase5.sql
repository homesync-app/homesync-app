-- Phase 5: RLS initplan optimization for Firebase+Supabase synced auth
BEGIN;

-- users
ALTER POLICY "Users can insert own profile"
ON public.users
WITH CHECK ((select auth.uid()) = id);

ALTER POLICY "Users can update own profile"
ON public.users
USING ((select auth.uid()) = id);

ALTER POLICY "Users can view household member profiles"
ON public.users
USING (
  ((select auth.uid()) = id)
  OR (
    id IN (
      SELECT hm2.user_id
      FROM public.household_members hm1
      JOIN public.household_members hm2
        ON hm1.household_id = hm2.household_id
      WHERE hm1.user_id = (select auth.uid())
    )
  )
);

-- households
ALTER POLICY "Users can create households"
ON public.households
WITH CHECK ((select auth.uid()) IS NOT NULL);

ALTER POLICY "Users can view their households"
ON public.households
USING (
  id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = (select auth.uid())
  )
);

ALTER POLICY "Owners can update households"
ON public.households
USING (
  id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = (select auth.uid())
      AND hm.role = 'owner'
  )
);

ALTER POLICY "Owners can delete households"
ON public.households
USING (
  id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = (select auth.uid())
      AND hm.role = 'owner'
  )
);

-- tasks
ALTER POLICY "Users can create tasks"
ON public.tasks
WITH CHECK (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = (select auth.uid())
  )
);

ALTER POLICY "Users can view household tasks"
ON public.tasks
USING (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = (select auth.uid())
  )
);

ALTER POLICY "Users can update tasks"
ON public.tasks
USING (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = (select auth.uid())
  )
);

ALTER POLICY "Owners can delete tasks"
ON public.tasks
USING (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = (select auth.uid())
      AND hm.role = 'owner'
  )
);

COMMIT;