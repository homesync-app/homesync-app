-- Fix weekly winner reward duplication and missing coin award bug by checking reference_id instead of created_at date range.

CREATE OR REPLACE FUNCTION public.award_weekly_winner_for_week(
  p_household_id UUID,
  p_week_start_date DATE
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_uid UUID;
  v_week_end DATE;
  v_winner_id UUID;
  v_winner_xp INTEGER;
  v_winner_row_id UUID;
  v_coins_awarded INTEGER := 20;
  v_existing public.weekly_winners%ROWTYPE;
BEGIN
  v_uid := public.current_app_user_id();
  v_week_end := p_week_start_date + 6;

  IF v_uid IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = v_uid
  ) THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'No autorizado'
    );
  END IF;

  SELECT *
  INTO v_existing
  FROM public.weekly_winners ww
  WHERE ww.household_id = p_household_id
    AND ww.week_start = p_week_start_date
    AND ww.created_at >= (p_week_start_date::timestamptz + interval '6 days')
  LIMIT 1;

  IF FOUND THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.ledger_entries le
      WHERE le.household_id = p_household_id
        AND le.user_id = v_existing.user_id
        and le.type = 'weekly_winner_bonus'
        and le.currency = 'COIN'
        and le.amount = coalesce(v_existing.coins_awarded, v_coins_awarded)
        and le.reference_type = 'weekly_winner'
        and le.reference_id = v_existing.id::text
    ) THEN
      INSERT INTO public.ledger_entries (
        user_id,
        household_id,
        amount,
        currency,
        type,
        description,
        reference_type,
        reference_id,
        source,
        created_by
      ) VALUES (
        v_existing.user_id,
        p_household_id,
        coalesce(v_existing.coins_awarded, v_coins_awarded),
        'COIN',
        'weekly_winner_bonus',
        '¡Premio por ganar la semana!',
        'weekly_winner',
        v_existing.id::text,
        'rpc',
        v_uid::text
      );
    END IF;

    RETURN jsonb_build_object(
      'success', true,
      'already_processed', true,
      'message', 'Esta semana ya fue procesada',
      'winner_id', v_existing.user_id,
      'xp_earned', v_existing.xp_earned,
      'coins_awarded', coalesce(v_existing.coins_awarded, v_coins_awarded),
      'week_start_date', p_week_start_date
    );
  END IF;

  SELECT le.user_id, sum(le.amount)::integer
  INTO v_winner_id, v_winner_xp
  FROM public.ledger_entries le
  WHERE le.household_id = p_household_id
    AND le.type = 'xp_earned'
    AND le.currency = 'XP'
    AND le.created_at >= p_week_start_date::timestamptz
    AND le.created_at < (p_week_start_date::timestamptz + interval '7 days')
  GROUP BY le.user_id
  ORDER BY sum(le.amount) DESC
  LIMIT 1;

  IF v_winner_id IS NULL OR coalesce(v_winner_xp, 0) <= 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'No hay actividades esta semana',
      'week_start_date', p_week_start_date
    );
  END IF;

  v_winner_row_id := gen_random_uuid();

  INSERT INTO public.weekly_winners (
    id,
    household_id,
    user_id,
    week_start,
    week_end,
    xp_earned,
    coins_awarded
  ) VALUES (
    v_winner_row_id,
    p_household_id,
    v_winner_id,
    p_week_start_date,
    v_week_end,
    v_winner_xp,
    v_coins_awarded
  )
  ON CONFLICT (household_id, week_start)
  DO UPDATE SET
    user_id = excluded.user_id,
    week_end = excluded.week_end,
    xp_earned = excluded.xp_earned,
    coins_awarded = excluded.coins_awarded,
    created_at = now()
  RETURNING id INTO v_winner_row_id;

  IF NOT EXISTS (
    SELECT 1
    FROM public.ledger_entries le
    WHERE le.household_id = p_household_id
      AND le.user_id = v_winner_id
      AND le.type = 'weekly_winner_bonus'
      AND le.currency = 'COIN'
      AND le.amount = v_coins_awarded
      AND le.reference_type = 'weekly_winner'
      AND le.reference_id = v_winner_row_id::text
  ) THEN
    INSERT INTO public.ledger_entries (
      user_id,
      household_id,
      amount,
      currency,
      type,
      description,
      reference_type,
      reference_id,
      source,
      created_by
    ) VALUES (
      v_winner_id,
      p_household_id,
      v_coins_awarded,
      'COIN',
      'weekly_winner_bonus',
      '¡Premio por ganar la semana!',
      'weekly_winner',
      v_winner_row_id::text,
      'rpc',
      v_uid::text
    );
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'already_processed', false,
    'message', 'Ganador premiado',
    'winner_id', v_winner_id,
    'xp_earned', v_winner_xp,
    'coins_awarded', v_coins_awarded,
    'week_start_date', p_week_start_date
  );
END;
$function$;

-- Repair script: Grant the missing reward for the week starting 2026-05-25 in household 39f979f1-de2f-4f18-88eb-2f3ba21a0753
DO $$
DECLARE
  v_ww_id UUID;
  v_user_id UUID;
  v_coins INTEGER := 20;
BEGIN
  SELECT id, user_id INTO v_ww_id, v_user_id
  FROM public.weekly_winners
  WHERE household_id = '39f979f1-de2f-4f18-88eb-2f3ba21a0753'
    AND week_start = '2026-05-25';

  IF FOUND THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.ledger_entries
      WHERE household_id = '39f979f1-de2f-4f18-88eb-2f3ba21a0753'
        AND user_id = v_user_id
        AND type = 'weekly_winner_bonus'
        AND reference_type = 'weekly_winner'
        AND reference_id = v_ww_id::text
    ) THEN
      INSERT INTO public.ledger_entries (
        user_id,
        household_id,
        amount,
        currency,
        type,
        description,
        reference_type,
        reference_id,
        source
      ) VALUES (
        v_user_id,
        '39f979f1-de2f-4f18-88eb-2f3ba21a0753',
        v_coins,
        'COIN',
        'weekly_winner_bonus',
        '¡Premio por ganar la semana!',
        'weekly_winner',
        v_ww_id::text,
        'rpc'
      );
    END IF;
  END IF;
END $$;
