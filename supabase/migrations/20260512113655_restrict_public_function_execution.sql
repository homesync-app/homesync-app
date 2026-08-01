-- Reconstructed from remote migration history (version 20260512113655).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

revoke execute on all functions in schema public from anon;
revoke execute on all functions in schema public from public;
grant execute on all functions in schema public to authenticated;

alter default privileges in schema public
  revoke execute on functions from anon;
alter default privileges in schema public
  revoke execute on functions from public;
alter default privileges in schema public
  grant execute on functions to authenticated;
