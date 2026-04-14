# Design System: Aplicacion de Pareja

**Project ID:** 17415806387289055570
**Base Screen ID:** fe771d1455594eac947a1c0fe217f6ce

## 1. Visual Theme & Atmosphere

The application embodies a "Scandi-warm" atmosphere—clean, minimalist, but highly approachable and friendly. It avoids sterile whites and sharp greys in favor of soft cream tones, pastel accents, and generous whitespace. It feels collaborative, positive, and reinforcing rather than strictly utilitarian.

## 2. Color Palette & Roles

- **Warm Off-White (#FFFCF9):** Used as the main application background. Gives a soft, paper-like feel.
- **Soft Cream (#FDFBF7):** Used for elevated surfaces like cards, modal sheets, and floating containers.
- **Warm Peach (#FF8A65):** The primary accent color (Call to Action). Used for main buttons, floating action buttons, and active states.
- **Soft Sage Green (#81C784):** The secondary accent color. Used for positive reinforcement like XP tags, completed checkmarks, and positive balances.
- **Warm Dark Gray (#4A4443):** Used for primary text (headers, important paragraph text). Avoids the harshness of pitch black.
- **Muted Taupe (#9E9592):** Used for secondary text, metadata, dates, and subtle borders.

## 3. Typography Rules

- **Font Family:** Outfit (modern, rounded sans-serif with warm personality).
- **Headers:** High emphasis, bold weight (700-800), tight letter-spacing (-0.5px) for a modern feel.
- **Body/Secondary:** Regular or Medium weight (400-500) with generous line height (1.5) for readability.

## 4. Component Stylings

- **Buttons:** Fully pill-shaped (100% border radius). Usually filled with Warm Peach. Deep, soft, diffused shadow to make them highly tappable.
- **Cards/Containers:** Generously rounded corners (24px). Background is Soft Cream. They feature whisper-soft, diffused drop shadows (blur radius 10px-20px with very low opacity ~2-5%) rather than harsh borders.
- **Tags/Badges:** Pill-shaped capsules for XP, Coins, or Status labels. They use low-opacity backgrounds of their respective accent colors (e.g., 15% opacity Sage Green for XP).

## 5. Layout Principles

- **Whitespace:** Prominent use of negative space. Generous padding inside cards (16px - 24px) and margins between sections (32px).
- **Grid Alignment:** Single-column vertical list layouts are preferred on mobile, with logical grouping of related information via cards.

## 6. Design System Notes for Stitch Generation

[Copy this block when using the `enhance-prompt` skill for Stitch generation]
**DESIGN SYSTEM (REQUIRED):**

- Platform: Mobile, iOS-friendly
- Theme: Light, Scandi-warm, friendly, clean
- Background: Warm Off-White (#FFFCF9)
- Surface: Soft Cream (#FDFBF7)
- Primary Accent: Warm Peach (#FF8A65) for main actions
- Secondary Accent: Soft Sage Green (#81C784) for positive rewards/XP
- Text Primary: Warm Dark Gray (#4A4443)
- Text Secondary: Muted Taupe (#9E9592)
- Components: Generously rounded corners (24px for cards, fully pill-shaped for buttons), whisper-soft diffused shadows.
