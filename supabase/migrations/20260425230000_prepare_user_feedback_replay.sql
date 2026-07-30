-- The following reconstructed migration recreates the same feedback policies
-- and index. Drop the first copies so clean replay preserves one equivalent set.

drop policy if exists "authenticated users can insert feedback"
  on public.user_feedback;
drop policy if exists "service role can read all feedback"
  on public.user_feedback;
drop index if exists public.user_feedback_created_at_idx;
