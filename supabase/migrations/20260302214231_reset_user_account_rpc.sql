-- Reconstructed from remote migration history (version 20260302214231).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.reset_user_account()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'message', 'No autenticado');
  END IF;

  -- Delete all task associations (both created and assigned)
  DELETE FROM public.tasks WHERE created_by_id = v_user_id OR assigned_to = v_user_id;
  
  -- Delete expense participation (splits first, then whole expenses if they are the owner)
  -- Deleting expense_splits for user doesn't delete expenses they didn't create
  DELETE FROM public.expense_splits WHERE user_id = v_user_id;
  DELETE FROM public.expenses WHERE created_by_id = v_user_id OR paid_by = v_user_id;
  
  -- Reset progress (coins, xp, ledger history)
  DELETE FROM public.ledger_entries WHERE user_id = v_user_id;
  DELETE FROM public.reward_redemptions WHERE user_id = v_user_id;
  DELETE FROM public.notifications WHERE user_id = v_user_id;
  DELETE FROM public.household_activities WHERE user_id = v_user_id;
  DELETE FROM public.savings_contributions WHERE user_id = v_user_id;
  DELETE FROM public.weekly_winners WHERE user_id = v_user_id;
  DELETE FROM public.weekly_duel_history WHERE winner_user_id = v_user_id OR loser_user_id = v_user_id;

  -- Reset basic profile (optional)
  UPDATE public.users 
  SET full_name = 'Usuario', 
      avatar_url = NULL,
      mercadopago_alias = NULL
  WHERE id = v_user_id;

  RETURN jsonb_build_object('success', true, 'message', 'Cuenta reseteada correctamente');
END;
$$;
;