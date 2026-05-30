-- Reconstructed from remote migration history (version 20260427114400).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

UPDATE storage.buckets
SET file_size_limit = 2097152,
    allowed_mime_types = ARRAY['image/webp', 'image/png']
WHERE id = 'custom-avatars';
;