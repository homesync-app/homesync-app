# HomeSync - DB schema snapshot

El snapshot operativo del schema vive en `docs/schema.md`.

Este archivo existe porque el backlog tecnico lo nombra como punto de entrada estable para agentes IA. Para evitar drift entre dos snapshots manuales, no duplicar tablas aca: leer y actualizar `docs/schema.md` cuando cambien tablas, columnas o RPCs.

Regla: si una migracion agrega o cambia columnas/RPCs usados por la app, el mismo corte actualiza `docs/schema.md`.
