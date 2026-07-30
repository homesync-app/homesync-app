-- Compatibility window for the next imported migration only. The previous
-- object_task signature has a default that its CREATE OR REPLACE removes,
-- which PostgreSQL rejects unless the old function is dropped first.
-- The UUID column shape matches what that legacy function expects.

drop function public.object_task(uuid, uuid, text);

alter table public.ledger_entries
  alter column reference_id type uuid
  using nullif(reference_id, '')::uuid;
