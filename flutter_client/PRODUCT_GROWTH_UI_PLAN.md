# HomeSync Product Growth + UI Plan

Fecha: 2026-04-10

## Objetivo

Subir la calidad percibida del producto y mejorar retencion con un plan que combine:

- mejor UX visual,
- mejor instrumentacion,
- mejor lectura de comportamiento real de usuarios.

## Estado Actual

### Ya aplicado

- Hay base de animaciones e interacciones fluidas en varios widgets.
- Ya existen respuestas hapticas en acciones importantes.
- La navegacion inferior ya usa una logica parcial de icono activo/inactivo.
- Existen empty states reutilizables.
- Firebase Crashlytics ya esta integrado.

### Aplicado a medias

- Empty states: funcionales pero sin ilustraciones o identidad visual propia.
- Sistema de iconos: correcto pero no totalmente consistente en toda la app.
- Animaciones: hay base tecnica, pero faltan momentos de alto impacto.
- Analytics: dependencia instalada, pero sin eventos de producto consistentes.

### No aplicado

- Waitlist / pagina de captura.
- Feedback board.
- Automatizaciones de email por comportamiento.
- Landing page final.
- Instrumentacion de funnels clave.

## Prioridades

### Fase 1 - Medir primero

Objetivo: entender donde entra, avanza y abandona la gente.

Tareas:

1. Crear servicio centralizado de analytics.
2. Medir funnel de autenticacion:
   - `auth_sign_in_started`
   - `auth_sign_in_succeeded`
   - `auth_sign_in_failed`
   - `auth_sign_up_started`
   - `auth_sign_up_succeeded`
   - `auth_sign_up_failed`
   - `auth_google_sign_in_started`
   - `auth_google_sign_in_succeeded`
   - `auth_google_sign_in_failed`
3. Medir `app_opened` y vistas de pantalla principales.
4. Medir eventos de activacion:
   - primera tarea creada,
   - primer gasto creado,
   - apertura de paywall,
   - inicio de compra premium.

### Fase 2 - Mejorar personalidad visual

Objetivo: que la app se sienta mas terminada y memorable.

Tareas:

1. Reemplazar empty states clave por variantes con ilustracion/mascota.
2. Definir criterio de iconografia:
   - una familia principal,
   - outlined para inactivo,
   - filled para activo,
   - evitar mezclar estilos sin motivo.
3. Elegir 4 microinteracciones premium:
   - completar tarea,
   - guardar gasto,
   - cambiar tab,
   - guardar perfil/avatar.

### Fase 3 - Retencion y discovery

Objetivo: traer feedback real y mejorar conversion.

Tareas:

1. Crear landing page final.
2. Agregar feedback board.
3. Diseñar secuencias de email para onboarding e inactividad.
4. Mejorar store listing y screenshots de lanzamiento.

## Orden Recomendado

1. Analytics.
2. Empty states con identidad.
3. Sistema de iconos y tabs.
4. Microinteracciones clave.
5. Landing page final.
6. Feedback board.
7. Emails automatizados.

## Trabajo Iniciado Hoy

Se comienza con:

- servicio base de analytics,
- observacion de navegacion,
- eventos del funnel de autenticacion.
