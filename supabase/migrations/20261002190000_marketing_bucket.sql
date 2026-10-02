-- Bucket público con el kit de redes (carruseles, reels, historias) y su
-- manifest (content_kit.json). Muse y la API de Instagram descargan cada pieza
-- por URL pública, por eso es public.
--
-- Sin policies sobre storage.objects para este bucket: nadie puede listarlo ni
-- escribir desde el cliente. Solo se sube con la service role
-- (tmp/marketing/publish_kit.py). Todo el contenido usa los hogares demo.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'marketing',
  'marketing',
  true,
  52428800,
  ARRAY['image/jpeg', 'image/png', 'video/mp4', 'application/json']
)
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;
