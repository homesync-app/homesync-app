-- Reconstructed from remote migration history (version 20260219212802).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE TABLE IF NOT EXISTS public.rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cost INTEGER NOT NULL CHECK (cost > 0),
  icon TEXT DEFAULT 'Â­Æ’Ã„Ã¼',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.reward_redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  household_id UUID REFERENCES public.households(id),
  cost INTEGER NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'fulfilled', 'cancelled')),
  fulfilled_by UUID REFERENCES public.users(id),
  fulfilled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rewards_household ON public.rewards(household_id);
CREATE INDEX idx_redemptions_user ON public.reward_redemptions(user_id);
CREATE INDEX idx_redemptions_household ON public.reward_redemptions(household_id);

ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_redemptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view household rewards"
ON public.rewards FOR SELECT
USING (household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid()));

CREATE POLICY "Owners can manage rewards"
ON public.rewards FOR ALL
USING (household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid() AND role = 'owner'));

CREATE POLICY "Users can view own redemptions"
ON public.reward_redemptions FOR SELECT
USING (user_id = auth.uid() OR household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid()));

CREATE POLICY "Users can create redemptions"
ON public.reward_redemptions FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.redeem_reward(
  p_reward_id UUID,
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_reward RECORD;
  v_user_balance INTEGER;
  v_household_id UUID;
  v_redemption_id UUID;
BEGIN
  SELECT r.*, hm.household_id INTO v_reward
  FROM rewards r
  JOIN household_members hm ON hm.household_id = r.household_id
  WHERE r.id = p_reward_id AND hm.user_id = p_user_id AND r.is_active = true;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Recompensa no encontrada');
  END IF;
  
  SELECT COALESCE(SUM(amount), 0) INTO v_user_balance
  FROM ledger_entries
  WHERE user_id = p_user_id AND household_id = v_reward.household_id AND currency = 'COIN';
  
  IF v_user_balance < v_reward.cost THEN
    RETURN jsonb_build_object(
      'success', false, 
      'message', 'No tienes suficientes coins',
      'balance', v_user_balance,
      'cost', v_reward.cost
    );
  END IF;
  
  INSERT INTO ledger_entries (
    household_id, user_id, type, amount, currency, 
    reference_type, description
  ) VALUES (
    v_reward.household_id, p_user_id, 'reward_redemption', -v_reward.cost, 'COIN',
    'reward', 'Canje: ' || v_reward.title
  );
  
  INSERT INTO reward_redemptions (
    reward_id, user_id, household_id, cost, status
  ) VALUES (
    p_reward_id, p_user_id, v_reward.household_id, v_reward.cost, 'pending'
  ) RETURNING id INTO v_redemption_id;
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Recompensa canjeada',
    'redemption_id', v_redemption_id,
    'new_balance', v_user_balance - v_reward.cost
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.fulfill_redemption(
  p_redemption_id UUID,
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_redemption RECORD;
BEGIN
  SELECT * INTO v_redemption FROM reward_redemptions WHERE id = p_redemption_id AND status = 'pending';
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Canje no encontrado o ya procesado');
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM household_members 
    WHERE household_id = v_redemption.household_id AND user_id = p_user_id AND role = 'owner'
  ) THEN
    RETURN jsonb_build_object('success', false, 'message', 'No tienes permiso para completar canjes');
  END IF;
  
  UPDATE reward_redemptions
  SET status = 'fulfilled', fulfilled_by = p_user_id, fulfilled_at = NOW()
  WHERE id = p_redemption_id;
  
  RETURN jsonb_build_object('success', true, 'message', 'Recompensa entregada');
END;
$$;

CREATE OR REPLACE FUNCTION public.get_available_rewards(
  p_user_id UUID
)
RETURNS TABLE (
  id UUID, title TEXT, description TEXT, cost INTEGER, icon TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT r.id, r.title, r.description, r.cost, r.icon
  FROM rewards r
  WHERE r.household_id IN (SELECT household_id FROM household_members WHERE user_id = p_user_id)
  AND r.is_active = true
  ORDER BY r.cost ASC;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_redemption_history(
  p_user_id UUID
)
RETURNS TABLE (
  id UUID, reward_title TEXT, cost INTEGER, status TEXT, created_at TIMESTAMPTZ, fulfilled_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT rr.id, r.title, rr.cost, rr.status, rr.created_at, rr.fulfilled_at
  FROM reward_redemptions rr
  JOIN rewards r ON r.id = rr.reward_id
  WHERE rr.user_id = p_user_id
  ORDER BY rr.created_at DESC;
END;
$$;

INSERT INTO public.rewards (title, description, cost, icon) VALUES
  ('Noche de peliculas', 'Elegis la pelicula y pedis delivery', 50, 'Â­Æ’Ã„Â¼'),
  ('Pizza a eleccion', 'Pizza de tu local favorito', 100, 'Â­Æ’Ã¬Ã²'),
  ('Dia de gaming', 'Un dia libre para jugar', 75, 'Â­Æ’Ã„Â«'),
  ('Masaje', 'Masaje relajante', 150, 'Â­Æ’Ã†Ã¥'),
  ('Dia libre de tareas', 'No hacer tareas por 1 dia', 200, 'Â­Æ’Ã®Ã '),
  ('Cena especial', 'Cena en restaurante a eleccion', 300, 'Â­Æ’Ã¬Â¢Â´Â©Ã…'),
  ('Sorpresa', 'Un regalo sorpresa', 250, 'Â­Æ’Ã„Ã¼');
