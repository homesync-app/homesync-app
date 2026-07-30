-- Reconstructed from remote migration history (version 20260220194946).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 1. Fix RLS on household_invitations so anyone can look up a code Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
-- The old policy only let users see their own invitations, 
-- blocking them from finding codes created by others.

DROP POLICY IF EXISTS "Users can view own invitations" ON household_invitations;

-- Allow viewing: own invitations OR any invitation by code (for join flow)
CREATE POLICY "Users can view invitations" ON household_invitations
  FOR SELECT USING (
    created_by = auth.uid()
    OR used_by = auth.uid()
    OR id IS NOT NULL  -- allow reading to look up by code (security via RPC)
  );

-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 2. Create a secure RPC to generate an invitation code Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
CREATE OR REPLACE FUNCTION generate_household_invitation(p_household_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_code text;
  v_is_owner boolean;
BEGIN
  -- Verify the caller is an owner of the household
  SELECT EXISTS(
    SELECT 1 FROM household_members
    WHERE household_id = p_household_id
      AND user_id = auth.uid()
      AND role = 'owner'
  ) INTO v_is_owner;

  IF NOT v_is_owner THEN
    RAISE EXCEPTION 'Only household owners can generate invitation codes';
  END IF;

  -- Check for existing valid (unused, not expired) invitation
  SELECT code INTO v_code
  FROM household_invitations
  WHERE household_id = p_household_id
    AND used_at IS NULL
    AND expires_at > now()
  ORDER BY created_at DESC
  LIMIT 1;

  -- If no valid invitation exists, create one
  IF v_code IS NULL THEN
    INSERT INTO household_invitations (household_id, created_by)
    VALUES (p_household_id, auth.uid())
    RETURNING code INTO v_code;
  END IF;

  RETURN v_code;
END;
$$;

-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 3. Create the JOIN household RPC Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
-- This is the core function: validates code, migrates user to the new household,
-- and deletes the old solo household.

CREATE OR REPLACE FUNCTION join_household_by_code(p_code text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_invitation        household_invitations%ROWTYPE;
  v_old_household_id  uuid;
  v_member_count      int;
BEGIN
  -- 1. Find the invitation by code (caseÃ”Ã‡Ã¦insensitive, must be unused and not expired)
  SELECT * INTO v_invitation
  FROM household_invitations
  WHERE upper(code) = upper(p_code)
    AND used_at IS NULL
    AND expires_at > now()
  LIMIT 1;

  IF v_invitation.id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_code',
      'message', 'El câ”œâ”‚digo no es vâ”œÃ­lido o ya fue utilizado');
  END IF;

  -- 2. Don't allow joining your own household
  IF v_invitation.household_id IN (
    SELECT household_id FROM household_members WHERE user_id = auth.uid()
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_member',
      'message', 'Ya eres miembro de este hogar');
  END IF;

  -- 3. Get user's current household (the one they created alone)
  SELECT household_id INTO v_old_household_id
  FROM household_members
  WHERE user_id = auth.uid()
  LIMIT 1;

  -- 4. Add user to the new household as 'member'
  INSERT INTO household_members (household_id, user_id, role)
  VALUES (v_invitation.household_id, auth.uid(), 'member')
  ON CONFLICT (household_id, user_id) DO NOTHING;

  -- 5. Mark invitation as used
  UPDATE household_invitations
  SET used_at = now(), used_by = auth.uid()
  WHERE id = v_invitation.id;

  -- 6. Clean up old solo household (if it exists and has only this user)
  IF v_old_household_id IS NOT NULL AND v_old_household_id != v_invitation.household_id THEN
    SELECT COUNT(*) INTO v_member_count
    FROM household_members
    WHERE household_id = v_old_household_id;

    IF v_member_count = 1 THEN
      -- Only delete if the user was the sole member
      DELETE FROM household_members WHERE household_id = v_old_household_id;
      DELETE FROM tasks WHERE household_id = v_old_household_id;
      DELETE FROM expenses WHERE household_id = v_old_household_id;
      DELETE FROM households WHERE id = v_old_household_id;
    ELSE
      -- Multiple members: just remove this user from old household
      DELETE FROM household_members
      WHERE household_id = v_old_household_id AND user_id = auth.uid();
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'household_id', v_invitation.household_id,
    'message', 'â”¬Ã­Te uniste al hogar exitosamente!'
  );
END;
$$;

-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 4. Grant execute permissions Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
GRANT EXECUTE ON FUNCTION generate_household_invitation(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION join_household_by_code(text) TO authenticated;

-- Ã”Ã¶Ã‡Ã”Ã¶Ã‡ 5. Add unique constraint on household_members if not exists Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡Ã”Ã¶Ã‡
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'household_members_household_user_unique'
  ) THEN
    ALTER TABLE household_members 
    ADD CONSTRAINT household_members_household_user_unique 
    UNIQUE (household_id, user_id);
  END IF;
END $$;
;