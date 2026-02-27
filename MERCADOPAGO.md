# Mercado Pago Integration Plan

## Objective

Integrate Mercado Pago into the Couple's App to facilitate expense settlement and potentially track shared expenses automatically.

## Integration Levels

### Phase 1: Easy Settlement (Manual)

- **Feature**: Button "Pagar con Mercado Pago" for debts.
- **Workflow**:
  1. User selects a debt/expense.
  2. Flutter app calls Supabase Edge Function `mercadopago-api`.
  3. Edge Function creates a "Preference" in Mercado Pago.
  4. Flutter app receives the `init_point` (URL).
  5. App opens the link in a WebView or using `url_launcher`.
  6. Return to app after payment via Deep Linking.

### Phase 2: Transaction Monitoring (Automatic - "Connect")

- **Feature**: Sync expenses automatically from MP account.
- **Workflow**:
  1. OAuth2 flow between the App and Mercado Pago.
  2. Securely store the `access_token` for the user in Supabase.
  3. Register Webhooks for "payment" and "merchant_order" events.
  4. Background process detects shared categories/merchants and suggests logging the expense.

## Requirements

- Mercado Pago Developer Account: **Connected**
- App ID: `2648429143493552`
- Public Key: `APP_USR-a4c4dfa6-e46b-424f-bbf1-7ccaa3ee114f`
- Access Token: (Stored in Supabase Secrets)
- Sandbox Test User: `TESTUSER8144198973828459144`

## Technical Roadmap

1. [x] Setup MP Developer Application.
2. [ ] Create Supabase Edge Function for Preference creation and OAuth.
3. [ ] Implement `mercadopago_service.dart` in Flutter.
4. [ ] Setup Deep Linking in `AndroidManifest.xml` and `Info.plist`.
5. [ ] Create "Vincular Mercado Pago" screen in Flutter.
6. [ ] Implement automatic expense suggestion from MP history.
