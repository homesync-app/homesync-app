-- Reconstructed from remote migration history (version 20260317161134).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Clear and reset templates
DELETE FROM public.reward_templates;

-- Insert templates
INSERT INTO public.reward_templates (title, description, cost, icon, is_popular, sort_order, category) VALUES
  ('Cafâ”œÂ® o mate preparado', 'Una pausa rica preparada con cariâ”œâ–’o', 20, 'Ã”Ã¿Ã²', true, 1, 'mimos'),
  ('Snack sorpresa', 'Un antojo inesperado para alegrar el dâ”œÂ¡a', 15, 'Â­Æ’Ã¬Â¬', true, 2, 'mimos'),
  ('Mini nota româ”œÃ­ntica', 'Un mensaje corto para sonreâ”œÂ¡r', 10, 'Â­Æ’Ã†Ã®', false, 3, 'mimos'),
  ('15 minutos de masajes', 'Masaje relajante de 15 minutos', 40, 'Â­Æ’Ã†Ã¥', true, 4, 'mimos'),
  ('Helado de tu elecciâ”œâ”‚n', 'Un postre frâ”œÂ¡o para celebrar', 15, 'Â­Æ’Ã¬Âª', true, 5, 'mimos'),
  ('Noche de cine en casa', 'Pelâ”œÂ¡cula y ambiente especial en casa', 35, 'Â­Æ’Ã„Â¼', true, 6, 'momentos juntos'),
  ('Tarde de gaming', 'Partida juntos con snacks incluidos', 35, 'Â­Æ’Ã„Â«', true, 7, 'momentos juntos'),
  ('Noche de juegos de mesa', 'Tiempo de juego y risas', 35, 'Â­Æ’Ã„â–“', false, 8, 'momentos juntos'),
  ('Cena casera especial', 'Tu comida favorita hecha en casa', 60, 'Â­Æ’Ã¬Â¢Â´Â©Ã…', true, 9, 'momentos juntos'),
  ('Picnic en casa', 'Manta, algo rico y desconexiâ”œâ”‚n', 45, 'Â­Æ’Âºâ•‘', false, 10, 'momentos juntos'),
  ('Noche sin pantallas', 'Tiempo de charla y conexiâ”œâ”‚n', 30, 'Â­Æ’Ã²Â»Â´Â©Ã…', false, 11, 'momentos juntos'),
  ('Maratâ”œâ”‚n de episodios a elecciâ”œâ”‚n', 'Vos elegâ”œÂ¡s la serie y el ritmo', 45, 'Â­Æ’Ã´â•‘', true, 12, 'momentos juntos'),
  ('Vale por no lavar los platos', 'Hoy te salvas de esa tarea', 60, 'Â­Æ’Ã¬Â¢Â´Â©Ã…', true, 13, 'libertades'),
  ('Vale por elegir la peli', 'Vos elegâ”œÂ¡s quâ”œÂ® ver', 30, 'Â­Æ’Ã„Ã‘', false, 14, 'libertades'),
  ('Vale por elegir la serie una semana', 'Tu serie, tus reglas por 7 dâ”œÂ¡as', 70, 'Â­Æ’Ã´â•‘', true, 15, 'libertades'),
  ('Vale por decidir el plan del finde', 'Vos elegâ”œÂ¡s el plan principal', 80, 'Â­Æ’Ã¹Ã´Â´Â©Ã…', false, 16, 'libertades'),
  ('Vale por no hacer una tarea puntual', 'Elegâ”œÂ¡s una tarea para delegar', 70, 'Ã”Â£Ã ', true, 17, 'libertades'),
  ('Vale por Ã”Ã‡Â£sâ”œÂ¡ a cualquier planÃ”Ã‡Ã˜', 'Hoy tu idea se cumple', 90, 'Â­Æ’Ã–Ã®', true, 18, 'libertades'),
  ('Cena afuera', 'Salida a cenar a un lugar especial', 140, 'Â­Æ’Ã¬Ã˜', true, 19, 'experiencias mâ”œÃ­s grandes'),
  ('Cita planeada completa', 'Plan completo organizado de principio a fin', 180, 'Ã”Â£Â¿', true, 20, 'experiencias mâ”œÃ­s grandes'),
  ('Dâ”œÂ¡a libre de tareas', 'Cero obligaciones por todo el dâ”œÂ¡a', 200, 'Â­Æ’Ã…Ã¡', true, 21, 'experiencias mâ”œÃ­s grandes');

-- Update existing rewards
UPDATE public.rewards r
SET category = t.category,
    cost = t.cost,
    icon = t.icon,
    description = t.description
FROM public.reward_templates t
WHERE r.title = t.title;

-- Use a safer subquery for backfill
INSERT INTO public.rewards (household_id, title, description, cost, icon, created_by, is_approved, category)
SELECT h.household_id, t.title, t.description, t.cost, t.icon, 
       (SELECT user_id FROM public.household_members m WHERE m.household_id = h.household_id LIMIT 1), 
       true, t.category
FROM (SELECT DISTINCT household_id FROM public.household_members) h
CROSS JOIN public.reward_templates t
WHERE NOT EXISTS (
  SELECT 1
  FROM public.rewards r
  WHERE r.household_id = h.household_id
    AND r.title = t.title
);
;