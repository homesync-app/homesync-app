-- ============================================
-- REWARD TEMPLATES SYSTEM
-- ============================================

-- Create reward_templates table
CREATE TABLE IF NOT EXISTS public.reward_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  cost INTEGER NOT NULL DEFAULT 5,
  icon TEXT,
  is_popular BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.reward_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies for reward_templates (read-only for all authenticated)
CREATE POLICY "Reward Templates are readable by all"
  ON public.reward_templates FOR SELECT
  TO authenticated
  USING (true);

-- Insert reward templates
INSERT INTO public.reward_templates (title, description, cost, icon, is_popular, sort_order) VALUES
  ('Masaje Relajante', 'Un masaje de 15 minutos para desestresarse', 50, '💆', true, 1),
  ('Elegir Película', 'Tienes el control total del control remoto hoy', 30, '🎬', true, 2),
  ('Desayuno en la Cama', 'Desayuno completo preparado y servido donde estés', 80, '🥞', false, 3),
  ('Cena Especial', 'Tu comida favorita preparada con amor', 100, '🍽️', false, 4),
  ('Organizar una Cita', 'Una salida planeada de principio a fin', 150, '✨', true, 5),
  ('Vale por un Chocolate', 'Un antojo dulce de tu elección', 15, '🍫', false, 6),
  ('Día Libre de Tareas', 'Hoy no tienes que lavar platos ni limpiar nada', 200, '🏠', true, 7),
  ('Elegir Música una Semana', 'Control total de la playlist en el auto y la casa', 45, '🎵', false, 8),
  ('Café de Especialidad', 'Un café preparado con arte', 20, '☕', false, 9),
  ('Siesta Ininterrumpida', '1 hora de silencio absoluto para dormir', 40, '😴', false, 10)
ON CONFLICT DO NOTHING;

-- ============================================
-- RPC: Clone reward templates to user household
-- ============================================

CREATE OR REPLACE FUNCTION public.clone_reward_templates(
  p_user_id UUID,
  p_template_ids UUID[] DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_household_id UUID;
  v_cloned_count INTEGER := 0;
  v_template record;
BEGIN
  -- Get household
  SELECT household_id INTO v_household_id
  FROM public.household_members
  WHERE user_id = p_user_id
  LIMIT 1;

  IF v_household_id IS NULL THEN
    -- If they don't have a household yet, create one
    INSERT INTO public.households (name)
    VALUES ('Mi Hogar')
    RETURNING id INTO v_household_id;

    INSERT INTO public.household_members (
      household_id,
      user_id,
      role
    ) VALUES (
      v_household_id,
      p_user_id,
      'owner'
    );
  END IF;

  -- Clone templates to the 'rewards' table
  IF p_template_ids IS NULL THEN
    -- Clone all templates
    FOR v_template IN SELECT * FROM public.reward_templates ORDER BY sort_order
    LOOP
      INSERT INTO public.rewards (
        household_id,
        title,
        description,
        cost,
        icon,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.title,
        v_template.description,
        v_template.cost,
        v_template.icon,
        p_user_id,
        true -- Admin/Template rewards are pre-approved
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  ELSE
    -- Clone specific templates
    FOR v_template IN 
      SELECT * FROM public.reward_templates 
      WHERE id = ANY(p_template_ids)
      ORDER BY sort_order
    LOOP
      INSERT INTO public.rewards (
        household_id,
        title,
        description,
        cost,
        icon,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.title,
        v_template.description,
        v_template.cost,
        v_template.icon,
        p_user_id,
        true
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  END IF;

  RETURN v_cloned_count;
END;
$$;

-- Grant permission
GRANT EXECUTE ON FUNCTION public.clone_reward_templates(UUID, UUID[]) TO authenticated;
