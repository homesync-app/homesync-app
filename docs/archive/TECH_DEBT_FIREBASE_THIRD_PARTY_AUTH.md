# Deuda Técnica: Migración a Firebase Third-Party Auth Correcto

## Estado actual

El proyecto tiene **Firebase Third-Party Auth habilitado en Supabase** (proyecto `homesync-prod-r7-123`) pero el cliente Flutter **no lo usa correctamente**. En su lugar:

- **Google Sign-In**: usa `signInWithIdToken(provider: OAuthProvider.google, googleOAuthToken)` → crea sesión Supabase nativa (funciona)
- **Email/Password**: usa dual auth — Firebase + Supabase `signInWithPassword` en paralelo (workaround funcional pero no ideal)

El `AUTH_MODE=firebase_third_party` en el código es un nombre conceptual, no refleja la implementación oficial de Supabase.

## Lo que debería ser

Con Third-Party Auth correctamente implementado, **el JWT de Firebase se usa directamente** para cada request a Supabase. No hay sesión Supabase — Supabase valida el JWT contra los JWKS de Firebase en cada llamada.

### Inicialización correcta del cliente

```dart
await Supabase.initialize(
  url: AppEnvironment.supabaseUrl,
  anonKey: AppEnvironment.supabaseAnonKey,
  accessToken: () async =>
      await FirebaseAuth.instance.currentUser?.getIdToken(),
);
```

### Flujo de login simplificado

```dart
// Solo Firebase — no hay que hacer nada en Supabase
await FirebaseAuth.instance.signInWithEmailAndPassword(email, password);
// El accessToken callback provee el JWT automáticamente a Supabase
```

## Requisitos para la migración

### 1. Agregar `role: "authenticated"` a los tokens de Firebase

Sin este claim, Supabase trata al usuario como `anon` y las RLS bloquean todo.

**Opción A — Firebase Blocking Function (recomendada):**
```javascript
// functions/index.js
const { beforeSignIn } = require('firebase-functions/v2/identity');

exports.beforeSignIn = beforeSignIn((event) => {
  return {
    customClaims: {
      role: 'authenticated',
    },
  };
});
```
Se ejecuta sincrónicamente en cada sign-in. Requiere **Firebase Identity Platform** (plan Blaze).

**Opción B — `onCreate` Cloud Function (async):**
```javascript
exports.addAuthRole = functions.auth.user().onCreate(async (user) => {
  await admin.auth().setCustomUserClaims(user.uid, { role: 'authenticated' });
});
```
Requiere `getIdToken(true)` (force refresh) después del primer signup para que el claim esté disponible.

### 2. Actualizar RLS policies

Firebase UIDs son strings alfanuméricos (`XrL9gj2kNpQ4mR7v...`), **no son UUIDs**. Hay que cambiar las policies:

```sql
-- ANTES (sesión Supabase nativa)
USING (user_id = auth.uid())

-- DESPUÉS (Third-Party Auth con Firebase UID como TEXT)
USING (user_id = (auth.jwt()->>'sub'))
```

También hay que cambiar las columnas `user_id` de `UUID` a `TEXT` en todas las tablas afectadas.

### 3. Eliminar `_client.auth.currentSession` y `_client.auth.currentUser`

Con Third-Party Auth no hay sesión Supabase. Ambos retornan `null`. Hay que reemplazar con:

```dart
// ANTES
final userId = _client.auth.currentUser?.id;

// DESPUÉS
final userId = FirebaseAuth.instance.currentUser?.uid;
```

Archivos afectados (buscar con `grep -rn "currentSession\|currentUser" lib/`).

### 4. Remover lógica de sync manual de sesión Supabase

Eliminar de `FirebaseAuthService`:
- `_prepareSupabaseAfterFirebaseSignIn()`
- `_syncSupabaseSessionWithFirebase()`
- `_performSupabaseSessionSync()`
- `_syncSupabaseWithEmailPassword()`
- `_ensureProvisionedAccess()`
- `syncSupabaseSessionIfNeeded()`

Y simplificar `signInWithEmail`, `signUpWithEmail`, `signInWithGoogle` para que solo hagan la parte de Firebase.

### 5. Actualizar `AppIdentityService`

Actualmente resuelve el user ID desde Supabase. Debería resolverlo desde Firebase:

```dart
Future<String?> refresh() async {
  return FirebaseAuth.instance.currentUser?.uid;
}
```

### 6. Actualizar `receipt_scan_service.dart`

Actualmente usa `_supabase.auth.currentSession?.accessToken`. Con Third-Party Auth debe usar el Firebase token:

```dart
final accessToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
```

## Impacto estimado

| Área | Archivos afectados | Complejidad |
|------|-------------------|-------------|
| Firebase Auth Service | `firebase_auth_service.dart` | Alta |
| App Identity Service | `app_identity_service.dart` | Media |
| Supabase Auth Service | `supabase_auth_service.dart` | Alta |
| RLS migrations | N migraciones SQL | Alta |
| DB schema (UUID → TEXT) | Múltiples tablas | Muy alta |
| receipt_scan_service | 1 archivo | Baja |
| Todos los repos que usan `currentUser` | ~10 archivos | Media |

## Orden de ejecución recomendado

1. Firebase Blocking Function (Identity Platform)
2. Nueva migración SQL: columnas `user_id UUID → TEXT`
3. Nueva migración SQL: RLS policies actualizadas
4. Actualizar `Supabase.initialize` con `accessToken` callback
5. Refactorizar `FirebaseAuthService` (eliminar sync manual)
6. Refactorizar `AppIdentityService`
7. Actualizar repositories que leen `currentUser`
8. Test end-to-end con usuario nuevo y usuario existente
9. Migrar usuarios existentes (Firebase UID → Supabase UUID mapping si aplica)

## Notas importantes

- Los usuarios existentes tienen datos asociados a **Supabase UUIDs**, no a Firebase UIDs. Necesitarás una migración de datos o una tabla de mapping `firebase_uid → supabase_uuid` durante la transición.
- Evaluar si vale la pena la migración completa o si el dual auth actual (que ya funciona) es suficiente para el MVP.
- Referencia: [Supabase Firebase Auth Docs](https://supabase.com/docs/guides/auth/third-party/firebase-auth)
