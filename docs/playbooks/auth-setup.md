# Playbook: Auth / Setup / Onboarding

## Archivos clave

- `flutter_client/lib/features/auth/` — Firebase auth service, identity resolution
- `flutter_client/lib/features/household/presentation/screens/setup_screen.dart` (~2243 LOC — NO leer entero)
- `flutter_client/lib/features/household/presentation/screens/setup_widgets.dart` (~576 LOC — widgets compartidos)
- `flutter_client/lib/features/household/presentation/screens/member_onboarding_screen.dart`
- `flutter_client/lib/core/services/app_identity_service.dart`

## Flujo Auth → Identity

```
FirebaseAuth.instance.currentUser
  → AppIdentityService.refresh()
    → ensure_user_profile(firebase_uid, email, displayName, photoURL)
      → current_app_user_id() [SQL]
        → busca JWT sub → users.firebase_uid → users.id
```

## Flujo Setup (8 pasos wizard)

`setup_screen.dart` — busca `switch (_currentStep)`:
- Steps 0-7 son métodos `_build*Step*` dentro de `_SetupScreenState`
- Business logic (initState, handlers): ~lines 35-690

## Widgets extraídos

`setup_widgets.dart` contiene widgets reutilizables del wizard:
- `SetupStepEyebrow`, `SetupSupportBullet`, `SetupHeading`
- `SetupPrimaryButton`, `SetupSecondaryButton`
- `SetupFeatureCard`, `SetupStrategyTip`
- `SetupFamilyPanel`, `SetupFamilyChoiceChip`
- `SetupOptionTile`, `SetupOnboardingIllustration`

## Member Onboarding

1. `join_household_by_code` inserta con `onboarding_completed = false`
2. `MemberOnboardingScreen` → elige rol → `complete-member_onboarding` RPC

## Reglas

- NUNCA usar `supabase.auth.signIn()` — siempre Firebase Auth → JWT → Supabase
- `ensure_user_profile` usa `coalesce` — no sobreescribe datos existentes
- `_prefillIdentityFromAuth` solo pre-llena nombre para Google sign-in
- Tipos de hogar: `couple` (max 2, single-use code), `family`/`friends` (sin límite, multi-use)
