# HomeSync · Admin

Panel de administración interno de HomeSync. Es una SPA (React + Vite + TypeScript + Tailwind)
que lee directamente de Supabase con la `anon key` y la sesión del admin autenticado.

> Uso interno. El `index.html` incluye `noindex, nofollow` y no debe exponerse públicamente sin auth.

## Stack

- React 19 + Vite 7 + TypeScript
- Tailwind v4
- react-router-dom 7
- @supabase/supabase-js

## Secciones

| Ruta              | Página           | Qué muestra |
|-------------------|------------------|-------------|
| `/`               | Overview         | Métricas globales y actividad reciente |
| `/households`     | Hogares          | Lista de hogares con miembros (expandible) |
| `/users`          | Usuarios         | Miembros por hogar y su rol |
| `/activity`       | Actividad        | Cohortes y adopción (post-launch) |
| `/economy`        | Economía         | Flujo de XP y monedas |
| `/content`        | Contenido        | Plantillas de tareas y premios (CRUD) |
| `/inbox`          | Bandeja          | Issues, feedback, crashes y logs |
| `/ocr-insights`   | OCR Insights     | Pipeline del OCR de tickets |
| `/shopping-icons` | Íconos Compras   | Cobertura de íconos vs. uso real |
| `/settings`       | Configuración    | Cuenta, seguridad y logout |

## Desarrollo

```bash
npm install
npm run dev        # http://localhost:5173
npm run lint       # eslint
npm run build      # tsc -b && vite build → dist/
npm run preview    # sirve dist/ localmente
```

## Variables de entorno (`.env.local`)

```
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
VITE_SKIP_AUTH=true   # solo dev: saltea el login. Se ignora en cualquier build de producción.
```

> `VITE_SKIP_AUTH` solo tiene efecto cuando `import.meta.env.DEV` es `true`. Un build
> productivo (`npm run build`) siempre exige login, aunque la variable quede en `true`.
> No commitees `.env.local` ni la `service_role key`.

## Auth

Login vía Supabase Auth (email + password). El acceso a las tablas está sujeto a las RLS
policies del proyecto, así que el admin necesita una cuenta con permisos de lectura sobre
las vistas/tablas que consume el panel.
