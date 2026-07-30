-- Reconstructed from remote migration history (version 20260218114103).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

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
  ('cleaning', 'Limpieza', 'Â­Æ’Âºâ•£', '#3B82F6', 1),
  ('kitchen', 'Cocina', 'Â­Æ’Ã¬Â¢Â´Â©Ã…', '#F59E0B', 2),
  ('bedroom', 'Dormitorio', 'Â­Æ’Ã¸Ã…Â´Â©Ã…', '#8B5CF6', 3),
  ('bathroom', 'Baâ”œâ–’o', 'Â­Æ’Ãœâ”', '#06B6D4', 4),
  ('general', 'General', 'Â­Æ’Ã…Ã¡', '#10B981', 5),
  ('pets', 'Mascotas', 'Â­Æ’Ã‰Â¥', '#EC4899', 6),
  ('outdoor', 'Exterior', 'Â­Æ’Ã®â”', '#84CC16', 7)
ON CONFLICT (id) DO NOTHING;

-- Insert task templates
-- CLEANING (Limpieza)
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Barrer el piso', 'cleaning', 'easy', 5, 3, 'Â­Æ’Âºâ•£', true, 1),
  ('Trapear el piso', 'cleaning', 'medium', 10, 5, 'Â­Æ’ÂºÂ¢', true, 2),
  ('Aspirar la casa', 'cleaning', 'medium', 10, 5, 'Â­Æ’Ã±Ã»', false, 3),
  ('Limpiar ventanas', 'cleaning', 'hard', 20, 10, 'Â­Æ’Â¬Æ’', false, 4),
  ('Sacudir muebles', 'cleaning', 'easy', 5, 3, 'Â­Æ’Â¬Ã¦', false, 5),
  ('Limpiar espejos', 'cleaning', 'easy', 5, 3, 'Â­Æ’Â¬Ã—', false, 6),
  ('Limpiar polvo', 'cleaning', 'easy', 5, 3, 'Ã”Â£Â¿', true, 7),
  ('Organizar la sala', 'cleaning', 'medium', 10, 5, 'Â­Æ’Ã¸Ã¯Â´Â©Ã…', false, 8)
ON CONFLICT DO NOTHING;

-- KITCHEN (Cocina)
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Lavar los platos', 'kitchen', 'easy', 5, 3, 'Â­Æ’Ã¬Â¢Â´Â©Ã…', true, 1),
  ('Cocinar almuerzo', 'kitchen', 'hard', 20, 10, 'Â­Æ’Ã¦Â¿Ã”Ã‡Ã¬Â­Æ’Ã¬â”‚', true, 2),
  ('Cocinar cena', 'kitchen', 'hard', 20, 10, 'Â­Æ’Ã¬â”‚', false, 3),
  ('Limpiar la cocina', 'kitchen', 'medium', 10, 5, 'Â­Æ’ÂºÂ¢', true, 4),
  ('Hacer la compra', 'kitchen', 'medium', 10, 5, 'Â­Æ’Ã¸Ã†', true, 5),
  ('Guardar las compras', 'kitchen', 'easy', 5, 3, 'Â­Æ’Ã´Âª', false, 6),
  ('Organizar la despensa', 'kitchen', 'medium', 10, 5, 'Â­Æ’Ã‘Â½', false, 7),
  ('Limpiar el refrigerador', 'kitchen', 'medium', 10, 5, 'Â­Æ’ÂºÃ¨', false, 8)
ON CONFLICT DO NOTHING;

-- BEDROOM (Dormitorio)
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Hacer la cama', 'bedroom', 'easy', 5, 3, 'Â­Æ’Ã¸Ã…Â´Â©Ã…', true, 1),
  ('Cambiar sâ”œÃ­banas', 'bedroom', 'medium', 10, 5, 'Â­Æ’Âºâ•‘', false, 2),
  ('Ordenar el cuarto', 'bedroom', 'medium', 10, 5, 'Â­Æ’Âºâ•£', true, 3),
  ('Organizar armario', 'bedroom', 'hard', 20, 10, 'Â­Æ’Ã¦Ã²', false, 4),
  ('Ordenar la ropa', 'bedroom', 'medium', 10, 5, 'Â­Æ’Ã¦Ã¶', false, 5),
  ('Limpiar bajo la cama', 'bedroom', 'medium', 10, 5, 'Â­Æ’Âºâ•£', false, 6)
ON CONFLICT DO NOTHING;

-- BATHROOM (Baâ”œâ–’o)
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Limpiar el baâ”œâ–’o', 'bathroom', 'hard', 20, 10, 'Â­Æ’Ãœâ”', true, 1),
  ('Limpiar el inodoro', 'bathroom', 'medium', 10, 5, 'Â­Æ’ÃœÂ¢', false, 2),
  ('Cambiar toallas', 'bathroom', 'easy', 5, 3, 'Â­Æ’Âºâ•‘', false, 3),
  ('Limpiar espejo baâ”œâ–’o', 'bathroom', 'easy', 5, 3, 'Â­Æ’Â¬Ã—', false, 4),
  ('Desinfectar baâ”œâ–’o', 'bathroom', 'medium', 10, 5, 'Â­Æ’Âºâ”¤', false, 5)
ON CONFLICT DO NOTHING;

-- GENERAL
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Sacar la basura', 'general', 'easy', 5, 3, 'Â­Æ’Ã¹Ã¦Â´Â©Ã…', true, 1),
  ('Regar las plantas', 'general', 'easy', 5, 3, 'Â­Æ’Ã®â”', true, 2),
  ('Recoger correos', 'general', 'easy', 5, 3, 'Â­Æ’Ã´Â¼', false, 3),
  ('Organizar entrada', 'general', 'medium', 10, 5, 'Â­Æ’ÃœÂ¬', false, 4),
  ('Lavar ropa', 'general', 'medium', 10, 5, 'Â­Æ’Âºâ•‘', true, 5),
  ('Tender la ropa', 'general', 'medium', 10, 5, 'Â­Æ’Ã¦Ã²', false, 6),
  ('Planchar ropa', 'general', 'medium', 10, 5, 'Ã”ÃœÃ­', false, 7),
  ('Hacer la cama invitados', 'general', 'medium', 10, 5, 'Â­Æ’Ã¸Ã…Â´Â©Ã…', false, 8)
ON CONFLICT DO NOTHING;

-- PETS (Mascotas)
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Alimentar mascotas', 'pets', 'easy', 5, 3, 'Â­Æ’Ã‰Â¥', true, 1),
  ('Pasear al perro', 'pets', 'medium', 10, 5, 'Â­Æ’Ã‰Ã²', true, 2),
  ('Limpiar arenero', 'pets', 'medium', 10, 5, 'Â­Æ’Ã‰â–’', false, 3),
  ('Dar agua a mascotas', 'pets', 'easy', 5, 3, 'Â­Æ’Ã†Âº', false, 4),
  ('Cepillar mascota', 'pets', 'easy', 5, 3, 'Ã”Â£Â¿', false, 5),
  ('Limpiar jaula/pecera', 'pets', 'hard', 20, 10, 'Â­Æ’Ã‰Ã¡', false, 6)
ON CONFLICT DO NOTHING;

-- OUTDOOR (Exterior)
INSERT INTO public.task_templates (title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES
  ('Cortar el câ”œÂ®sped', 'outdoor', 'hard', 20, 10, 'Â­Æ’Ã®â”', false, 1),
  ('Regar el jardâ”œÂ¡n', 'outdoor', 'medium', 10, 5, 'Â­Æ’Ã†Âº', false, 2),
  ('Barrer la entrada', 'outdoor', 'easy', 5, 3, 'Â­Æ’Âºâ•£', false, 3),
  ('Limpiar terraza', 'outdoor', 'medium', 10, 5, 'Â­Æ’Ã…Ã¡', false, 4),
  ('Podar plantas', 'outdoor', 'medium', 10, 5, 'Ã”Â£Ã©Â´Â©Ã…', false, 5),
  ('Lavar el coche', 'outdoor', 'medium', 10, 5, 'Â­Æ’ÃœÃ¹', false, 6)
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
