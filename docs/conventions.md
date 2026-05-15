# HomeSync - Convenciones tecnicas

## Providers

- `xxxProvider`: lectura o derivacion sin mutaciones.
- `xxxControllerProvider`: mutaciones o acciones con `AsyncNotifier`/controller.
- `xxxStreamProvider`: realtime, sockets o streams externos.
- `xxx<Action>Provider`: calculo derivado especifico, sin efectos secundarios.

Antes de crear un provider nuevo, buscar por feature y preferir extender el controller existente si la accion modifica el mismo estado.

## Riverpod

- Providers con realtime/sockets: `@Riverpod(keepAlive: true)`.
- Resto: `autoDispose` por defecto.
- Retry declarativo solo en providers de lectura.
- Nunca retry automatico en errores de negocio, auth, permisos o validacion.
- `ref.mounted` es obligatorio en callbacks async/fire-and-forget antes de tocar `ref` despues de un `await`.
- No poner side effects criticos en widgets pausables por `TickerMode`.

## RPCs

- Acciones criticas nuevas usan nombre versionado: `accion_v1`.
- Mantener wrappers legacy por 1-2 releases cuando se renombra un RPC usado por clientes en vuelo.
- Todo RPC critico debe tener entrada en `docs/rpc_contracts.md`.
- SQL/RLS usa `current_app_user_id()` para Firebase JWTs; no usar `auth.uid()` en codigo nuevo.

## Documentacion

- Si una regla evita repetir un bug, va a `docs/antipatterns.md`.
- Si una accion tiene optimistic update, va a `docs/optimistic_policy.md`.
- Si una card decide comportamiento por tipo de feed, va a `docs/feed_contract.md`.
