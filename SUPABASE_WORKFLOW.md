# Flujo Profesional de Supabase (HomeSync)

Para evitar problemas de que la aplicación busque una función que "no existe", o que el esquema se rompa trabajando en equipo, de ahora en adelante **el código manda sobre la base de datos**.

## Escenario A: Haces el cambio en la Web de Supabase (Panel Gráfico)

Si por conveniencia creas una columna o una nueva función RPC usando el panel gráfico o el editor SQL de la cuenta web:

1. Abre la terminal en esta carpeta.
2. Vincula el proyecto local con el de la web (solo la primera vez):
   ```bash
   supabase link --project-ref tfavamqszdkoeabpyxms
   ```
   (Te pedirá tu contraseña o token de acceso de Supabase).
3. **Descarga el cambio a tu código inmediatamente:**
   ```bash
   supabase db pull
   ```

> **¿Qué hace esto?** Lee tu producción actual, detecta tus cambios manuales, y auto-genera un archivo `.sql` dentro de `supabase/migrations/` (¡ojo, la carpeta oficial de Supabase, no tu antigua carpeta `database/migrations`!) con todos los cambios que hiciste. Esto luego lo subes por GitHub y ¡Boom!, tu base de datos tiene versionado de código.

## Escenario B: Haces el cambio escribiendo código SQL primero (Recomendado nivel Senior)

1. En la consola crea un archivo vacío nuevo:
   ```bash
   supabase migration new arreglar_bug_xp
   ```
2. Eso creará un archivo nuevo. Ábrelo en Visual Studio Code, y escribe el código (ej. `ALTER TABLE...`).
3. Empuja el cambio a producción:
   ```bash
   supabase db push
   ```
   > ¡Listo! Ya hiciste un cambio en producción sin tocar la web, y quedó rastreado en GitHub.
