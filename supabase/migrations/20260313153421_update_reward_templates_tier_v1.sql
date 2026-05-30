-- Reconstructed from remote migration history (version 20260313153421).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Truncate and refill reward templates with the new tier-based system requested by the user
TRUNCATE public.reward_templates;

INSERT INTO public.reward_templates (title, description, cost, icon, category, sort_order)
VALUES
  -- Â­Æ’Æ’Ã³ Caricias y gestos (15Ã”Ã‡Ã´30 coins)
  ('Masaje de 15 minutos', 'Un mimo relajante para desconectar', 25, 'Â­Æ’Ã†Ã¥', 'caricias', 1),
  ('Masaje de pies', 'Relajaciâ”œâ”‚n total despuâ”œÂ®s de un dâ”œÂ¡a largo', 20, 'Â­Æ’ÂªÃ‚', 'caricias', 2),
  ('Mate o cafâ”œÂ® preparado', 'Hecho con amor y a tu gusto', 20, 'Ã”Ã¿Ã²', 'caricias', 3),
  ('Desayuno servido', 'Empezar el dâ”œÂ¡a de la mejor manera', 30, 'Â­Æ’Ã‘Ã—', 'caricias', 4),

  -- Â­Æ’Ã¶Ã Tiempo y Ocio (40Ã”Ã‡Ã´100 coins)
  ('Noche de cine', 'Tâ”œâ•‘ eliges la pelâ”œÂ¡cula hoy', 40, 'Â­Æ’Ã„Â¼', 'ocio', 5),
  ('Cena favorita', 'Tu antojo es ley esta noche', 50, 'Â­Æ’Ã¬Ã²', 'ocio', 6),
  ('Tarde de gaming', 'Un rato de vicio sin culpas', 45, 'Â­Æ’Ã„Â«', 'ocio', 7),
  ('Vale por un "Sâ”œÂ¡" a cualquier plan', 'El comodâ”œÂ¡n definitivo para una salida', 100, 'Â­Æ’Ã„Æ’Â´Â©Ã…', 'ocio', 8),

  -- Â­Æ’Ã¶â”¤ Comodidades (50Ã”Ã‡Ã´150 coins)
  ('Vale por no lavar los platos', 'Libre de detergente por esta vez', 50, 'Â­Æ’Ã¬Â¢Â´Â©Ã…', 'comodidades', 9),
  ('Vale por no limpiar el baâ”œâ–’o', 'Alguien mâ”œÃ­s se encarga hoy', 60, 'Â­Æ’Âºâ•', 'comodidades', 10),
  ('Dâ”œÂ¡a libre de tareas', 'Desconexiâ”œâ”‚n total de las responsabilidades', 120, 'Â­Æ’Ã…Ã»Â´Â©Ã…', 'comodidades', 11);
;