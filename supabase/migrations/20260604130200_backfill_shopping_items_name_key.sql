-- Backfill de shopping_items.name_key para items con name_key null o cuyo
-- key no existe en el manifest actual (huérfanos, p.ej. "leche_v1",
-- "aceite" hardcodeado en la app, plurales no contemplados por el matcher
-- strict de Flutter, etc.).
--
-- Resuelve el key con la misma logica que el admin:
--   1. exact match contra aliases
--   2. first-word match
--   3. first-word singular match
--   4. substring match (longest alias >= 4 chars)
--
-- Pre-condiciones:
--   - 20260604130000_shopping_catalog_keys_table_and_function.sql aplicado
--   - 20260604130100_seed_shopping_catalog_keys.sql aplicado
--
-- Verificacion post-aplicar (reemplaza COUNT(*) esperado):
--   SELECT
--     count(*) FILTER (WHERE name_key IS NULL) AS still_null,
--     count(*) FILTER (WHERE name_key IS NOT NULL
--                       AND NOT EXISTS (SELECT 1 FROM public.shopping_catalog_keys k
--                                       WHERE k.key = shopping_items.name_key)) AS still_orphan
--   FROM public.shopping_items;
--   -- Esperado: still_null + still_orphan ~ filas sin match posible
--   --          (productos sin icono en catalogo: 'Queso' generico, 'Carne' generico,
--   --           items tipeados a mano que no estan en el seed)

-- Solo toca filas problematicas: name_key null o key no presente en el
-- catalogo. No pisa los keys que ya son validos (importante: si un admin
-- eligio manualmente un key raro, lo respetamos).
UPDATE public.shopping_items
SET name_key = public.resolve_shopping_catalog_key(name)
WHERE name_key IS NULL
   OR NOT EXISTS (
     SELECT 1 FROM public.shopping_catalog_keys k
     WHERE k.key = shopping_items.name_key
   );
