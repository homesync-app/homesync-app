-- Reconstructed from remote migration history (version 20260221163538).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Enable Write access for Admin on Category and Task Template tables
-- Note: In a production environment, we would restrict this to a specific 'admin' role or user.
-- For now, we enable it for all authenticated users to allow development of the Admin Portal.

-- CATEGORIES
DROP POLICY IF EXISTS "Categories are readable by all" ON public.categories;
CREATE POLICY "Categories are CRUD for all"
  ON public.categories FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- TASK TEMPLATES
DROP POLICY IF EXISTS "Templates are readable by all" ON public.task_templates;
CREATE POLICY "Templates are CRUD for all"
  ON public.task_templates FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
;