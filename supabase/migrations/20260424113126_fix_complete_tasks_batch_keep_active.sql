-- Reconstructed from remote migration history (version 20260424113126).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.complete_tasks_batch(
  p_request_id TEXT,
  p_user_ids UUID[],
  p_task_ids UUID[],
  p_household_id UUID,
  p_completed_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_task_id UUID;
  v_xp_reward INTEGER;
  v_coin_reward INTEGER;
  v_task_title TEXT;
  v_task_desc TEXT;
  v_task_cat TEXT;
  v_due_at TIMESTAMPTZ;
  v_rec_type TEXT;
  v_rec_interval INTEGER;
  v_next_due_at TIMESTAMPTZ;
  v_activity_id UUID;
  v_user_id UUID;
  v_eff_completed_at TIMESTAMPTZ;
  v_count INTEGER := 0;
BEGIN
  v_eff_completed_at := COALESCE(p_completed_at, NOW());

  FOREACH v_task_id IN ARRAY p_task_ids
  LOOP
    SELECT title, description, category, xp_reward, coin_reward,
           due_at, recurrence_type, recurrence_interval
    INTO v_task_title, v_task_desc, v_task_cat, v_xp_reward, v_coin_reward,
         v_due_at, v_rec_type, v_rec_interval
    FROM public.tasks
    WHERE id = v_task_id
      AND household_id = p_household_id
      AND status IN (
        'assigned','active','in_progress','objected',
        'pending_approval','pending_verification','verified'
      )
    FOR UPDATE;

    IF FOUND THEN
      v_next_due_at := public.calculate_next_task_due_at(
        v_due_at, v_rec_type, v_rec_interval
      );

      INSERT INTO public.household_activities (
        household_id, user_id, event_type, title, description, metadata
      ) VALUES (
        p_household_id, p_user_ids[1], 'task_completed', v_task_title, v_task_desc,
        jsonb_build_object(
          'task_id', v_task_id,
          'batch_request_id', p_request_id,
          'xp_per_user', v_xp_reward,
          'coins_per_user', v_coin_reward,
          'performers', p_user_ids,
          'category', v_task_cat
        )
      ) RETURNING id INTO v_activity_id;

      UPDATE public.tasks
      SET
        status = 'active',
        due_at = COALESCE(v_next_due_at, due_at),
        completed_at = v_eff_completed_at,
        completed_by = p_user_ids[1],
        last_completed_at = v_eff_completed_at,
        last_verified_by = NULL,
        verified_by = NULL,
        verified_at = NULL,
        updated_at = NOW()
      WHERE id = v_task_id;

      FOREACH v_user_id IN ARRAY p_user_ids
      LOOP
        IF v_xp_reward > 0 THEN
          INSERT INTO public.ledger_entries (
            id, household_id, user_id, type, amount, currency,
            reference_id, reference_type, description, source, created_by
          ) VALUES (
            gen_random_uuid(), p_household_id, v_user_id, 'xp_earned',
            v_xp_reward, 'XP', v_activity_id::TEXT, 'activity',
            'XP: ' || v_task_title, 'rpc_batch', v_user_id::TEXT
          ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
        END IF;

        IF v_coin_reward > 0 THEN
          INSERT INTO public.ledger_entries (
            id, household_id, user_id, type, amount, currency,
            reference_id, reference_type, description, source, created_by
          ) VALUES (
            gen_random_uuid(), p_household_id, v_user_id, 'coins_earned',
            v_coin_reward, 'COIN', v_activity_id::TEXT, 'activity',
            'Coins: ' || v_task_title, 'rpc_batch', v_user_id::TEXT
          ) ON CONFLICT (user_id, type, reference_id) DO NOTHING;
        END IF;
      END LOOP;

      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'message', v_count::TEXT || ' tasks completed in batch',
    'completed_count', v_count
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_tasks_batch(TEXT, UUID[], UUID[], UUID, TIMESTAMPTZ) TO authenticated;

UPDATE public.tasks
SET status = 'active', updated_at = NOW()
WHERE status IN ('pending_verification', 'verified');
