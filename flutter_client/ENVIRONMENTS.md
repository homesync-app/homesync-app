# HomeSync Environment Setup

HomeSync no toma credenciales desde el codigo fuente. Todas las variables se
inyectan con `--dart-define` o `--dart-define-from-file`.

## Variables requeridas

Siempre:

- `APP_ENV`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GOOGLE_WEB_CLIENT_ID`

Adicionales para Web:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`

## Archivo local recomendado

1. Copia `flutter_client/.env.example` a `flutter_client/.env.local`.
2. Completa los valores reales.
3. Mantene ese archivo fuera de git.

Ejemplo:

```bash
cd flutter_client
copy .env.example .env.local
```

## Ejecutar en staging

```bash
flutter run --dart-define-from-file=.env.local
```

Si queres forzar staging explicitamente:

```bash
flutter run --dart-define-from-file=.env.local --dart-define=APP_ENV=staging
```

## Ejecutar en production

```bash
flutter run --dart-define-from-file=.env.production --dart-define=APP_ENV=production
```

## Build Android release

```bash
flutter build appbundle --release --dart-define-from-file=.env.production --dart-define=APP_ENV=production
```

## CI/CD

El workflow de produccion ya builda con:

```bash
flutter build appbundle --release --dart-define=APP_ENV=production
```

Ademas de eso, el runner debe inyectar el resto de variables sensibles por
`--dart-define` o generar un archivo de entorno antes del build.

## Validacion al arrancar

La app falla temprano si faltan variables obligatorias. Eso evita publicar un
build que arranca apuntando al entorno equivocado o con credenciales vacias.
