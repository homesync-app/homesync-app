-- ============================================
-- TASK TEMPLATES SYSTEM
-- ============================================

-- Create categories table
CREATE TABLE IF NOT EXISTS public.categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT DEFAULT '#6B7280',
  sort_order INTEGER DEFAULT 0
);

-- Create task_templates table
CREATE TABLE IF NOT EXISTS public.task_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  category_id TEXT NOT NULL REFERENCES public.categories(id),
  difficulty TEXT NOT NULL DEFAULT 'medium',
  xp_reward INTEGER NOT NULL DEFAULT 10,
  coin_reward INTEGER NOT NULL DEFAULT 5,
  icon TEXT,
  is_popular BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies for categories (read-only for all authenticated)
CREATE POLICY "Categories are readable by all"
  ON public.categories FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policies for task_templates (read-only for all authenticated)
CREATE POLICY "Templates are readable by all"
  ON public.task_templates FOR SELECT
  TO authenticated
  USING (true);

-- Insert categories
INSERT INTO public.categories (id, name, icon, color, sort_order) VALUES
  ('cleaning', 'Limpieza', '🧹', '#3B82F6', 1),
  ('kitchen', 'Cocina', '🍽️', '#F59E0B', 2),
  ('bedroom', 'Dormitorio', '🛏️', '#8B5CF6', 3),
  ('bathroom', 'Baño', '🚿', '#06B6D4', 4),
  ('general', 'General', '🏠', '#10B981', 5),
  ('pets', 'Mascotas', '🐾', '#EC4899', 6),
  ('outdoor', 'Exterior', '🌿', '#84CC16', 7)
ON CONFLICT (id) DO NOTHING;

-- Insert task templates
-- CLEANING (Limpieza) - 8 tasks
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Barrer el piso', 'cleaning', 'easy', 5, 3, '🧹', true, 1),
  ('Trapear el piso', 'cleaning', 'medium', 10, 5, '🧽', true, 2),
  ('Aspirar la casa', 'cleaning', 'medium', 10, 5, '🤖', false, 3),
  ('Limpiar ventanas', 'cleaning', 'hard', 20, 10, '🪟', false, 4),
  ('Sacudir muebles', 'cleaning', 'easy', 5, 3, '🪑', false, 5),
  ('Limpiar espejos', 'cleaning', 'easy', 5, 3, '🪞', false, 6),
  ('Limpiar polvo', 'cleaning', 'easy', 5, 3, '✨', true, 7),
  ('Organizar la sala', 'cleaning', 'medium', 10, 5, '🛋️', false, 8)
ON CONFLICT DO NOTHING;

-- KITCHEN (Cocina) - 8 tasks
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Lavar los platos', 'kitchen', 'easy', 5, 3, '🍽️', true, 1),
  ('Cocinar almuerzo', 'kitchen', 'hard', 20, 10, '👨‍🍳', true, 2),
  ('Cocinar cena', 'kitchen', 'hard', 20, 10, '🍳', false, 3),
  ('Limpiar la cocina', 'kitchen', 'medium', 10, 5, '🧽', true, 4),
  ('Hacer la compra', 'kitchen', 'medium', 10, 5, '🛒', true, 5),
  ('Guardar las compras', 'kitchen', 'easy', 5, 3, '📦', false, 6),
  ('Organizar la despensa', 'kitchen', 'medium', 10, 5, '🥫', false, 7),
  ('Limpiar el refrigerador', 'kitchen', 'medium', 10, 5, '🧊', false, 8)
ON CONFLICT DO NOTHING;

-- BEDROOM (Dormitorio) - 6 tasks
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Hacer la cama', 'bedroom', 'easy', 5, 3, '🛏️', true, 1),
  ('Cambiar sábanas', 'bedroom', 'medium', 10, 5, '🧺', false, 2),
  ('Ordenar el cuarto', 'bedroom', 'medium', 10, 5, '🧹', true, 3),
  ('Organizar armario', 'bedroom', 'hard', 20, 10, '👕', false, 4),
  ('Ordenar la ropa', 'bedroom', 'medium', 10, 5, '👔', false, 5),
  ('Limpiar bajo la cama', 'bedroom', 'medium', 10, 5, '🧹', false, 6)
ON CONFLICT DO NOTHING;

-- BATHROOM (Baño) - 5 tasks
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Limpiar el baño', 'bathroom', 'hard', 20, 10, '🚿', true, 1),
  ('Limpiar el inodoro', 'bathroom', 'medium', 10, 5, '🚽', false, 2),
  ('Cambiar toallas', 'bathroom', 'easy', 5, 3, '🧺', false, 3),
  ('Limpiar espejo baño', 'bathroom', 'easy', 5, 3, '🪞', false, 4),
  ('Desinfectar baño', 'bathroom', 'medium', 10, 5, '🧴', false, 5)
ON CONFLICT DO NOTHING;

-- GENERAL - 8 tasks
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Sacar la basura', 'general', 'easy', 5, 3, '🗑️', true, 1),
  ('Regar las plantas', 'general', 'easy', 5, 3, '🌿', true, 2),
  ('Recoger correos', 'general', 'easy', 5, 3, '📬', false, 3),
  ('Organizar entrada', 'general', 'medium', 10, 5, '🚪', false, 4),
  ('Lavar ropa', 'general', 'medium', 10, 5, '🧺', true, 5),
  ('Tender la ropa', 'general', 'medium', 10, 5, '👕', false, 6),
  ('Planchar ropa', 'general', 'medium', 10, 5, '⚡', false, 7),
  ('Hacer la cama invitados', 'general', 'medium', 10, 5, '🛏️', false, 8)
ON CONFLICT DO NOTHING;

-- PETS (Mascotas) - 6 tasks
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Alimentar mascotas', 'pets', 'easy', 5, 3, '🐾', true, 1),
  ('Pasear al perro', 'pets', 'medium', 10, 5, '🐕', true, 2),
  ('Limpiar arenero', 'pets', 'medium', 10, 5, '🐱', false, 3),
  ('Dar agua a mascotas', 'pets', 'easy', 5, 3, '💧', false, 4),
  ('Cepillar mascota', 'pets', 'easy', 5, 3, '✨', false, 5),
  ('Limpiar jaula/pecera', 'pets', 'hard', 20, 10, '🐠', false, 6)
ON CONFLICT DO NOTHING;

-- OUTDOOR (Exterior) - 6 tasks
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Cortar el césped', 'outdoor', 'hard', 20, 10, '🌿', false, 1),
  ('Regar el jardín', 'outdoor', 'medium', 10, 5, '💧', false, 2),
  ('Barrer la entrada', 'outdoor', 'easy', 5, 3, '🧹', false, 3),
  ('Limpiar terraza', 'outdoor', 'medium', 10, 5, '🏠', false, 4),
  ('Podar plantas', 'outdoor', 'medium', 10, 5, '✂️', false, 5),
  ('Lavar el coche', 'outdoor', 'medium', 10, 5, '🚗', false, 6)
ON CONFLICT DO NOTHING;

-- ============================================
-- RPC: Clone templates to user tasks
-- ============================================

CREATE OR REPLACE FUNCTION public.clone_task_templates(
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
  -- Get or create household
  SELECT household_id INTO v_household_id
  FROM public.household_members
  WHERE user_id = p_user_id
  LIMIT 1;

  IF v_household_id IS NULL THEN
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

  -- Clone all templates or specific ones
  IF p_template_ids IS NULL THEN
    -- Clone all templates
    FOR v_template IN SELECT * FROM public.task_templates ORDER BY category_id, sort_order
    LOOP
      INSERT INTO public.tasks (
        id,
        household_id,
        created_by_id,
        title,
        category,
        difficulty,
        xp_reward,
        coin_reward,
        status
      ) VALUES (
        gen_random_uuid(),
        v_household_id,
        p_user_id,
        v_template.title,
        v_template.category_id,
        v_template.difficulty,
        v_template.xp_reward,
        v_template.coin_reward,
        'active'
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  ELSE
    -- Clone specific templates
    FOR v_template IN 
      SELECT * FROM public.task_templates 
      WHERE id = ANY(p_template_ids)
      ORDER BY category_id, sort_order
    LOOP
      INSERT INTO public.tasks (
        id,
        household_id,
        created_by_id,
        title,
        category,
        difficulty,
        xp_reward,
        coin_reward,
        status
      ) VALUES (
        gen_random_uuid(),
        v_household_id,
        p_user_id,
        v_template.title,
        v_template.category_id,
        v_template.difficulty,
        v_template.xp_reward,
        v_template.coin_reward,
        'active'
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  END IF;

  RETURN v_cloned_count;
END;
$$;

-- Grant permission
GRANT EXECUTE ON FUNCTION public.clone_task_templates(UUID, UUID[]) TO authenticated;
