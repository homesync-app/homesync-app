-- The following imported migration recreates the same catalog policy.
-- Drop the first copy so replay preserves one equivalent final policy.

drop policy if exists "authenticated can upsert catalog requests"
  on public.shopping_catalog_requests;
