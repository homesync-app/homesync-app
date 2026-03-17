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
INSERT INTO public.reward_templates (title, description, cost, icon, is_popular, sort_order, category) VALUES
  ('Café o mate preparado', 'Una pausa rica preparada con cariño', 20, '☕', true, 1, 'mimos'),
  ('Snack sorpresa', 'Un antojo inesperado para alegrar el día', 15, '🍪', true, 2, 'mimos'),
  ('Mini nota romántica', 'Un mensaje corto para sonreír', 10, '💌', false, 3, 'mimos'),
  ('15 minutos de masajes', 'Masaje relajante de 15 minutos', 40, '💆', true, 4, 'mimos'),
  ('Helado de tu elección', 'Un postre frío para celebrar', 15, '🍦', true, 5, 'mimos'),

  ('Noche de cine en casa', 'Película y ambiente especial en casa', 35, '🎬', true, 6, 'momentos'),
  ('Tarde de gaming', 'Partida juntos con snacks incluidos', 35, '🎮', true, 7, 'momentos'),
  ('Noche de juegos de mesa', 'Tiempo de juego y risas', 35, '🎲', false, 8, 'momentos'),
  ('Cena casera especial', 'Tu comida favorita hecha en casa', 60, '🍽️', true, 9, 'momentos'),
  ('Picnic en casa', 'Manta, algo rico y desconexión', 45, '🧺', false, 10, 'momentos'),
  ('Noche sin pantallas', 'Tiempo de charla y conexión', 30, '🕯️', false, 11, 'momentos'),
  ('Maratón de episodios a elección', 'Vos elegís la serie y el ritmo', 45, '📺', true, 12, 'momentos'),

  ('Vale por no lavar los platos', 'Hoy te salvas de esa tarea', 60, '🍽️', true, 13, 'libertades'),
  ('Vale por elegir la peli', 'Vos elegís qué ver', 30, '🎥', false, 14, 'libertades'),
  ('Vale por elegir la serie una semana', 'Tu serie, tus reglas por 7 días', 70, '📺', true, 15, 'libertades'),
  ('Vale por decidir el plan del finde', 'Vos elegís el plan principal', 80, '🗓️', false, 16, 'libertades'),
  ('Vale por no hacer una tarea puntual', 'Elegís una tarea para delegar', 70, '✅', true, 17, 'libertades'),
  ('Vale por “sí a cualquier plan”', 'Hoy tu idea se cumple', 90, '🙌', true, 18, 'libertades'),

  ('Cena afuera', 'Salida a cenar a un lugar especial', 140, '🍝', true, 19, 'experiencias'),
  ('Cita planeada completa', 'Plan completo organizado de principio a fin', 180, '✨', true, 20, 'experiencias'),
  ('Día libre de tareas', 'Cero obligaciones por todo el día', 200, '🏠', true, 21, 'experiencias')
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
