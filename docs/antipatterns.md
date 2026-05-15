# HomeSync - Antipatterns

Lista corta de cosas que ya sabemos que hacen mas dificil tocar el repo.

- No invalidar `householdProvider` desde acciones de tareas si alcanza con invalidar tasks/feed/stats; causa rebuilds amplios.
- No mezclar recursos financieros y actividades sociales en la misma rama de UI por inferencia de strings. Usar el contrato de `docs/feed_contract.md`.
- No acreditar XP/coins en UI como fuente de verdad. El ledger lo decide el RPC.
- No usar `supabase.auth.signIn()`; auth es Firebase Auth + JWT como access token de Supabase.
- No usar `auth.uid()` en SQL/RLS nuevo. Usar `current_app_user_id()`.
- No actualizar `users` directo desde cliente. Usar RPC security-definer como `update_own_profile`.
- No editar `flutter_client/lib/l10n/generated/` a mano.
- No agregar abstracciones genericas de paginacion/estado solo por estetica; primero demostrar bug repetido.
- No leer `docs/archive/` salvo pedido explicito.
