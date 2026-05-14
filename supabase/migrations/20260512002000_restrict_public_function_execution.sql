-- Supabase/Postgres grants EXECUTE on functions to PUBLIC by default, which
-- makes SECURITY DEFINER RPCs callable by the anon role unless explicitly
-- revoked. HomeSync uses authenticated Firebase JWTs for app RPCs, so keep
-- authenticated access explicit and close anonymous execution.

revoke execute on all functions in schema public from anon;
revoke execute on all functions in schema public from public;
grant execute on all functions in schema public to authenticated;

alter default privileges in schema public
  revoke execute on functions from anon;
alter default privileges in schema public
  revoke execute on functions from public;
alter default privileges in schema public
  grant execute on functions to authenticated;
