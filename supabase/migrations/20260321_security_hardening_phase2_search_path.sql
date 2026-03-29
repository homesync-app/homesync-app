-- Security hardening phase 2
-- Set search_path on all public functions that still have mutable search_path.

DO $$
DECLARE
  fn RECORD;
BEGIN
  FOR fn IN
    SELECT p.oid::regprocedure::text AS signature
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND coalesce(array_to_string(p.proconfig, ','), '') NOT LIKE '%search_path=%'
  LOOP
    EXECUTE format('ALTER FUNCTION %s SET search_path = public;', fn.signature);
  END LOOP;
END $$;
