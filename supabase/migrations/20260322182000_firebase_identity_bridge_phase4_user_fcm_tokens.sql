alter table public.user_fcm_tokens
  drop constraint if exists user_fcm_tokens_user_id_fkey;

alter table public.user_fcm_tokens
  add constraint user_fcm_tokens_user_id_fkey
  foreign key (user_id)
  references public.users(id)
  on delete cascade;

drop policy if exists "Users can manage their own tokens" on public.user_fcm_tokens;
create policy "Users can manage their own tokens"
on public.user_fcm_tokens
for all
using (user_id = public.current_app_user_id())
with check (user_id = public.current_app_user_id());
