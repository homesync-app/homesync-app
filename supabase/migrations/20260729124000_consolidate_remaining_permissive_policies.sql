-- Consolidate equivalent permissive RLS policies without changing access.
-- PostgreSQL ORs permissive policies for the same role/action; expressing each
-- OR explicitly avoids duplicate policy evaluation and advisor warnings.

drop policy if exists "Adult admins can update household member roles"
  on public.household_members;
drop policy if exists "Users can update own membership"
  on public.household_members;

create policy "household_members_authenticated_update"
on public.household_members
for update
to authenticated
using (
  user_id = public.current_app_user_id()
  or private.is_adult_household_admin(household_id, user_id)
)
with check (
  user_id = public.current_app_user_id()
  or private.is_adult_household_admin(household_id, user_id)
);

drop policy if exists "admins can read feedback"
  on public.user_feedback;
drop policy if exists "users can read own feedback"
  on public.user_feedback;

create policy "user_feedback_authenticated_select"
on public.user_feedback
for select
to authenticated
using (
  public.is_current_app_admin()
  or (
    (select public.is_supabase_or_firebase_project_jwt()) is true
    and user_id = public.current_app_user_id()::text
  )
);