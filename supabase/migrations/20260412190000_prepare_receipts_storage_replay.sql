-- Two imported receipts migrations create the same policies. Remove the first
-- set so the later historical copy can replay without changing the final ACL.

drop policy if exists "receipts_select_by_household_member"
  on storage.objects;
drop policy if exists "receipts_insert_by_household_member"
  on storage.objects;
drop policy if exists "receipts_delete_by_household_member"
  on storage.objects;
