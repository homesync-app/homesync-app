-- Reconstructed from remote migration history (version 20260220201219).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 1. Update the trigger function to also handle username/name metadata Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      NEW.raw_user_meta_data->>'preferred_username',
      split_part(NEW.email, '@', 1)  -- fallback: use part before @
    )
  )
  ON CONFLICT (id) DO UPDATE
    SET full_name = COALESCE(
      EXCLUDED.full_name,
      public.users.full_name
    );
  RETURN NEW;
END;
$$;

-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 2. Also fix existing users who still have NULL full_name Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
UPDATE public.users u
SET full_name = COALESCE(
  au.raw_user_meta_data->>'full_name',
  au.raw_user_meta_data->>'name',
  split_part(au.email, '@', 1)
)
FROM auth.users au
WHERE u.id = au.id
  AND (u.full_name IS NULL OR u.full_name = '');
;