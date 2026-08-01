-- INSERT ... RETURNING (used by the Flutter feedback form) also requires the
-- inserted row to be visible through a SELECT policy. Keep visibility scoped
-- to the authenticated app user while preserving the separate admin policy.

drop policy if exists "users can read own feedback"
  on public.user_feedback;

create policy "users can read own feedback"
on public.user_feedback
for select
to authenticated
using (
  (select public.is_supabase_or_firebase_project_jwt()) is true
  and user_id = public.current_app_user_id()::text
);
