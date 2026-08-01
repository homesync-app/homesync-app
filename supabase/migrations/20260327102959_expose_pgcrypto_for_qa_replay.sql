-- The next imported function restricts search_path to public/auth but calls
-- pgcrypto helpers without schema qualification. Expose temporary wrappers so
-- its top-level seed calls can replay; the following shim removes them.

create function public.gen_salt(p_type text)
returns text
language sql
set search_path = ''
as $function$
  select extensions.gen_salt(p_type)
$function$;

create function public.crypt(p_password text, p_salt text)
returns text
language sql
set search_path = ''
as $function$
  select extensions.crypt(p_password, p_salt)
$function$;
