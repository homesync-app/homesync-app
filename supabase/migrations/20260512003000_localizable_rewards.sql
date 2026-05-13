-- Make system rewards localizable without changing user-authored custom rewards.

ALTER TABLE public.reward_templates
  ADD COLUMN IF NOT EXISTS translation_key text,
  ADD COLUMN IF NOT EXISTS description_key text,
  ADD COLUMN IF NOT EXISTS category_key text;

ALTER TABLE public.rewards
  ADD COLUMN IF NOT EXISTS source_template_id uuid,
  ADD COLUMN IF NOT EXISTS title_key text,
  ADD COLUMN IF NOT EXISTS description_key text,
  ADD COLUMN IF NOT EXISTS category_key text;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'rewards_source_template_id_fkey'
      AND conrelid = 'public.rewards'::regclass
  ) THEN
    ALTER TABLE public.rewards
      ADD CONSTRAINT rewards_source_template_id_fkey
      FOREIGN KEY (source_template_id)
      REFERENCES public.reward_templates(id)
      ON DELETE SET NULL;
  END IF;
END $$;

COMMENT ON COLUMN public.reward_templates.translation_key IS
  'ARB key for localizing the system reward title.';
COMMENT ON COLUMN public.reward_templates.description_key IS
  'ARB key for localizing the system reward description.';
COMMENT ON COLUMN public.reward_templates.category_key IS
  'ARB key for localizing the system reward category.';
COMMENT ON COLUMN public.rewards.source_template_id IS
  'Original system reward template. Null for user-authored custom rewards.';
COMMENT ON COLUMN public.rewards.title_key IS
  'ARB key for localizing a system-origin reward title. Null means display rewards.title as custom text.';
COMMENT ON COLUMN public.rewards.description_key IS
  'ARB key for localizing a system-origin reward description. Null means display rewards.description as custom text.';
COMMENT ON COLUMN public.rewards.category_key IS
  'ARB key for localizing a system-origin reward category.';

CREATE OR REPLACE FUNCTION public.reward_normalized_text(p_value text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT regexp_replace(lower(trim(coalesce(p_value, ''))), '\s+', ' ', 'g')
$$;

CREATE OR REPLACE FUNCTION public.reward_title_key_for(p_title text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT CASE public.reward_normalized_text(p_title)
    WHEN 'café o mate preparado' THEN 'rewardTemplateCoffeeMatePrepared'
    WHEN 'cafe o mate preparado' THEN 'rewardTemplateCoffeeMatePrepared'
    WHEN 'mate o café preparado' THEN 'rewardTemplateCoffeeMatePrepared'
    WHEN 'mate o cafe preparado' THEN 'rewardTemplateCoffeeMatePrepared'
    WHEN 'snack sorpresa' THEN 'rewardTemplateSurpriseSnack'
    WHEN 'mini nota romántica' THEN 'rewardTemplateMiniRomanticNote'
    WHEN 'mini nota romantica' THEN 'rewardTemplateMiniRomanticNote'
    WHEN '15 minutos de masajes' THEN 'rewardTemplateMassage15Minutes'
    WHEN 'masaje de 15 minutos' THEN 'rewardTemplateMassage15Minutes'
    WHEN 'helado de tu elección' THEN 'rewardTemplateIceCreamChoice'
    WHEN 'helado de tu eleccion' THEN 'rewardTemplateIceCreamChoice'
    WHEN 'noche de cine en casa' THEN 'rewardTemplateMovieNightHome'
    WHEN 'tarde de gaming' THEN 'rewardTemplateGamingAfternoon'
    WHEN 'noche de juegos de mesa' THEN 'rewardTemplateBoardGameNight'
    WHEN 'cena casera especial' THEN 'rewardTemplateSpecialHomemadeDinner'
    WHEN 'picnic en casa' THEN 'rewardTemplateHomePicnic'
    WHEN 'noche sin pantallas' THEN 'rewardTemplateNoScreensNight'
    WHEN 'maratón de episodios a elección' THEN 'rewardTemplateEpisodeMarathonChoice'
    WHEN 'maraton de episodios a eleccion' THEN 'rewardTemplateEpisodeMarathonChoice'
    WHEN 'vale por no lavar los platos' THEN 'rewardTemplateNoDishesVoucher'
    WHEN 'vale por elegir la peli' THEN 'rewardTemplateChooseMovieVoucher'
    WHEN 'vale por elegir la serie una semana' THEN 'rewardTemplateChooseSeriesWeekVoucher'
    WHEN 'vale por decidir el plan del finde' THEN 'rewardTemplateWeekendPlanVoucher'
    WHEN 'vale por no hacer una tarea puntual' THEN 'rewardTemplateSkipOneChoreVoucher'
    WHEN 'vale por “sí a cualquier plan”' THEN 'rewardTemplateYesToAnyPlanVoucher'
    WHEN 'vale por "sí a cualquier plan"' THEN 'rewardTemplateYesToAnyPlanVoucher'
    WHEN 'vale por “si a cualquier plan”' THEN 'rewardTemplateYesToAnyPlanVoucher'
    WHEN 'cena afuera' THEN 'rewardTemplateDinnerOut'
    WHEN 'cita planeada completa' THEN 'rewardTemplatePlannedDate'
    WHEN 'día libre de tareas' THEN 'rewardTemplateChoreFreeDay'
    WHEN 'dia libre de tareas' THEN 'rewardTemplateChoreFreeDay'
    WHEN '15 minutos extra de pantalla' THEN 'rewardTemplateExtraScreen15Minutes'
    WHEN 'elegir la cena' THEN 'rewardTemplateChooseDinner'
    WHEN 'helado para todos' THEN 'rewardTemplateIceCreamForEveryone'
    WHEN 'juguete o premio pequeno' THEN 'rewardTemplateSmallToyPrize'
    WHEN 'juguete o premio pequeño' THEN 'rewardTemplateSmallToyPrize'
    WHEN 'noche de peli' THEN 'rewardTemplateFamilyMovieNight'
    WHEN 'pedir comida' THEN 'rewardTemplateOrderTakeout'
    WHEN 'plan del fin de semana' THEN 'rewardTemplateWeekendFamilyPlan'
    WHEN 'postre especial' THEN 'rewardTemplateSpecialDessert'
    ELSE NULL
  END
$$;

CREATE OR REPLACE FUNCTION public.reward_description_key_for(p_description text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT CASE public.reward_normalized_text(p_description)
    WHEN 'una pausa rica preparada con cariño' THEN 'rewardTemplateCoffeeMatePreparedDescription'
    WHEN 'un antojo inesperado para alegrar el día' THEN 'rewardTemplateSurpriseSnackDescription'
    WHEN 'un mensaje corto para sonreír' THEN 'rewardTemplateMiniRomanticNoteDescription'
    WHEN 'masaje relajante de 15 minutos' THEN 'rewardTemplateMassage15MinutesDescription'
    WHEN 'un postre frío para celebrar' THEN 'rewardTemplateIceCreamChoiceDescription'
    WHEN 'película y ambiente especial en casa' THEN 'rewardTemplateMovieNightHomeDescription'
    WHEN 'partida juntos con snacks incluidos' THEN 'rewardTemplateGamingAfternoonDescription'
    WHEN 'tiempo de juego y risas' THEN 'rewardTemplateBoardGameNightDescription'
    WHEN 'tu comida favorita hecha en casa' THEN 'rewardTemplateSpecialHomemadeDinnerDescription'
    WHEN 'manta, algo rico y desconexión' THEN 'rewardTemplateHomePicnicDescription'
    WHEN 'tiempo de charla y conexión' THEN 'rewardTemplateNoScreensNightDescription'
    WHEN 'vos elegís la serie y el ritmo' THEN 'rewardTemplateEpisodeMarathonChoiceDescription'
    WHEN 'hoy te salvas de esa tarea' THEN 'rewardTemplateNoDishesVoucherDescription'
    WHEN 'vos elegís qué ver' THEN 'rewardTemplateChooseMovieVoucherDescription'
    WHEN 'tu serie, tus reglas por 7 días' THEN 'rewardTemplateChooseSeriesWeekVoucherDescription'
    WHEN 'vos elegís el plan principal' THEN 'rewardTemplateWeekendPlanVoucherDescription'
    WHEN 'elegís una tarea para delegar' THEN 'rewardTemplateSkipOneChoreVoucherDescription'
    WHEN 'hoy tu idea se cumple' THEN 'rewardTemplateYesToAnyPlanVoucherDescription'
    WHEN 'salida a cenar a un lugar especial' THEN 'rewardTemplateDinnerOutDescription'
    WHEN 'plan completo organizado de principio a fin' THEN 'rewardTemplatePlannedDateDescription'
    WHEN 'cero obligaciones por todo el día' THEN 'rewardTemplateChoreFreeDayDescription'
    WHEN 'un ratito mas para jugar o mirar algo.' THEN 'rewardTemplateExtraScreen15MinutesDescription'
    WHEN 'decidir el menu de una noche en casa.' THEN 'rewardTemplateChooseDinnerDescription'
    WHEN 'salida o pedido de helado familiar.' THEN 'rewardTemplateIceCreamForEveryoneDescription'
    WHEN 'canje por algo simple elegido con un adulto.' THEN 'rewardTemplateSmallToyPrizeDescription'
    WHEN 'plan simple para disfrutar todos juntos.' THEN 'rewardTemplateFamilyMovieNightDescription'
    WHEN 'una noche sin cocinar para toda la familia.' THEN 'rewardTemplateOrderTakeoutDescription'
    WHEN 'elegir una salida o actividad para hacer juntos.' THEN 'rewardTemplateWeekendFamilyPlanDescription'
    WHEN 'elegir un postre favorito para despues de cenar.' THEN 'rewardTemplateSpecialDessertDescription'
    ELSE NULL
  END
$$;

CREATE OR REPLACE FUNCTION public.reward_category_key_for(p_category text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT CASE public.reward_normalized_text(p_category)
    WHEN 'mimos' THEN 'rewardCategoryTreats'
    WHEN 'momentos' THEN 'rewardCategoryMoments'
    WHEN 'momentos juntos' THEN 'rewardCategoryMoments'
    WHEN 'libertades' THEN 'rewardCategoryPerks'
    WHEN 'experiencias' THEN 'rewardCategoryExperiences'
    WHEN 'experiencias más grandes' THEN 'rewardCategoryExperiences'
    WHEN 'experiencias mas grandes' THEN 'rewardCategoryExperiences'
    WHEN 'familia' THEN 'rewardCategoryFamily'
    WHEN 'otros' THEN 'rewardCategoryOther'
    ELSE NULL
  END
$$;

UPDATE public.reward_templates
SET translation_key = public.reward_title_key_for(title),
    description_key = public.reward_description_key_for(description),
    category_key = public.reward_category_key_for(category)
WHERE translation_key IS NULL
   OR description_key IS NULL
   OR category_key IS NULL;

UPDATE public.rewards r
SET source_template_id = rt.id
FROM public.reward_templates rt
WHERE r.source_template_id IS NULL
  AND public.reward_normalized_text(r.title) = public.reward_normalized_text(rt.title)
  AND (r.cost = rt.cost OR r.cost IS NULL OR rt.cost IS NULL);

UPDATE public.rewards
SET title_key = public.reward_title_key_for(title),
    description_key = public.reward_description_key_for(description),
    category_key = public.reward_category_key_for(category)
WHERE title_key IS NULL
   OR description_key IS NULL
   OR category_key IS NULL;

UPDATE public.rewards r
SET title_key = coalesce(r.title_key, rt.translation_key),
    description_key = coalesce(r.description_key, rt.description_key),
    category_key = coalesce(r.category_key, rt.category_key)
FROM public.reward_templates rt
WHERE r.source_template_id = rt.id;

CREATE OR REPLACE FUNCTION public.set_reward_localization_keys()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.source_template_id IS NOT NULL THEN
    SELECT
      coalesce(NEW.title_key, rt.translation_key),
      coalesce(NEW.description_key, rt.description_key),
      coalesce(NEW.category_key, rt.category_key)
    INTO NEW.title_key, NEW.description_key, NEW.category_key
    FROM public.reward_templates rt
    WHERE rt.id = NEW.source_template_id;
  END IF;

  IF NEW.title_key IS NULL THEN
    NEW.title_key := public.reward_title_key_for(NEW.title);
  END IF;
  IF NEW.description_key IS NULL THEN
    NEW.description_key := public.reward_description_key_for(NEW.description);
  END IF;
  IF NEW.category_key IS NULL THEN
    NEW.category_key := public.reward_category_key_for(NEW.category);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS rewards_set_localization_keys ON public.rewards;
CREATE TRIGGER rewards_set_localization_keys
BEFORE INSERT OR UPDATE OF source_template_id, title, description, category
ON public.rewards
FOR EACH ROW
EXECUTE FUNCTION public.set_reward_localization_keys();

CREATE OR REPLACE FUNCTION public.clone_reward_templates(
  p_user_id uuid,
  p_template_ids uuid[] DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_household_id uuid;
  v_cloned_count integer := 0;
  v_template record;
BEGIN
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

  IF EXISTS (
    SELECT 1 FROM public.rewards WHERE household_id = v_household_id
  ) THEN
    RETURN 0;
  END IF;

  IF p_template_ids IS NULL THEN
    FOR v_template IN SELECT * FROM public.reward_templates ORDER BY sort_order
    LOOP
      INSERT INTO public.rewards (
        household_id,
        source_template_id,
        title,
        title_key,
        description,
        description_key,
        cost,
        icon,
        category,
        category_key,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.id,
        v_template.title,
        v_template.translation_key,
        v_template.description,
        v_template.description_key,
        v_template.cost,
        v_template.icon,
        v_template.category,
        v_template.category_key,
        p_user_id,
        true
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  ELSE
    FOR v_template IN
      SELECT * FROM public.reward_templates
      WHERE id = ANY(p_template_ids)
      ORDER BY sort_order
    LOOP
      INSERT INTO public.rewards (
        household_id,
        source_template_id,
        title,
        title_key,
        description,
        description_key,
        cost,
        icon,
        category,
        category_key,
        created_by,
        is_approved
      ) VALUES (
        v_household_id,
        v_template.id,
        v_template.title,
        v_template.translation_key,
        v_template.description,
        v_template.description_key,
        v_template.cost,
        v_template.icon,
        v_template.category,
        v_template.category_key,
        p_user_id,
        true
      );
      v_cloned_count := v_cloned_count + 1;
    END LOOP;
  END IF;

  RETURN v_cloned_count;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.clone_reward_templates(uuid, uuid[]) FROM anon, public;
GRANT EXECUTE ON FUNCTION public.clone_reward_templates(uuid, uuid[]) TO authenticated;
