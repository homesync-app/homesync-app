-- Reconstructed from remote migration history (version 20260313124826).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Add category column to reward_templates and rewards
ALTER TABLE public.reward_templates ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'otros';
ALTER TABLE public.rewards ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'otros';

-- Remove old templates
DELETE FROM public.reward_templates;

-- Insert new templates
INSERT INTO public.reward_templates (title, description, cost, icon, category, sort_order) VALUES
  -- Caricias y gestos (Category: caricias)
  ('Masaje de 15 minutos', 'Un mimo relajante para desconectar', 25, 'Â­Æ’Ã†Ã¥', 'caricias', 1),
  ('Masaje de pies', 'Relajaciâ”œâ”‚n total despuâ”œÂ®s de un dâ”œÂ¡a largo', 20, 'Â­Æ’ÂªÃ‚', 'caricias', 2),
  ('Abrazos largos (5 minutos)', 'Carga de energâ”œÂ¡a con amor', 15, 'Â­Æ’Â½Ã©', 'caricias', 3),
  ('Mate o cafâ”œÂ® preparado', 'Hecho con amor y a tu gusto', 20, 'Ã”Ã¿Ã²', 'caricias', 4),
  ('Desayuno servido', 'Empezar el dâ”œÂ¡a de la mejor manera', 25, 'Â­Æ’Ã‘Ã—', 'caricias', 5),
  ('Mimos extra antes de dormir', 'Un ratito mâ”œÃ­s de ternura', 20, 'Â­Æ’Ã¿â”¤', 'caricias', 6),

  -- Favores cotidianos y Decisiones (Category: favores)
  ('Saltear una tarea domâ”œÂ®stica', 'Hoy te toca descansar a vos', 40, 'Â­Æ’Âºâ•£', 'favores', 7),
  ('Ayuda obligatoria en una tarea', 'Trabajo en equipo para terminar râ”œÃ­pido', 30, 'Â­Æ’Ã±Ã˜', 'favores', 8),
  ('El otro lava los platos hoy', 'Libre de detergente por hoy', 40, 'Â­Æ’Ã¬Â¢Â´Â©Ã…', 'favores', 9),
  ('Dormir 30 minutos mâ”œÃ­s maâ”œâ–’ana', 'Un ratito mâ”œÃ­s de sueâ”œâ–’o sagrado', 35, 'Ã”Ã…â–‘', 'favores', 10),
  ('El otro se encarga de la cocina hoy', 'Menâ”œâ•‘ sorpresa y cocina limpia', 45, 'Â­Æ’Ã¦Â¿Ã”Ã‡Ã¬Â­Æ’Ã¬â”‚', 'favores', 11),
  ('Pelâ”œÂ¡cula de la noche', 'Vos elegâ”œÂ¡s quâ”œÂ® vemos hoy', 20, 'Â­Æ’Ã„Â¼', 'favores', 12),
  ('Cena de hoy', 'Tu antojo es ley esta noche', 30, 'Â­Æ’Ã¬Ã²', 'favores', 13),
  ('Lugar del prâ”œâ”‚ximo delivery', 'Sin discusiones, donde vos quieras', 25, 'Â­Æ’Ã¸Ã', 'favores', 14),
  ('Plan del sâ”œÃ­bado', 'El dâ”œÂ¡a es tuyo, vos mandâ”œÃ­s', 60, 'Â­Æ’Ã´Ã ', 'favores', 15),
  ('Actividad del domingo', 'Relax o aventura, vos decidâ”œÂ¡s', 50, 'Ã”Ã¿Ã‡Â´Â©Ã…', 'favores', 16),

  -- Momentos especiales (Category: momentos)
  ('Salida elegida', 'Una aventura planeada por vos', 80, 'Â­Æ’Ã„Ã­', 'momentos', 17),
  ('Noche especial', 'Cena, velas y momentos inolvidables', 90, 'Â­Æ’Ã²Â»Â´Â©Ã…', 'momentos', 18),
  ('Plan sorpresa', 'Dejâ”œÃ­ que el otro te sorprenda', 100, 'Â­Æ’Ã„Ã¼', 'momentos', 19),
  ('Dâ”œÂ¡a libre de tareas', 'Desconexiâ”œâ”‚n total de las responsabilidades', 120, 'Â­Æ’Ã…Ã»Â´Â©Ã…', 'momentos', 20);

-- Update the clone function to include category
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
        category,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.title,
        v_template.description,
        v_template.cost,
        v_template.icon,
        v_template.category,
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
        category,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.title,
        v_template.description,
        v_template.cost,
        v_template.icon,
        v_template.category,
        p_user_id,
        true
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  END IF;

  RETURN v_cloned_count;
END;
$$;
;