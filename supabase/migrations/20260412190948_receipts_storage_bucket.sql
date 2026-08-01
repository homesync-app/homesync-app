-- Reconstructed from remote migration history (version 20260412190948).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'receipts',
  'receipts',
  false,
  5242880,
  ARRAY['image/webp', 'image/jpeg', 'image/png']
)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "receipts_select_by_household_member"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'receipts'
    AND (storage.foldername(name))[1] IN (
      SELECT household_id::text
      FROM public.household_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "receipts_insert_by_household_member"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'receipts'
    AND (storage.foldername(name))[1] IN (
      SELECT household_id::text
      FROM public.household_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "receipts_delete_by_household_member"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'receipts'
    AND (storage.foldername(name))[1] IN (
      SELECT household_id::text
      FROM public.household_members
      WHERE user_id = auth.uid()
    )
  );
