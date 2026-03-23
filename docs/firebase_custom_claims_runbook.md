# Firebase Claims Runbook

## Current status

The database is already prepared for Firebase-backed identity:

- `public.users.firebase_uid` exists
- `public.current_app_user_id()` exists
- core RLS policies already resolve through app identity helpers
- the two active test users already have `firebase_uid` backfilled in Supabase

## Users mapped

- Blas
  - email: `blas.r7@gmail.com`
  - app_user_id: `e4a31718-a63d-450f-b70f-db899dd109a9`
  - firebase_uid: `yTNKo5xTfHfoAFp89BTaW4VjNX52`
- Rochi
  - email: `gonzalezvenegasestudio@gmail.com`
  - app_user_id: `4fe99844-3706-4fde-8472-c2f1feb83c00`
  - firebase_uid: `3z4jQeVJHtRZANHBMAZi5hV7vD93`

## Required custom claims

Each Firebase user must receive:

- `role: "authenticated"`
- `app_user_id: "<public.users.id>"`

This is the minimum contract expected by Supabase third-party auth and the current database helpers.

## Prepared files

- claims payload: [custom_claims.users.json](C:/Users/Blas_/Documents/Aplicacion%20de%20Pareja/scripts/firebase/custom_claims.users.json)
- admin script: [set_custom_claims.mjs](C:/Users/Blas_/Documents/Aplicacion%20de%20Pareja/scripts/firebase/set_custom_claims.mjs)

## One-time execution steps

1. Obtain a Firebase service account JSON for the target project.
2. On a machine with Node.js installed, run:

```powershell
cd "C:\Users\Blas_\Documents\Aplicacion de Pareja"
npm install firebase-admin
$env:FIREBASE_SERVICE_ACCOUNT_JSON="C:\path\to\service-account.json"
node .\scripts\firebase\set_custom_claims.mjs
```

3. Sign out and sign back in on both devices, or force token refresh.

## Client-side token refresh

After claims are applied, users should refresh the Firebase token. The safest path is:

- sign out
- sign in again

If needed, the app can also force a refresh via `FirebaseAuth.instance.currentUser?.getIdToken(true)`.

## What still remains after claims

After claims are set successfully, the next final steps are:

1. enable the final Firebase third-party auth mode in the client
2. remove the legacy `signInWithIdToken(provider: google)` bridge from `firebase_auth_service.dart`
3. verify login, notifications, household access and finance privacy with both users
