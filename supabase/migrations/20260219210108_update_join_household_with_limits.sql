-- Reconstructed from remote migration history (version 20260219210108).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.join_household(
  p_code TEXT,
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_invitation RECORD;
  v_member_count INTEGER;
  v_result JSONB;
BEGIN
  SELECT hi.*, h.household_type INTO v_invitation 
  FROM public.household_invitations hi
  JOIN households h ON h.id = hi.household_id
  WHERE hi.code = UPPER(p_code)
  AND hi.used_at IS NULL
  AND hi.expires_at > NOW();
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Câ”œâ”‚digo invâ”œÃ­lido o expirado');
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM household_members 
    WHERE household_id = v_invitation.household_id AND user_id = p_user_id
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'Ya eres miembro de este hogar');
  END IF;
  
  SELECT COUNT(*) INTO v_member_count
  FROM household_members
  WHERE household_id = v_invitation.household_id;
  
  IF v_invitation.household_type = 'couple' AND v_member_count >= 2 THEN
    RETURN jsonb_build_object(
      'success', false, 
      'message', 'Este hogar ya tiene 2 miembros (mâ”œÃ­ximo para Pareja)'
    );
  END IF;
  
  INSERT INTO public.household_members (
    household_id, user_id, role
  ) VALUES (
    v_invitation.household_id, p_user_id, 'member'
  );
  
  UPDATE public.household_invitations
  SET used_at = NOW(), used_by = p_user_id
  WHERE id = v_invitation.id;
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Te uniste al hogar exitosamente',
    'household_id', v_invitation.household_id,
    'household_type', v_invitation.household_type
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.get_household_info(
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'household_id', h.id,
    'household_type', h.household_type,
    'display_name', h.display_name,
    'role', hm.role,
    'member_count', member_count.count
  ) INTO v_result
  FROM households h
  JOIN household_members hm ON hm.household_id = h.id
  JOIN (SELECT household_id, COUNT(*) as count FROM household_members GROUP BY household_id) member_count ON member_count.household_id = h.id
  WHERE hm.user_id = p_user_id
  LIMIT 1;
  
  RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;
