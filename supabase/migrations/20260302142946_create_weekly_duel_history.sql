-- Reconstructed from remote migration history (version 20260302142946).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Tabla para guardar el historial de duelos semanales
CREATE TABLE IF NOT EXISTS public.weekly_duel_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  winner_user_id UUID REFERENCES auth.users(id),
  winner_name TEXT,
  loser_user_id UUID REFERENCES auth.users(id),
  loser_name TEXT,
  winner_xp INTEGER DEFAULT 0,
  loser_xp INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(household_id, week_start_date)
);

-- Habilitar RLS
ALTER TABLE public.weekly_duel_history ENABLE ROW LEVEL SECURITY;

-- Polâ”œÂ¡tica para que los miembros del hogar puedan ver el historial
CREATE POLICY "Members can view duel history" ON public.weekly_duel_history
  FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.household_members WHERE user_id = auth.uid()
    )
  );

-- Polâ”œÂ¡tica para que cualquier miembro pueda insertar
CREATE POLICY "Members can insert duel history" ON public.weekly_duel_history
  FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT household_id FROM public.household_members WHERE user_id = auth.uid()
    )
  );

-- Funciâ”œâ”‚n RPC para guardar el resultado del duelo semanal
CREATE OR REPLACE FUNCTION public.save_weekly_duel_result(
  p_household_id UUID,
  p_week_start_date DATE,
  p_winner_user_id UUID,
  p_winner_name TEXT,
  p_loser_user_id UUID,
  p_loser_name TEXT,
  p_winner_xp INTEGER,
  p_loser_xp INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSONB;
BEGIN
  INSERT INTO public.weekly_duel_history (
    household_id,
    week_start_date,
    winner_user_id,
    winner_name,
    loser_user_id,
    loser_name,
    winner_xp,
    loser_xp
  ) VALUES (
    p_household_id,
    p_week_start_date,
    p_winner_user_id,
    p_winner_name,
    p_loser_user_id,
    p_loser_name,
    p_winner_xp,
    p_loser_xp
  )
  ON CONFLICT (household_id, week_start_date)
  DO UPDATE SET
    winner_user_id = p_winner_user_id,
    winner_name = p_winner_name,
    loser_user_id = p_loser_user_id,
    loser_name = p_loser_name,
    winner_xp = p_winner_xp,
    loser_xp = p_loser_xp,
    created_at = NOW();

  RETURN jsonb_build_object('success', true, 'message', 'Duelo guardado correctamente');
END;
$$;

-- Funciâ”œâ”‚n RPC para obtener el historial de duelos
CREATE OR REPLACE FUNCTION public.get_weekly_duel_history(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_household_id UUID;
  v_result JSONB;
BEGIN
  SELECT household_id INTO v_household_id
  FROM public.household_members
  WHERE user_id = p_user_id
  LIMIT 1;

  IF v_household_id IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  SELECT jsonb_agg(t) INTO v_result
  FROM (
    SELECT 
      id,
      week_start_date,
      winner_name,
      loser_name,
      winner_xp,
      loser_xp,
      created_at,
      CASE 
        WHEN winner_user_id = p_user_id THEN 'win'
        WHEN loser_user_id = p_user_id THEN 'loss'
        ELSE 'neutral'
      END as user_result
    FROM public.weekly_duel_history
    WHERE household_id = v_household_id
    ORDER BY week_start_date DESC
    LIMIT 12
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- Grants
GRANT ALL ON public.weekly_duel_history TO authenticated;
GRANT EXECUTE ON FUNCTION public.save_weekly_duel_result TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_weekly_duel_history TO authenticated;
