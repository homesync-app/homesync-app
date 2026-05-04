-- Custom premium avatars.
-- The original uploaded photo is never stored. Only the final generated avatar
-- is persisted in Storage.

CREATE TABLE IF NOT EXISTS public.custom_avatar_generations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  household_id UUID REFERENCES public.households(id) ON DELETE SET NULL,
  avatar_url TEXT NOT NULL,
  source_image_count INTEGER NOT NULL DEFAULT 1 CHECK (source_image_count BETWEEN 1 AND 4),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_custom_avatar_generations_user_month
  ON public.custom_avatar_generations (user_id, created_at DESC);

ALTER TABLE public.custom_avatar_generations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users can view own custom avatar generations"
  ON public.custom_avatar_generations;

CREATE POLICY "users can view own custom avatar generations"
  ON public.custom_avatar_generations
  FOR SELECT
  TO authenticated
  USING (user_id = public.current_app_user_id());

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'custom-avatars',
  'custom-avatars',
  true,
  524288,
  ARRAY['image/webp', 'image/png']
)
ON CONFLICT (id) DO UPDATE
SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

