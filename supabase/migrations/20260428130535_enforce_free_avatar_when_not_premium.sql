-- Reconstructed from remote migration history (version 20260428130535).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

create or replace function public.enforce_free_avatar_when_not_premium()
returns trigger
language plpgsql
as $$
begin
  if coalesce(new.is_premium, false) = false
    and new.avatar_url is not null
    and (
      new.avatar_url like 'premium://%'
      or new.avatar_url like 'assets/images/custom_avatars/%'
      or new.avatar_url like '%/storage/v1/object/public/custom-avatars/%'
    )
  then
    new.avatar_url := 'Â­Æ’Ã‰â–’';
  end if;

  return new;
end;
$$;

drop trigger if exists enforce_free_avatar_when_not_premium_trigger on public.users;

create trigger enforce_free_avatar_when_not_premium_trigger
before insert or update of is_premium, avatar_url on public.users
for each row
execute function public.enforce_free_avatar_when_not_premium();

update public.users
set avatar_url = 'Â­Æ’Ã‰â–’'
where coalesce(is_premium, false) = false
  and avatar_url is not null
  and (
    avatar_url like 'premium://%'
    or avatar_url like 'assets/images/custom_avatars/%'
    or avatar_url like '%/storage/v1/object/public/custom-avatars/%'
  );
