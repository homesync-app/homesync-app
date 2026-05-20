-- =============================================================================
-- Fix RLS de ocr_scan_logs para el bridge Firebase third-party auth
-- =============================================================================
-- Bug que cierra esta migracion:
--   ocr_scan_logs.user_id se inserta desde el cliente con el "id interno" de
--   public.users (resultado de AppIdentityService). Pero la policy de INSERT
--   chequeaba `user_id = auth.uid()`, que bajo el bridge devuelve el Firebase
--   UID (subject del JWT), NO el users.id. Resultado: TODOS los inserts de
--   OCR fueron silenciosamente rechazados por RLS. La tabla en prod tiene
--   0 filas; el panel admin de OCR mostraba 0 scans aunque los usuarios si
--   estaban escaneando.
--
-- Evidencia: una de las policies de SELECT ya estaba migrada a
-- is_current_app_admin() (que internamente usa current_app_user_id() y la
-- resolucion por firebase_uid). La INSERT y UPDATE se olvidaron en la
-- migracion del bridge.
--
-- Fixes:
--   1. INSERT policy -> usar current_app_user_id() (mismo helper que el
--      resto del repo) en lugar de auth.uid().
--   2. UPDATE policy -> idem.
--   3. Drop "admins read all logs" (vieja, rota, redundante con
--      "admins can read ocr_scan_logs" que usa is_current_app_admin()).
--   4. Add "users select own logs" -> los usuarios pueden leer SOLO sus
--      propios logs. Sin esto, el .select('id') post-insert del cliente
--      devuelve null y los subsiguientes updates (matcher_result, user_action)
--      nunca se ejecutan, dejando los logs incompletos.
-- =============================================================================

-- 1. INSERT: reemplazar auth.uid() por current_app_user_id() ------------------

drop policy if exists "users insert own logs" on public.ocr_scan_logs;

create policy "users insert own logs"
  on public.ocr_scan_logs
  for insert
  to authenticated
  with check (user_id = public.current_app_user_id());


-- 2. UPDATE: idem ------------------------------------------------------------

drop policy if exists "users update own logs" on public.ocr_scan_logs;

create policy "users update own logs"
  on public.ocr_scan_logs
  for update
  to authenticated
  using (user_id = public.current_app_user_id())
  with check (user_id = public.current_app_user_id());


-- 3. SELECT users propios (nuevo) --------------------------------------------
-- Sin esto, el cliente no puede leer back el id que acaba de insertar y los
-- updates posteriores (matcher_result, user_action) quedan huerfanos.

drop policy if exists "users select own logs" on public.ocr_scan_logs;

create policy "users select own logs"
  on public.ocr_scan_logs
  for select
  to authenticated
  using (user_id = public.current_app_user_id());


-- 4. Borrar SELECT vieja de admin (rota, redundante) -------------------------
-- La policy "admins can read ocr_scan_logs" con is_current_app_admin() cubre
-- el caso correctamente. Esta vieja apuntaba a auth.uid() que bajo el bridge
-- no resuelve al users.id interno.

drop policy if exists "admins read all logs" on public.ocr_scan_logs;
