-- Reconstructed from remote migration history (version 20260418192854).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


-- Backfill empty full_name with email prefix (part before @)
update public.users
set full_name = split_part(email, '@', 1),
    updated_at = now()
where full_name is null or trim(full_name) = '';
;