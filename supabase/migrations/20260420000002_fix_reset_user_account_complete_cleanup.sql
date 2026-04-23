-- Complete reset_user_account: add missing table cleanups.
-- Covers tasks (all user refs), rewards, redemptions, mercadopago_connections,
-- user_fcm_tokens, household_invitations, plus orphan household cleanup.

create or replace function public.reset_user_account()
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

  UPDATE public.users
  SET full_name = 'Usuario',
      avatar_url = NULL,
      mercadopago_alias = NULL
  WHERE id = v_user_id;

  RETURN jsonb_build_object('success', true, 'message', 'Cuenta reseteada correctamente');
END;
$$;
