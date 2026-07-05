-- ─────────────────────────────────────────────────────────────────────────────
-- Account deletion RPC (Google Play / App Store requirement).
--
-- WHY a soft-delete instead of DELETE FROM public.users:
--   public.users(id) is referenced by ~20 FKs with a MIX of ON DELETE behaviors
--   (CASCADE, SET NULL, and some NO ACTION). A hard row delete risks failing on
--   a NO ACTION constraint and is hard to verify safely. Instead we:
--     1. Purge all of the user's own data (same surface as reset_user_account).
--     2. Strip PII from the users row (email, name, avatar, firebase_uid, alias).
--     3. Stamp deleted_at so the account is unusable and re-login can't resurrect
--        it (firebase_uid is cleared, so ensure_user_profile creates a fresh row).
--   The client deletes the actual Firebase Auth credential via
--   FirebaseAuth.currentUser.delete(), which is the real "account" from the
--   user's perspective. This combination satisfies the store deletion policy.
--
-- This RPC is SECURITY DEFINER + pinned search_path and only ever acts on the
-- caller's own id (current_app_user_id()). It does NOT touch other members'
-- rows, and it does NOT change any RLS policy.
-- ─────────────────────────────────────────────────────────────────────────────

-- Soft-delete marker. Nullable, defaults to NULL (active account).
alter table public.users
  add column if not exists deleted_at timestamptz;

comment on column public.users.deleted_at is
  'Set by delete_account() when a user deletes their account. Non-null means the row is a tombstone: PII is stripped and firebase_uid is cleared so re-login creates a fresh profile.';

create or replace function public.delete_account()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
DECLARE
  v_user_id uuid;
  v_household_id uuid;
  v_member_count int;
BEGIN
  v_user_id := public.current_app_user_id();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'No autenticado');
  END IF;

  -- ── 1. Purge the user's own data (mirrors reset_user_account) ──────────────
  DELETE FROM public.tasks
  WHERE created_by_id = v_user_id
     OR assigned_to = v_user_id
     OR completed_by = v_user_id
     OR last_verified_by = v_user_id
     OR objected_by = v_user_id;

  DELETE FROM public.expense_splits WHERE user_id = v_user_id;
  DELETE FROM public.expenses
  WHERE created_by_id = v_user_id OR paid_by = v_user_id;

  DELETE FROM public.reward_redemptions
  WHERE user_id = v_user_id OR fulfilled_by = v_user_id;
  DELETE FROM public.rewards
  WHERE created_by = v_user_id OR suggested_to = v_user_id;

  DELETE FROM public.ledger_entries WHERE user_id = v_user_id;
  DELETE FROM public.savings_contributions WHERE user_id = v_user_id;
  DELETE FROM public.weekly_winners WHERE user_id = v_user_id;
  DELETE FROM public.weekly_duel_history
  WHERE winner_user_id = v_user_id OR loser_user_id = v_user_id;
  DELETE FROM public.notifications WHERE user_id = v_user_id;
  DELETE FROM public.household_activities WHERE user_id = v_user_id;

  DELETE FROM public.mercadopago_connections WHERE user_id = v_user_id;
  DELETE FROM public.user_fcm_tokens WHERE user_id = v_user_id;

  DELETE FROM public.household_invitations
  WHERE created_by = v_user_id OR used_by = v_user_id;

  -- ── 2. Household membership + orphan household cleanup ─────────────────────
  SELECT household_id INTO v_household_id
  FROM public.household_members
  WHERE user_id = v_user_id
  LIMIT 1;

  DELETE FROM public.household_members WHERE user_id = v_user_id;

  IF v_household_id IS NOT NULL THEN
    SELECT COUNT(*) INTO v_member_count
    FROM public.household_members
    WHERE household_id = v_household_id;

    IF v_member_count = 0 THEN
      DELETE FROM public.tasks WHERE household_id = v_household_id;
      DELETE FROM public.expenses WHERE household_id = v_household_id;
      DELETE FROM public.shopping_items WHERE household_id = v_household_id;
      DELETE FROM public.household_activities WHERE household_id = v_household_id;
      DELETE FROM public.household_invitations WHERE household_id = v_household_id;
      DELETE FROM public.households WHERE id = v_household_id;
    END IF;
  END IF;

  -- ── 3. Anonymize + tombstone the users row ─────────────────────────────────
  -- Clearing firebase_uid is critical: ensure_user_profile() looks up by it, so
  -- a future login with the same Firebase account creates a brand-new profile
  -- instead of resurrecting this deleted one.
  UPDATE public.users
  SET full_name = NULL,
      avatar_url = NULL,
      mercadopago_alias = NULL,
      email = 'deleted+' || v_user_id::text || '@homesync.deleted',
      firebase_uid = NULL,
      deleted_at = now()
  WHERE id = v_user_id;

  RETURN jsonb_build_object('success', true, 'message', 'Cuenta eliminada');
END;
$$;

comment on function public.delete_account() is
  'Deletes the calling user''s account: purges their data, anonymizes the users row and stamps deleted_at. Client must also call FirebaseAuth.currentUser.delete(). Self-only (current_app_user_id); never affects other members.';

-- Lock down execution: authenticated callers only, never anon.
revoke execute on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated, service_role;
