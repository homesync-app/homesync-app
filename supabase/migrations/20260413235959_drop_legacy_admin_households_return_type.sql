-- The next imported migration adds owner_email to the TABLE return contract.
-- PostgreSQL cannot change OUT parameters through CREATE OR REPLACE.

drop function if exists public.admin_get_all_households();
