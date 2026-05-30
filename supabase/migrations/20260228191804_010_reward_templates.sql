-- Reconstructed from remote migration history (version 20260228191804).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

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
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'reward_templates' 
        AND policyname = 'Reward Templates are readable by all'
    ) THEN
        CREATE POLICY "Reward Templates are readable by all"
          ON public.reward_templates FOR SELECT
          TO authenticated
          USING (true);
    END IF;
END
$$;

-- Insert reward templates
INSERT INTO public.reward_templates (title, description, cost, icon, is_popular, sort_order) VALUES
  ('Helado', 'Una salida por helado', 15, 'Â­Æ’Ã¬Âª', true, 1),
  ('Noche de peli', 'Elige la pelâ”œÂ¡cula de hoy', 20, 'Â­Æ’Ã„Â¼', true, 2),
  ('Masaje de 15 min', 'Masaje relajante', 30, 'Â­Æ’Ã†Ã¥', true, 3),
  ('Desayuno en la cama', 'Desayuno preparado y servido en cama', 50, 'Â­Æ’Ã‘Ã—', false, 4),
  ('Cena especial', 'Preparar la cena favorita', 40, 'Â­Æ’Ã¬Â¢Â´Â©Ã…', false, 5),
  ('Exento de una tarea', 'Puede saltarse una tarea del hogar', 25, 'Â­Æ’Ã„Â½', true, 6)
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
;