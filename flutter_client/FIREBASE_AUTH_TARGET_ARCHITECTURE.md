# Firebase Auth Target Architecture

## Goal

Keep Firebase as the identity authority and let Supabase consume Firebase JWTs
directly as a third-party auth provider.

This avoids the current fragile pattern where a Firebase sign-in is translated
into a Supabase Google sign-in flow.

## Recommended architecture

- Firebase Auth is the only login authority for email/password and Google.
- Supabase uses Firebase JWTs through `accessToken`.
- App data keeps using internal app user IDs instead of coupling every foreign
  key to the raw Firebase UID.
- Authorization in Postgres must resolve the current app user from Firebase
  claims or a mapping table.

## Important current constraint

The current database schema uses `uuid` foreign keys that point to
`public.users.id` and, in many places, to `auth.users.id`.

That means a direct switch to raw Firebase UIDs is not safe, because Firebase
UIDs are strings and do not match the existing UUID-based identity model.

## Professional migration path

1. Keep `public.users.id` as the internal app UUID.
2. Add `public.users.firebase_uid text unique`.
3. Configure Supabase Third-Party Auth with Firebase.
4. Add Firebase custom claims:
   - `role = authenticated`
   - `app_user_id = <public.users.id>`
5. Update RLS/helpers/functions to resolve the current app user from
   `auth.jwt()->>'app_user_id'`.
6. Move the app UI/session gate to Firebase auth state.
7. Stop using Supabase native password auth for end users.

## What can be implemented locally

- App environment flags for auth mode.
- Supabase client configuration with Firebase `accessToken`.
- Client-side migration from Supabase-auth-driven UI to Firebase-auth-driven UI.
- Database migrations to support `firebase_uid` and claim-based resolution.

## What still requires Firebase access

- Enable Firebase Third-Party Auth integration in Supabase.
- Add Firebase Authentication blocking functions or an Admin SDK script to set
  custom claims for all users.
- Backfill claims for existing Firebase users.

## Current repo status

The repo is now prepared to support an auth mode called
`firebase_third_party`, but it should not be enabled until the Firebase custom
claims and database mapping strategy are in place.
