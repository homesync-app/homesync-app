# Premium Custom Avatar Generation

## Objetivo

Permitir que usuarios Premium generen 1 avatar personalizado por mes a partir de una foto, manteniendo el estilo visual de los avatares premium actuales.

## Política de datos

- La foto original nunca se guarda.
- La foto original se comprime en el cliente y se envía solo a la Edge Function.
- La Edge Function genera un avatar con fondo transparente.
- Solo se guarda el avatar final optimizado en Supabase Storage.
- El perfil del usuario guarda una URL pública del avatar final en `users.avatar_url`.

## Límites

- Solo usuarios con `users.is_premium = true`.
- 1 generación por usuario por mes calendario.
- Imagen de entrada máxima: 5 MB en base64.
- Avatar final: `1024x1024`, `webp`, fondo transparente.

## Flujo

1. Usuario toca `Crear avatar personalizado`.
2. Elige cámara o galería.
3. Cliente comprime la imagen a WebP.
4. Cliente invoca `generate-custom-avatar` con Firebase ID token.
5. Edge Function valida JWT de Firebase.
6. Edge Function verifica Premium y límite mensual.
7. Edge Function llama OpenAI Images API.
8. Edge Function sube el avatar final a `custom-avatars`.
9. Cliente actualiza `users.avatar_url` usando el flujo existente.

## Prompt base

Crear un avatar premium tierno, cálido y pulido para HomeSync, inspirado en la persona de la foto sin ser fotorrealista. Estilo ilustración 3D suave, familiar, amigable, colores crema, peach y sage, torso/cabeza grande para leerse bien en móvil, fondo transparente, sin texto, sin borde, sin recortes.

