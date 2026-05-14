---
version: alpha
name: HomeSync
description: Warm, collaborative design system for a Flutter household coordination app with couple, family, friends, and solo modes.
colors:
  primary: "#EE652B"
  primary-light: "#FFF0EA"
  primary-dark: "#D85A23"
  background: "#FFFCF9"
  surface: "#FFF8F2"
  elevated-surface: "#FDF6EF"
  nav-surface: "#FFFBF7"
  text-primary: "#4A4443"
  text-secondary: "#8E8480"
  text-muted: "#B2AAA6"
  text-on-primary: "#FFFFFF"
  divider: "#F0E4D9"
  border: "#F0E4D9"
  sage: "#84A59D"
  success: "#22C55E"
  warning: "#FFBD3D"
  error: "#E57373"
  info: "#84A59D"
  accent-blue: "#5A94E1"
  accent-purple: "#9575CD"
  accent-peach: "#E88D67"
  accent-orange: "#FF8A65"
  background-dark: "#1B1716"
  surface-dark: "#26211F"
  elevated-surface-dark: "#342E2B"
typography:
  display:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: 900
    lineHeight: 1.12
    letterSpacing: -1px
  title:
    fontFamily: Outfit
    fontSize: 26px
    fontWeight: 900
    lineHeight: 1.16
    letterSpacing: -1px
  card-title:
    fontFamily: Outfit
    fontSize: 18px
    fontWeight: 800
    lineHeight: 1.25
    letterSpacing: 0px
  body:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.5
    letterSpacing: 0px
  body-strong:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: 700
    lineHeight: 1.4
    letterSpacing: 0px
  label:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: 0px
  nav-label:
    fontFamily: Outfit
    fontSize: 12px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: 0px
rounded:
  xs: 8px
  sm: 12px
  md: 16px
  lg: 20px
  xl: 24px
  xxl: 28px
  modal: 32px
  pill: 999px
spacing:
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 40px
  xxxl: 48px
  screen-horizontal: 20px
  section-gap: 24px
  item-gap: 12px
components:
  screen:
    backgroundColor: "{colors.background}"
    textColor: "{colors.text-primary}"
    padding: "{spacing.screen-horizontal}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xl}"
    padding: 20px
  card-hero:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xxl}"
    padding: 20px
  button-primary:
    backgroundColor: "{colors.primary-light}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body-strong}"
    rounded: "{rounded.pill}"
    height: 52px
    padding: 28px
  button-soft:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body-strong}"
    rounded: "{rounded.pill}"
    height: 52px
    padding: 28px
  input:
    backgroundColor: "{colors.text-on-primary}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.lg}"
    padding: 24px
  pill:
    backgroundColor: "{colors.primary-light}"
    textColor: "{colors.text-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: 12px
  nav-bar:
    backgroundColor: "{colors.nav-surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.xl}"
    height: 64px
  divider:
    backgroundColor: "{colors.divider}"
    height: 1px
---

## Overview

HomeSync is a warm, practical household app. It should feel organized enough for recurring chores, money, approvals, and shopping, but never cold or administrative. The base mood is Scandi-warm: soft paper backgrounds, peach action color, sage reinforcement, rounded geometry, and generous breathing room.

The design language is shared across all household types, while each mode can shift emphasis through `HouseholdModeDesign`: couple mode can be more affectionate, family mode more operational, friends mode more direct, and solo mode calmer and more personal.

Primary implementation references:

- `flutter_client/lib/core/theme/app_colors.dart`
- `flutter_client/lib/core/theme/app_design_tokens.dart`
- `flutter_client/lib/core/theme/app_spacing.dart`
- `flutter_client/lib/core/theme/app_theme.dart`
- `docs/design-system.md`

## Colors

The palette avoids sterile white and harsh black. It uses warm off-white backgrounds, cream surfaces, grounded brown-gray text, and a focused set of accents.

- **Warm Peach (`#EE652B`):** The primary brand and action color. Use for floating actions, key selected states, and the most important action on a screen.
- **Soft Peach Wash (`#FFF0EA`):** Use for low-emphasis selected states, filled buttons, subtle icon wells, and gentle primary emphasis.
- **Warm Paper (`#FFFCF9`):** Default app background. It should make screens feel light, domestic, and readable.
- **Soft Cream Surface (`#FFF8F2`):** Default card, sheet, and grouped-content surface.
- **Warm Ink (`#4A4443`):** Main text color. Prefer this over pure black.
- **Muted Taupe (`#8E8480`, `#B2AAA6`):** Secondary text, metadata, helper copy, inactive labels, and quieter icons.
- **Sage (`#84A59D`):** Collaborative or reassuring accent, especially for positive household progress, calm states, and non-primary reinforcement.
- **Success Green (`#22C55E`):** Completed states, positive balances, successful sync, and confirmation.
- **Gold (`#FFBD3D`):** Rewards, coins, premium cues, and celebratory indicators.
- **Blue and Purple (`#5A94E1`, `#9575CD`):** Informational and category accents. Use sparingly.

Dark mode keeps the same warm direction with brown-black backgrounds and cream text. It should feel cozy and legible, not slate-blue or monochrome.

## Typography

Use Outfit everywhere, with `sans-serif` and `Arial` as fallbacks. Typography should feel rounded, clear, and modern.

Use `w900` for hero titles, dashboard amounts, and high-emphasis numbers. Use `w800` for card titles, selected tab labels, and important controls. Use `w700` for compact labels and key metadata. Use `w500` or `w600` for body/supporting copy so screens do not become visually loud.

Negative letter spacing is reserved for hero titles and large amounts. Standard UI labels and body text should keep neutral letter spacing.

## Layout

Mobile screens use a single-column flow with clear section grouping. Default horizontal screen padding is `20px`, compact internal gaps are `12px`, and section gaps are usually `24px`. Large feature breaks can use `32px` or more when the screen needs a quieter rhythm.

Prefer shared primitives before local layout code:

- `AppScreenScaffold` for screen background and structure.
- `AppCard` for repeated content and grouped blocks.
- `AppSectionHeader` for section titles and actions.
- `AppPill` for statuses, filters, and compact metadata.
- `AppSheetShell` for bottom sheets.
- `AppFloatingActionButton` for the main screen action.
- `CustomBottomNav` and `AppSegmentedTabs` for navigation patterns.

Avoid cards inside cards. Page sections should not become stacks of decorative containers when a simpler section header plus list would scan better.

## Elevation & Depth

Depth is soft and diffused. Cards use light borders plus low-opacity shadows. Floating controls and sheets can use stronger blur, but the shadow should remain warm and quiet.

Use `AppElevation.card`, `AppElevation.floating`, and `AppElevation.modal` instead of inventing local shadows. Gradients are reserved for hero, onboarding, and celebratory moments, with at most one gradient moment per screen.

## Shapes

HomeSync uses friendly rounded geometry:

- `12px` to `16px` for compact controls and small containers.
- `20px` for standard controls.
- `24px` for regular cards.
- `28px` for hero cards.
- `32px` for modal sheets and dialogs.
- `999px` for pills, chips, and badge-like controls.

Buttons are usually pill-shaped. Floating action buttons use a rounded square or extended pill treatment depending on context.

## Components

Primary actions should be visually obvious and limited to one main action per screen. When a screen has several possible actions, use a sheet rather than crowding the top-level interface.

Cards should hold real repeated content or meaningful grouped information. Hero cards are reserved for the main summary of a screen, such as household balance, weekly progress, or onboarding identity.

Inputs should use cream or white fills, warm borders, clear focus rings, and generous vertical padding. Error states use `#E57373`; success states use `#22C55E`.

Pills and badges should use low-opacity accent fills with strong text contrast. They are appropriate for XP, coins, status, category, due-date, and approval metadata.

## Do's and Don'ts

Do use `context.theme`, `AppColors`, `AppRadii`, `AppInsets`, `AppSpacing`, `AppElevation`, and `HouseholdModeDesign` before adding local values.

Do keep Spanish source copy in Argentine voseo and route all new UI strings through ARB.

Do let household mode change tone and emphasis while preserving the same component grammar.

Don't hardcode `Color(0x...)` inside feature screens unless the value is isolated and justified.

Don't make every surface a card, add nested cards, or use gradients to compensate for weak hierarchy.

Don't overuse bold text. A screen where everything is `w800` or `w900` loses hierarchy quickly.
