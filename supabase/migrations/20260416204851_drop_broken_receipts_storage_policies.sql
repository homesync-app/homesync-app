-- Reconstructed from remote migration history (version 20260416204851).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

DROP POLICY IF EXISTS "receipts_select_by_household_member" ON storage.objects;
DROP POLICY IF EXISTS "receipts_insert_by_household_member" ON storage.objects;
DROP POLICY IF EXISTS "receipts_delete_by_household_member" ON storage.objects;
