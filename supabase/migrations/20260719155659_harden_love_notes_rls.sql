-- love_notes: dos huecos de integridad detectados en el analisis del dashboard.
-- 1) El INSERT no validaba que to_user_id fuera miembro del hogar de la nota
--    (se podia dirigir una nota a un usuario de otro hogar).
-- 2) El UPDATE del destinatario no restringia columnas (podia editar content).
--    Se resuelve con column-level grant: solo is_read es actualizable por
--    authenticated; service_role no se toca.
-- De paso, las tres politicas quedan scopeadas TO authenticated (eran public;
-- anon no tenia acceso real porque current_app_user_id() le es EXECUTE-denied).
-- Smoke SQL 2026-07-19 (rollback): insert a partner OK + destinatario marca
-- is_read OK; insert cross-household => 42501; update de content => 42501.
-- Aplicada a prod via MCP el 2026-07-19.

drop policy "household members insert love notes" on public.love_notes;
create policy "household members insert love notes" on public.love_notes
  for insert to authenticated
  with check (
    from_user_id = current_app_user_id()
    and household_id in (
      select hm.household_id from household_members hm
      where hm.user_id = current_app_user_id()
    )
    and exists (
      select 1 from household_members hm2
      where hm2.household_id = love_notes.household_id
        and hm2.user_id = love_notes.to_user_id
    )
  );

drop policy "household members read love notes" on public.love_notes;
create policy "household members read love notes" on public.love_notes
  for select to authenticated
  using (
    household_id in (
      select hm.household_id from household_members hm
      where hm.user_id = current_app_user_id()
    )
  );

drop policy "recipient can mark as read" on public.love_notes;
create policy "recipient can mark as read" on public.love_notes
  for update to authenticated
  using (to_user_id = current_app_user_id())
  with check (to_user_id = current_app_user_id());

revoke update on public.love_notes from authenticated, anon;
grant update (is_read) on public.love_notes to authenticated;
