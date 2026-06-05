-- Teen finances — Parent Mode toggle for the allowance ("mesada") feature.
-- OFF by default. Only meaningful for family households with active premium;
-- the client gates the UI via allowanceEnabledProvider (family + premium + this
-- flag). See docs/TEEN_FINANCES_SPEC.md.

ALTER TABLE public.households
  ADD COLUMN IF NOT EXISTS allowance_enabled BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN public.households.allowance_enabled IS
  'Parent Mode: enables adult→teen allowance transfers (mesada). Off by default; premium + family gated client-side.';
