-- ============================================
-- REWARD TEMPLATES SYNC (ALIGN WITH CURRENT STORE)
-- ============================================

-- 1) Replace templates with the new curated list
DELETE FROM public.reward_templates;

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

-- 2) Backfill rewards for each household without touching special events
-- Insert only missing rewards by title to avoid duplicates.
WITH households AS (
  SELECT household_id, MIN(user_id) AS owner_id
  FROM public.household_members
  GROUP BY household_id
)
INSERT INTO public.rewards (household_id, title, description, cost, icon, created_by, is_approved)
SELECT h.household_id, t.title, t.description, t.cost, t.icon, h.owner_id, true
FROM households h
CROSS JOIN public.reward_templates t
WHERE NOT EXISTS (
  SELECT 1
  FROM public.rewards r
  WHERE r.household_id = h.household_id
    AND r.title = t.title
);
