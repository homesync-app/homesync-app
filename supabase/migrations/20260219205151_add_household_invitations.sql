-- Reconstructed from remote migration history (version 20260219205151).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE TABLE IF NOT EXISTS public.household_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  code TEXT UNIQUE NOT NULL DEFAULT UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6)),
  created_by UUID NOT NULL REFERENCES public.users(id),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),
  used_at TIMESTAMPTZ,
  used_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_household_invitations_code ON public.household_invitations(code);
CREATE INDEX idx_household_invitations_household ON public.household_invitations(household_id);

ALTER TABLE public.household_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own invitations"
ON public.household_invitations FOR SELECT
USING (created_by = auth.uid() OR used_by = auth.uid());

CREATE POLICY "Owners can create invitations"
ON public.household_invitations FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM household_members hm
    WHERE hm.household_id = household_invitations.household_id
    AND hm.user_id = auth.uid()
    AND hm.role = 'owner'
  )
);

CREATE OR REPLACE FUNCTION public.generate_invitation_code(
  p_household_id UUID,
  p_user_id UUID
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_code TEXT;
BEGIN
  INSERT INTO public.household_invitations (
    household_id,
    created_by
  ) VALUES (
    p_household_id,
    p_user_id
  ) RETURNING code INTO v_code;
  
  RETURN v_code;
END;
$$;

CREATE OR REPLACE FUNCTION public.join_household(
  p_code TEXT,
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_invitation RECORD;
  v_result JSONB;
BEGIN
  SELECT * INTO v_invitation 
  FROM public.household_invitations 
  WHERE code = UPPER(p_code)
  AND used_at IS NULL
  AND expires_at > NOW();
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Câ”œâ”‚digo invâ”œÃ­lido o expirado'
    );
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM household_members 
    WHERE household_id = v_invitation.household_id 
    AND user_id = p_user_id
  ) THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Ya eres miembro de este hogar'
    );
  END IF;
  
  INSERT INTO public.household_members (
    household_id,
    user_id,
    role
  ) VALUES (
    v_invitation.household_id,
    p_user_id,
    'member'
  );
  
  UPDATE public.household_invitations
  SET used_at = NOW(), used_by = p_user_id
  WHERE id = v_invitation.id;
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Te uniste al hogar exitosamente',
    'household_id', v_invitation.household_id
  );
END;
$$;
