-- Reconstructed from remote migration history (version 20260304111410).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

ALTER TABLE public.household_activities ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_view_household_activities
ON public.household_activities
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.household_members
    WHERE public.household_members.household_id = public.household_activities.household_id
    AND public.household_members.user_id = auth.uid()
  )
);
;