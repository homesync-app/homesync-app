-- Bucket privado para tickets de compra.
-- Path: receipts/{household_id}/{uuid}.webp
-- Las signed URLs se generan on demand; nunca se persisten URLs en DB.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'receipts',
  'receipts',
  false,        -- privado: acceso solo via signed URLs
  5242880,      -- 5 MB hard limit por archivo (real ~60-120 KB comprimido)
  ARRAY['image/webp', 'image/jpeg', 'image/png']
)
ON CONFLICT (id) DO NOTHING;

-- RLS: solo miembros del household pueden leer/subir/borrar sus propios tickets.
-- El primer segmento del path debe ser un household_id del usuario.

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
