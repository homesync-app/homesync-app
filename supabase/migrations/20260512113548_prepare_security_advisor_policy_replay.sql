-- The following reconstructed security-advisor migration recreates these
-- policies without dropping the equivalent copies applied earlier.

drop policy if exists "authenticated can view catalog requests"
  on public.shopping_catalog_requests;
drop policy if exists "authenticated users can insert own feedback"
  on public.user_feedback;
