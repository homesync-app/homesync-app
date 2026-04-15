drop policy if exists "household members insert love notes" on public.love_notes;
drop policy if exists "household members read love notes" on public.love_notes;
drop policy if exists "recipient can mark as read" on public.love_notes;

create policy "household members insert love notes"
  on public.love_notes for insert
  with check (
    from_user_id = public.current_app_user_id()
    and household_id in (
      select hm.household_id from public.household_members hm
      where hm.user_id = public.current_app_user_id()
    )
  );

create policy "household members read love notes"
  on public.love_notes for select
  using (
    household_id in (
      select hm.household_id from public.household_members hm
      where hm.user_id = public.current_app_user_id()
    )
  );

create policy "recipient can mark as read"
  on public.love_notes for update
  using (to_user_id = public.current_app_user_id())
  with check (to_user_id = public.current_app_user_id());

drop policy if exists "members can view scan logs" on public.receipt_scan_logs;

create policy "members can view scan logs"
  on public.receipt_scan_logs for select
  using (
    household_id in (
      select hm.household_id from public.household_members hm
      where hm.user_id = public.current_app_user_id()
    )
  );
