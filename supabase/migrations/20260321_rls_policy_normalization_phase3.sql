-- Phase 3 RLS normalization: remove legacy permissive policy and deduplicate overlaps
BEGIN;

-- 1) Critical privacy hardening: remove legacy permissive SELECT policy that can leak private expenses.
DROP POLICY IF EXISTS "Household members can view shared expenses" ON public.expenses;

-- 2) mercadopago_connections: remove redundant SELECT policy (covered by manage-own policy).
DROP POLICY IF EXISTS "Users can view their own connections" ON public.mercadopago_connections;

-- 3) rewards: split owner ALL policy into explicit write policies to avoid SELECT overlap.
DROP POLICY IF EXISTS "Owners can manage rewards" ON public.rewards;

CREATE POLICY "Owners can insert rewards"
ON public.rewards
FOR INSERT
TO public
WITH CHECK (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = auth.uid()
      AND hm.role = 'owner'
  )
);

CREATE POLICY "Owners can update rewards"
ON public.rewards
FOR UPDATE
TO public
USING (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = auth.uid()
      AND hm.role = 'owner'
  )
)
WITH CHECK (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = auth.uid()
      AND hm.role = 'owner'
  )
);

CREATE POLICY "Owners can delete rewards"
ON public.rewards
FOR DELETE
TO public
USING (
  household_id IN (
    SELECT hm.household_id
    FROM public.household_members hm
    WHERE hm.user_id = auth.uid()
      AND hm.role = 'owner'
  )
);

-- 4) savings_goals: split member ALL policy into explicit write policies to avoid SELECT overlap.
DROP POLICY IF EXISTS "Owners/Members can manage household goals" ON public.savings_goals;

CREATE POLICY "Members can insert household goals"
ON public.savings_goals
FOR INSERT
TO public
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = savings_goals.household_id
      AND hm.user_id = auth.uid()
  )
);

CREATE POLICY "Members can update household goals"
ON public.savings_goals
FOR UPDATE
TO public
USING (
  EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = savings_goals.household_id
      AND hm.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = savings_goals.household_id
      AND hm.user_id = auth.uid()
  )
);

CREATE POLICY "Members can delete household goals"
ON public.savings_goals
FOR DELETE
TO public
USING (
  EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = savings_goals.household_id
      AND hm.user_id = auth.uid()
  )
);

-- 5) weekly_winners: remove overly broad authenticated ALL policy.
DROP POLICY IF EXISTS "System can manage winners" ON public.weekly_winners;

CREATE POLICY "service_role can manage winners"
ON public.weekly_winners
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

COMMIT;