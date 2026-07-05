-- 1) qa_admin_get_household_members tenía EXECUTE para PUBLIC (incluye anon).
-- Es una función de QA-admin (con guardia qa_admin_require_access interna),
-- pero no debe ser ni invocable sin login. Alinear con sus hermanas
-- (solo authenticated).
revoke execute on function public.qa_admin_get_household_members(uuid) from public;
grant execute on function public.qa_admin_get_household_members(uuid) to authenticated;

-- 2) Storage: las policies del bucket `avatars` estaban abiertas a `public`
-- (rol que incluye anon). Esto permitía a cualquiera SIN login:
--   - listar/enumerar el bucket (SELECT)
--   - subir archivos arbitrarios al bucket (INSERT)
-- Las descargas de avatares usan la URL pública (/object/public/...), que
-- saltea RLS, así que mostrar avatares sigue funcionando. La subida real la
-- hace el usuario logueado (JWT de Firebase => rol authenticated), igual que
-- el bucket `receipts`. Cerramos ambas a authenticated.
drop policy if exists "Public Access" on storage.objects;
create policy "Avatars readable by authenticated"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'avatars');

drop policy if exists "Allow Public Uploads" on storage.objects;
create policy "Avatars uploadable by authenticated"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars');
