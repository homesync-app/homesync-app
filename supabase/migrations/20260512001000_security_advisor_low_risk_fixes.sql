-- Address low-risk Supabase security advisor findings without changing the
-- authenticated app RPC surface.

-- Diagnostic views should execute with the caller privileges so RLS on the
-- underlying tables remains effective.
alter view if exists public.v_manual_items_no_icon
  set (security_invoker = true);
alter view if exists public.v_ocr_unmatched_items
  set (security_invoker = true);
alter view if exists public.v_ocr_dropped_items
  set (security_invoker = true);
alter view if exists public.v_ocr_daily_stats
  set (security_invoker = true);

-- Pin search_path on functions flagged by the advisor.
alter function public.upsert_catalog_request(text, text)
  set search_path = public;
alter function public.qa_admin_household_defaults(uuid)
  set search_path = public;
alter function public.create_task(
  uuid, text, text, uuid, text, text, integer, integer, text,
  timestamptz, text, integer, timestamptz, integer[], integer[]
)
  set search_path = public;
alter function public.reset_user_account()
  set search_path = public;

-- The app writes catalog requests through the upsert_catalog_request RPC.
-- Direct table access only needs read access for the admin workspace.
revoke all on table public.shopping_catalog_requests from anon;
drop policy if exists "authenticated can upsert catalog requests"
  on public.shopping_catalog_requests;

create policy "authenticated can view catalog requests"
on public.shopping_catalog_requests
for select
to authenticated
using ((select public.is_supabase_or_firebase_project_jwt()) is true);

grant select on table public.shopping_catalog_requests to authenticated;
grant execute on function public.upsert_catalog_request(text, text)
  to authenticated;
revoke execute on function public.upsert_catalog_request(text, text)
  from anon;

-- Feedback is submitted by signed-in users. Keep admin read/update policies,
-- but make inserts prove the row belongs to the current app user.
revoke all on table public.user_feedback from anon;
drop policy if exists "authenticated users can insert feedback"
  on public.user_feedback;

create policy "authenticated users can insert own feedback"
on public.user_feedback
for insert
to authenticated
with check (
  (select public.is_supabase_or_firebase_project_jwt()) is true
  and user_id = (public.current_app_user_id())::text
);

grant insert, select, update on table public.user_feedback to authenticated;
