-- Registro de accesos a la Edge Function growth-mcp (conector MCP de Muse),
-- para diagnosticar conexiones fallidas. Guarda método, método JSON-RPC,
-- NOMBRES de headers presentes, user agent y estado; nunca valores de headers
-- ni el token. Sin policies: solo la service role (la función) lee y escribe.
CREATE TABLE IF NOT EXISTS public.growth_mcp_access_log (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  http_method text,
  rpc_method text,
  status integer,
  auth_source text,
  header_names text[],
  user_agent text
);

ALTER TABLE public.growth_mcp_access_log ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.growth_mcp_access_log FROM anon, authenticated;

CREATE INDEX IF NOT EXISTS growth_mcp_access_log_created_at_idx
  ON public.growth_mcp_access_log (created_at DESC);
