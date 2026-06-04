-- Tabla + funcion para resolver name_key a partir del nombre libre de un
-- shopping_item. El matching sigue el mismo criterio del admin (homesync_admin
-- src/pages/ShoppingIcons.tsx):
--   1. exact match (full) sobre aliases normalizados
--   2. first-word match (compuestos: "Leche entera" -> "leche")
--   3. first-word singular match (plurales simples: "Papas" -> "papa")
--   4. substring match (alias contenido en el nombre, longitud >= 4)
--
-- La tabla `shopping_catalog_keys` es la fuente de verdad del matching
-- server-side; se puebla con el seed `bg_removal/icons/aliases_seed.json`
-- (ver supabase/scripts/seed_shopping_catalog_keys.js). El cliente admin y
-- la app Flutter usan el mismo set de aliases, asi que un cambio en el seed
-- se refleja en los 3 lados tras correr el script y aplicar la migracion.

-- ============================================================================
-- Tabla
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.shopping_catalog_keys (
  key text PRIMARY KEY,
  es_names text[] NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.shopping_catalog_keys IS
  'Mirror server-side del seed bg_removal/icons/aliases_seed.json. Usado por '
  'public.resolve_shopping_catalog_key() para el backfill de shopping_items.name_key.';

-- RLS: la tabla es de solo lectura para authenticated (matching en runtime
-- via funcion) y escribible solo desde migraciones (service role bypasea RLS).
ALTER TABLE public.shopping_catalog_keys ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS shopping_catalog_keys_select_authenticated
  ON public.shopping_catalog_keys;
CREATE POLICY shopping_catalog_keys_select_authenticated
  ON public.shopping_catalog_keys
  FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================================
-- Funcion: normalize inline (sin extension unaccent para no agregar deps)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.normalize_shopping_name(name text)
RETURNS text
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
  SELECT regexp_replace(
    lower(trim(
      translate(
        translate(
          translate(
            translate(
              translate(
                translate(
                  translate(
                    translate(
                      translate(coalesce(name, ''),
                        'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN'),
                      'äëïöüÄËÏÖÜ', 'aeiouAEIOU'),
                    'âêîôûÂÊÎÔÛ', 'aeiouAEIOU'),
                  'àèìòùÀÈÌÒÙ', 'aeiouAEIOU'),
                'ãẽĩõũÃẼĨÕŨ', 'aeiouAEIOU'),
              'ýÿŷŸ', 'yyyY'),
            'çÇ', 'cC'),
          'ñÑ', 'nN'),
        '¿¡', '?!')
    )),
    '\s+', ' ', 'g'
  );
$$;

COMMENT ON FUNCTION public.normalize_shopping_name(text) IS
  'Normaliza un nombre de producto: lowercase + asciifolding (ES/EU) + trim + '
  'colapsa espacios. Usado por resolve_shopping_catalog_key().';

-- ============================================================================
-- Funcion: resolver key
-- ============================================================================

CREATE OR REPLACE FUNCTION public.resolve_shopping_catalog_key(p_name text)
RETURNS text
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_normalized text;
  v_first_word text;
  v_first_word_singular text;
  v_key text;
  v_word_len int;
BEGIN
  IF p_name IS NULL OR trim(p_name) = '' THEN
    RETURN NULL;
  END IF;

  v_normalized := public.normalize_shopping_name(p_name);
  v_first_word := split_part(v_normalized, ' ', 1);
  v_word_len := length(v_first_word);

  -- Singularizacion conservadora: solo palabras > 4 chars, sin "ss" intermedio.
  -- Evita: "ss" -> "s", palabras de 1-3 chars. Aplica mismo criterio que el
  -- cliente admin.
  v_first_word_singular := v_first_word;
  IF v_word_len > 4 AND right(v_first_word, 2) = 'es' AND v_first_word NOT LIKE '%ss%' THEN
    v_first_word_singular := substring(v_first_word from 1 for v_word_len - 2);
  ELSIF v_word_len > 3 AND right(v_first_word, 1) = 's' AND v_first_word NOT LIKE '%ss%' THEN
    v_first_word_singular := substring(v_first_word from 1 for v_word_len - 1);
  END IF;

  -- 1. Exact full match
  SELECT k.key INTO v_key
  FROM public.shopping_catalog_keys k
  WHERE EXISTS (
    SELECT 1 FROM unnest(k.es_names) AS n
    WHERE public.normalize_shopping_name(n) = v_normalized
  )
  LIMIT 1;
  IF v_key IS NOT NULL THEN RETURN v_key; END IF;

  -- 2. First-word match
  SELECT k.key INTO v_key
  FROM public.shopping_catalog_keys k
  WHERE EXISTS (
    SELECT 1 FROM unnest(k.es_names) AS n
    WHERE public.normalize_shopping_name(n) = v_first_word
  )
  LIMIT 1;
  IF v_key IS NOT NULL THEN RETURN v_key; END IF;

  -- 3. First-word singular match
  IF v_first_word_singular <> v_first_word THEN
    SELECT k.key INTO v_key
    FROM public.shopping_catalog_keys k
    WHERE EXISTS (
      SELECT 1 FROM unnest(k.es_names) AS n
      WHERE public.normalize_shopping_name(n) = v_first_word_singular
    )
    LIMIT 1;
    IF v_key IS NOT NULL THEN RETURN v_key; END IF;
  END IF;

  -- 4. Substring match: el alias mas largo contenido en el nombre.
  --    length(n) >= 4 evita falsos positivos con articulos/preposiciones.
  SELECT k.key INTO v_key
  FROM public.shopping_catalog_keys k
  WHERE EXISTS (
    SELECT 1 FROM unnest(k.es_names) AS n
    WHERE length(n) >= 4
      AND v_normalized LIKE '%' || public.normalize_shopping_name(n) || '%'
  )
  ORDER BY (
    SELECT max(length(public.normalize_shopping_name(n2)))
    FROM unnest(k.es_names) n2
  ) DESC
  LIMIT 1;

  RETURN v_key;
END;
$$;

COMMENT ON FUNCTION public.resolve_shopping_catalog_key(text) IS
  'Resuelve el name_key de un shopping_item a partir del nombre libre. Mismo '
  'algoritmo que el cliente admin: exact -> first-word -> first-word singular '
  '-> substring (longest alias >= 4 chars). SECURITY DEFINER para no exponer '
  'la lectura a RLS de shopping_items cuando se invoca desde un RPC superior.';

-- ============================================================================
-- Grants
-- ============================================================================

REVOKE EXECUTE ON FUNCTION public.resolve_shopping_catalog_key(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.resolve_shopping_catalog_key(text) TO authenticated;
